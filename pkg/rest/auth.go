package rest

import (
	"context"
	"net/http"
)

type AuthService service

type Credentials struct {
	Username *string `json:"username,omitempty"`
	Password *string `json:"password,omitempty"`
}

type Login struct {
	User    *User     `json:"user,omitempty"`
	BaseURL *string   `json:"base_url,omitempty"`
	Token   *string   `json:"token,omitempty"`
	Status  *int      `json:"status,omitempty"`
}

// Create a token to authenticate a user.
//
// [OpenSubtitles Reference]
//
// [OpenSubtitles Reference]: https://opensubtitles.stoplight.io/docs/opensubtitles-api/73acf79accc0a-login
func (s *AuthService) Login(ctx context.Context, c *Credentials) (*Login, *http.Response, error) {
	u, err := s.client.NewURL("login", nil)
	if err != nil {
		return nil, nil, err
	}

	req, err := s.client.NewRequest("POST", u, c)
	if err != nil {
		return nil, nil, err
	}

	var l *Login
	res, err := s.client.Do(ctx, req, &l)
	if err != nil {
		return nil, nil, err
	}

	return l, res, nil
}

type Logout struct {
	Message *string `json:"message,omitempty"`
	Status  *int    `json:"status,omitempty"`
}

// Destroy a user token to end a session.
//
// [OpenSubtitles Reference]
//
// [OpenSubtitles Reference]: https://opensubtitles.stoplight.io/docs/opensubtitles-api/9fe4d6d078e50-logout
func (s *AuthService) Logout(ctx context.Context) (*Logout, *http.Response, error) {
	u, err := s.client.NewURL("logout", nil)
	if err != nil {
		return nil, nil, err
	}

	req, err := s.client.NewRequest("DELETE", u, nil)
	if err != nil {
		return nil, nil, err
	}

	var l *Logout
	res, err := s.client.Do(ctx, req, &l)
	if err != nil {
		return nil, nil, err
	}

	return l, res, nil
}
