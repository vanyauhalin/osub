package rest

import (
	"context"
	"net/http"
)

// https://opensubtitles.stoplight.io/docs/opensubtitles-api/69b286fc7506e-subtitle-formats

type InfosService service

type FormatsResponse struct {
	Data *FormatsData `json:"data,omitempty"`
}

type FormatsData struct {
	OutputFormats []*string `json:"output_formats,omitempty"`
}

// List subtitle formats recognized by the API.
//
// [OpenSubtitles Reference]
//
// [OpenSubtitles Reference]: https://opensubtitles.stoplight.io/docs/opensubtitles-api/69b286fc7506e-subtitle-formats
func (s *InfosService) Formats(ctx context.Context) (*FormatsResponse, *http.Response, error) {
	u, err := s.client.NewURL("infos/formats", nil)
	if err != nil {
		return nil, nil, err
	}

	req, err := s.client.NewRequest("GET", u, nil)
	if err != nil {
		return nil, nil, err
	}

	var r *FormatsResponse
	res, err := s.client.Do(ctx, req, &r)
	if err != nil {
		return nil, nil, err
	}

	return r, res, nil
}

type LanguagesResponse struct {
	Data []*Language `json:"data,omitempty"`
}

type Language struct {
	LanguageCode *string `json:"language_code,omitempty"`
	LanguageName *string `json:"language_name,omitempty"`
}

// Get the languages information.
//
// [OpenSubtitles Reference]
//
// [OpenSubtitles Reference]: https://opensubtitles.stoplight.io/docs/opensubtitles-api/1de776d20e873-languages
func (s *InfosService) Languages(ctx context.Context) (*LanguagesResponse, *http.Response, error) {
	u, err := s.client.NewURL("infos/languages", nil)
	if err != nil {
		return nil, nil, err
	}

	req, err := s.client.NewRequest("GET", u, nil)
	if err != nil {
		return nil, nil, err
	}

	var r *LanguagesResponse
	res, err := s.client.Do(ctx, req, &r)
	if err != nil {
		return nil, nil, err
	}

	return r, res, nil
}

type UserResponse struct {
	Data *User `json:"data,omitempty"`
}

type User struct {
	AllowedDownloads    *int    `json:"allowed_downloads,omitempty"`
	AllowedTranslations *int    `json:"allowed_translations,omitempty"`
	Level               *string `json:"level,omitempty"`
	UserID              *int    `json:"user_id,omitempty"`
	ExtInstalled        *bool   `json:"ext_installed,omitempty"`
	VIP                 *bool   `json:"vip,omitempty"`
	DownloadsCount      *int    `json:"downloads_count,omitempty"`
	RemainingDownloads  *int    `json:"remaining_downloads,omitempty"`
}

// Gather information about the user authenticated by a bearer token.
//
// [OpenSubtitles Reference]
//
// [OpenSubtitles Reference]: https://opensubtitles.stoplight.io/docs/opensubtitles-api/ea912bb244ef0-user-informations
func (s *InfosService) User(ctx context.Context) (*UserResponse, *http.Response, error) {
	u, err := s.client.NewURL("infos/user", nil)
	if err != nil {
		return nil, nil, err
	}

	req, err := s.client.NewRequest("GET", u, nil)
	if err != nil {
		return nil, nil, err
	}

	var r *UserResponse
	res, err := s.client.Do(ctx, req, &r)
	if err != nil {
		return nil, res, err
	}

	return r, res, nil
}
