package rest

import (
	"context"
	"net/http"
	"time"
)

type SubtitlesService service

type SubtitlesParameters struct {
	AITranslated      *string `url:"ai_translated,omitempty"`
	EpisodeNumber     *int    `url:"episode_number,omitempty"`
	ForeignPartsOnly  *string `url:"foreign_parts_only,omitempty"`
	HearingImpaired   *string `url:"hearing_impaired,omitempty"`
	ID                *int    `url:"id,omitempty"`
	IMDBID            *int    `url:"imdb_id,omitempty"`
	Languages         *string `url:"languages,omitempty"`
	MachineTranslated *string `url:"machine_translated,omitempty"`
	Moviehash         *string `url:"moviehash,omitempty"`
	MoviehashMatch    *string `url:"moviehash_match,omitempty"`
	OrderBy           *string `url:"order_by,omitempty"`
	OrderDirection    *string `url:"order_direction,omitempty"`
	Page              *int    `url:"page,omitempty"`
	ParentFeatureID   *int    `url:"parent_feature_id,omitempty"`
	ParentIMDBID      *int    `url:"parent_imdb_id,omitempty"`
	ParentTMDBID      *int    `url:"parent_tmdb_id,omitempty"`
	Query             *string `url:"query,omitempty"`
	SeasonNumber      *int    `url:"season_number,omitempty"`
	TMDBID            *int    `url:"tmdb_id,omitempty"`
	TrustedSources    *string `url:"trusted_sources,omitempty"`
	Type              *string `url:"type,omitempty"`
	UserID            *int    `url:"user_id,omitempty"`
	Year              *int    `url:"year,omitempty"`
}

type SubtitlesResponse struct {
	Data       []*SubtitlesEntity `json:"data,omitempty"`
	TotalCount *int               `json:"total_count,omitempty"`
}

type SubtitlesEntity struct {
	ID         *string    `json:"id,omitempty"`
	Attributes *Subtitles `json:"attributes,omitempty"`
}

type Subtitles struct {
	AITranslated      *bool           `json:"ai_translated,omitempty"`
	DownloadCount     *int            `json:"download_count,omitempty"`
	FeatureDetails    *FeatureDetails `json:"feature_details,omitempty"`
	Files             []*File         `json:"files,omitempty"`
	ForeignPartsOnly  *bool           `json:"foreign_parts_only,omitempty"`
	FPS               *float32        `json:"fps,omitempty"`
	FromTrusted       *bool           `json:"from_trusted,omitempty"`
	HD                *bool           `json:"hd,omitempty"`
	HearingImpaired   *bool           `json:"hearing_impaired,omitempty"`
	Language          *string         `json:"language,omitempty"`
	MachineTranslated *bool           `json:"machine_translated,omitempty"`
	Ratings           *float32        `json:"ratings,omitempty"`
	Release           *string         `json:"release,omitempty"`
	UploadDate        *time.Time      `json:"upload_date,omitempty"`
	Uploader          *Uploader       `json:"uploader,omitempty"`
	Votes             *int            `json:"votes,omitempty"`
}

type FeatureDetails struct {
	EpisodeNumber   *int    `json:"episode_number,omitempty"`
	FeatureID       *int    `json:"feature_id,omitempty"`
	FeatureType     *string `json:"feature_type,omitempty"`
	IMDBID          *int    `json:"imdb_id,omitempty"`
	MovieName       *string `json:"movie_name,omitempty"`
	ParentFeatureID *int    `json:"parent_feature_id,omitempty"`
	ParentIMDBID    *int    `json:"parent_imdb_id,omitempty"`
	ParentTitle     *string `json:"parent_title,omitempty"`
	ParentTMDBID    *int    `json:"parent_tmdb_id,omitempty"`
	SeasonNumber    *int    `json:"season_number,omitempty"`
	Title           *string `json:"title,omitempty"`
	TMDBID          *int    `json:"tmdb_id,omitempty"`
	Year            *int    `json:"year,omitempty"`
}

type File struct {
	FileID   *int    `json:"file_id,omitempty"`
	FileName *string `json:"file_name,omitempty"`
}

type Uploader struct {
	Name       *string `json:"name,omitempty"`
	Rank       *string `json:"rank,omitempty"`
	UploaderID *int    `json:"uploader_id,omitempty"`
}

func (s *SubtitlesService) Search(ctx context.Context, p *SubtitlesParameters) (*SubtitlesResponse, *http.Response, error) {
	u, err := s.client.NewURL("subtitles", &p)
	if err != nil {
		return nil, nil, err
	}

	req, err := s.client.NewRequest("GET", u, nil)
	if err != nil {
		return nil, nil, err
	}

	var r *SubtitlesResponse
	res, err := s.client.Do(ctx, req, &r)
	if err != nil {
		return nil, res, err
	}

	return r, res, nil
}
