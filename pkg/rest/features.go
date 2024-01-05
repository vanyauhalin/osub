package rest

import (
	"context"
	"net/http"
)

type FeaturesService service

type FeaturesParameters struct {
	FeatureID *int    `url:"feature_id,omitempty"`
	IMDBID    *int    `url:"imdb_id,omitempty"`
	Query     *string `url:"query,omitempty"`
	TMDBID    *int    `url:"tmdb_id,omitempty"`
	Type      *string `url:"type,omitempty"`
	Year      *int    `url:"year,omitempty"`
}

type FeaturesResponse struct {
	Data []*FeaturesEntity `json:"data,omitempty"`
}

type FeaturesEntity struct {
	ID         *string   `json:"id,omitempty"`
	Attributes *Features `json:"attributes,omitempty"`
}

type Features struct {
	EpisodeNumber *int    `json:"episode_number,omitempty"`
	FeatureType   *string `json:"feature_type,omitempty"`
	IMDBID        *int    `json:"imdb_id,omitempty"`
	ParentIMDBID  *int    `json:"parent_imdb_id,omitempty"`
	ParentTitle   *string `json:"parent_title,omitempty"`
	SeasonNumber  *int    `json:"season_number,omitempty"`
	Title         *string `json:"title,omitempty"`
	TMDBID        *int    `json:"tmdb_id,omitempty"`
	Year          *string `json:"year,omitempty"`
}

func (s *FeaturesService) Search(ctx context.Context, p *FeaturesParameters) (*FeaturesResponse, *http.Response, error) {
	u, err := s.client.NewURL("features", &p)
	if err != nil {
		return nil, nil, err
	}

	req, err := s.client.NewRequest("GET", u, nil)
	if err != nil {
		return nil, nil, err
	}

	var r *FeaturesResponse
	res, err := s.client.Do(ctx, req, &r)
	if err != nil {
		return nil, res, err
	}

	return r, res, nil
}
