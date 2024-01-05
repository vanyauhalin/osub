package rest

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
	"vanyauhalin/osub/internal/meta"

	"github.com/google/go-querystring/query"
)

const (
	version   = "v1"
	baseURL   = "https://api.opensubtitles.com/api/" + version + "/"
	userAgent = meta.ID + " " + meta.Tag
)

const apiKeyHeader = "Api-Key"
var   apiKey string

var (
	ErrBaseURLTrailingSlash = errors.New("rest: base url must have a trailing slash")
	ErrURLPathLeadingSlash  = errors.New("rest: url path must not have a leading slash")
)

type Client struct {
	client *http.Client

	BaseURL   *url.URL
	UserAgent string

	internal service

	Auth      *AuthService
	Download  *DownloadService
	Features  *FeaturesService
	Infos     *InfosService
	Subtitles *SubtitlesService
}

type service struct {
	client *Client
}

func NewClient() *Client {
	client := &http.Client{}
	c := &Client{client: client}
	c.init()
	return c
}

func (c *Client) WithJWT(token string) *Client {
	cp := c.copy()
	defer cp.init()

	t := cp.client.Transport
	if t == nil {
		t = http.DefaultTransport
	}

	cp.client.Transport = roundTripperFunc(
		func (req *http.Request) (*http.Response, error) {
			ctx := req.Context()
			req = req.Clone(ctx)

			s := fmt.Sprintf("Bearer %s", token)
			req.Header.Set("Authorization", s)

			return t.RoundTrip(req)
		},
	)

	return cp
}

func (c *Client) init() {
	if c.client == nil {
		c.client = http.DefaultClient
	}
	if c.BaseURL == nil {
		c.BaseURL, _ = url.Parse(baseURL)
	}
	if c.UserAgent == "" {
		c.UserAgent = userAgent
	}
	c.internal.client = c
	c.Auth = (*AuthService)(&c.internal)
	c.Download = (*DownloadService)(&c.internal)
	c.Features = (*FeaturesService)(&c.internal)
	c.Infos = (*InfosService)(&c.internal)
	c.Subtitles = (*SubtitlesService)(&c.internal)
}

func (c *Client) copy() *Client {
	return &Client{
		client: c.client,
		BaseURL: c.BaseURL,
		UserAgent: c.UserAgent,
	}
}

func (c *Client) NewURL(path string, params interface {}) (*url.URL, error) {
	if !strings.HasSuffix(c.BaseURL.String(), "/") {
		return nil, ErrBaseURLTrailingSlash
	}
	if strings.HasPrefix(path, "/") {
		return nil, ErrURLPathLeadingSlash
	}

	u, err := c.BaseURL.Parse(path)
	if err != nil {
		return nil, err
	}

	if params == nil {
		return u, nil
	}

	// TODO: apply performance recommendations.
	// - send GET parameters alphabetically sorted
	// - send GET parameters and values in lowercase
	// - in GET values remove "tt" from IMDB ID & remove leading 0 in any "ID" parameters

	q, err := query.Values(params)
	if err != nil {
		return nil, err
	}

	s := q.Encode()
	if len(s) > 0 {
		// For some unknown reason, some parameters may not come leading.
		u.RawQuery = "&" + s
	}

	return u, nil
}

func (c *Client) NewRequest(method string, url *url.URL, body interface {}) (*http.Request, error) {
	var b io.ReadWriter
	if body != nil {
		p, err := json.Marshal(body)
		if err != nil {
			return nil, err
		}
		b = bytes.NewBuffer(p)
	}

	req, err := http.NewRequest(method, url.String(), b)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Accept", "application/json")
	req.Header.Set(apiKeyHeader, apiKey)

	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	if c.UserAgent != "" {
		req.Header.Set("User-Agent", c.UserAgent)
	}

	return req, nil
}

func (c *Client) Do(ctx context.Context, req *http.Request, i interface {}) (*http.Response, error) {
	res, err := c.BareDo(ctx, req)
	if err != nil {
		return res, err
	}

	defer res.Body.Close()

	if i != nil {
		d := json.NewDecoder(res.Body)
		dErr := d.Decode(i)
		if dErr == io.EOF {
			// Ignore EOF errors caused by empty response body.
			dErr = nil
		}
		if dErr != nil {
			err = dErr
		}
	}

	return res, err
}

func (c *Client) BareDo(ctx context.Context, req *http.Request) (*http.Response, error) {
	if ctx == nil {
		return nil, nil
	}

	req = req.WithContext(ctx)

	res, err := c.client.Do(req)
	if err != nil {
		// If we got an error, and the context has been canceled, the context's
		// error is probably more useful.
		select {
		case <-ctx.Done():
			return nil, ctx.Err()
		default:
			// continue
		}
		return nil, err
	}

	return res, nil
}

// Helper routine that allocates a new bool value to store v and returns a
// pointer to it.
func Bool(v bool) *bool {
	return &v
}

// Helper routine that allocates a new float32 value to store v and returns a
// pointer to it.
func Float32(v float32) *float32 {
	return &v
}

// Helper routine that allocates a new int value to store v and returns a
// pointer to it.
func Int(v int) *int {
	return &v
}

// Helper routine that allocates a new string value to store v and returns a
// pointer to it.
func String(v string) *string {
	return &v
}

// Helper routine that allocates a new time.Time value to store v and returns a
// pointer to it.
func Time(v string) *time.Time {
	t, _ := time.Parse(time.RFC3339, v)
	return &t
}

// Creates a RoundTripper (transport).
type roundTripperFunc func(*http.Request) (*http.Response, error)

func (fn roundTripperFunc) RoundTrip(r *http.Request) (*http.Response, error) {
	return fn(r)
}
