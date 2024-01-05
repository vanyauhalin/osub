package rest

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"net/url"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockPP struct {
	A *int    `url:"a,omitempty" json:"a,omitempty"`
	B *int    `url:"b,omitempty" json:"b,omitempty"`
	C *string `url:"c,omitempty" json:"c,omitempty"`
}

func TestInitializesURLWithoutParameters(t *testing.T) {
	client, _, teardown := setup()
	defer teardown()

	e := client.BaseURL.String() + "e"
	a, err := client.NewURL("e", nil)
	require.NoError(t, err)
	assert.Equal(t, e, a.String())
}

func TestInitializesURLWithOmittedParameters(t *testing.T) {
	client, _, teardown := setup()
	defer teardown()

	e := client.BaseURL.String() + "e"
	p := &mockPP{}
	a, err := client.NewURL("e", p)
	require.NoError(t, err)
	assert.Equal(t, e, a.String())
}

func TestInitializesURLWithParameters(t *testing.T) {
	client, _, teardown := setup()
	defer teardown()

	e := client.BaseURL.String() + "e?&a=0&b=1&c=a+b+c"
	p := mockStruct()
	a, err := client.NewURL("e", p)
	require.NoError(t, err)
	assert.Equal(t, e, a.String())
}

func TestReturnsAnErrorIfBaseURLEndsNotHaveATrailingSlash(t *testing.T) {
	client, _, teardown := setup()
	defer teardown()

	u := client.BaseURL.String()
	s := u[:len([]rune(u)) - 1]

	client.BaseURL, _ = url.Parse(s)
	_, err := client.NewURL("e", nil)
	assert.ErrorIs(t, err, ErrBaseURLTrailingSlash)
}

func TestReturnsAnErrorIfURLPathHaveALeadingSlash(t *testing.T) {
	client, _, teardown := setup()
	defer teardown()

	_, err := client.NewURL("/e", nil)
	assert.ErrorIs(t, err, ErrURLPathLeadingSlash)
}

func TestInitializesRequestWithoutPayload(t *testing.T) {
	client, _, teardown := setup()
	defer teardown()

	u, err := client.NewURL("e", nil)
	require.NoError(t, err)

	r, err := client.NewRequest("GET", u, nil)
	require.NoError(t, err)

	testInitializesRequestHeaders(t, r)
	assert.Equal(t, "GET", r.Method)
	assert.Equal(t, u, r.URL)
	assert.Nil(t, r.Body)
}

func TestInitializesRequestWithPayload(t *testing.T) {
	client, _, teardown := setup()
	defer teardown()

	e := mockStruct()

	u, err := client.NewURL("e", nil)
	require.NoError(t, err)

	r, err := client.NewRequest("POST", u, e)
	require.NoError(t, err)

	d := json.NewDecoder(r.Body)
	a := &mockPP{}
	err = d.Decode(a)
	require.NoError(t, err)

	testInitializesRequestHeaders(t, r)
	assert.Equal(t, "application/json", r.Header.Get("Content-Type"))
	assert.Equal(t, "POST", r.Method)
	assert.Equal(t, u, r.URL)
	assert.Equal(t, e, a)
}

func testInitializesRequestHeaders(t *testing.T, r *http.Request) {
	assert.Equal(t, "application/json", r.Header.Get("Accept"))
	assert.Equal(t, apiKey, r.Header.Get(apiKeyHeader))
	assert.Equal(t, "me.vanyauhalin.osub v0.4.0", r.Header.Get("User-Agent"))
}

func TestDoes(t *testing.T) {
	client, mux, teardown := setup()
	defer teardown()

	mux.HandleFunc("/e", func (w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, mockString())
	})

	ctx := context.Background()
	e := mockStruct()

	u, err := client.NewURL("e", nil)
	require.NoError(t, err)

	r, err := client.NewRequest("GET", u, nil)
	require.NoError(t, err)

	a := &mockPP{}
	res, err := client.Do(ctx, r, &a)
	require.NoError(t, err)
	assert.Equal(t, http.StatusOK, res.StatusCode)
	assert.Equal(t, e, a)
}

func setup() (*Client, *http.ServeMux, func ()) {
	mux := http.NewServeMux()
	server := httptest.NewServer(mux)

	client := NewClient()
	client.BaseURL, _ = url.Parse(server.URL + "/")

	return client, mux, server.Close
}

func mockStruct() *mockPP {
	return &mockPP{
		A: Int(0),
		B: Int(1),
		C: String("a b c"),
	}
}

func mockString() string {
	return `{
	"a": 0,
	"b": 1,
	"c": "a b c"
}`
}
