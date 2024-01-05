package rest

import (
	"context"
	"fmt"
	"net/http"
	"testing"
	"vanyauhalin/osub/internal/tjson"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestUnmarshalsMarshalsFeaturesParameters(t *testing.T) {
	a0 := &FeaturesParameters{}
	b0 := "{}"
	tjson.TestUnmarshalsMarshalsJSON(t, a0, b0)

	a1 := &FeaturesParameters{
		FeatureID: Int(1),
		IMDBID: Int(1),
		Query: String("hi"),
		TMDBID: Int(1),
		Type: String("all"),
		Year: Int(2009),
	}
	b1 := `{
		"feature_id": 1,
		"imdb_id": 1,
		"query": "hi",
		"tmdb_id": 1,
		"type": "all",
		"year": 2009
	}`
	tjson.TestUnmarshalsMarshalsJSON(t, a1, b1)
}

func TestUnmarshalsMarshalsFeatures(t *testing.T) {
	a0 := &Features{}
	b0 := "{}"
	tjson.TestUnmarshalsMarshalsJSON(t, a0, b0)

	a1 := &FeaturesResponse{
		Data: []*FeaturesEntity{
			{
				ID: String("1"),
				Attributes: &Features{
					EpisodeNumber: Int(1),
					FeatureType: String("movie"),
					IMDBID: Int(1),
					ParentIMDBID: Int(1),
					ParentTitle: String("hi"),
					SeasonNumber: Int(1),
					Title: String("hola"),
					TMDBID: Int(1),
					Year: String("2009"),
				},
			},
		},
	}
	b1 := `{
		"data": [
			{
				"id": "1",
				"attributes": {
					"episode_number": 1,
					"feature_type": "movie",
					"imdb_id": 1,
					"parent_imdb_id": 1,
					"parent_title": "hi",
					"season_number": 1,
					"title": "hola",
					"tmdb_id": 1,
					"year": "2009"
				}
			}
		]
	}`
	tjson.TestUnmarshalsMarshalsJSON(t, a1, b1)
}

func TestSearchesUsingTheFeaturesService(t *testing.T) {
	client, mux, teardown := setup()
	defer teardown()

	mux.HandleFunc("/features", func (w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, "GET", r.Method)
		assert.Equal(t, "/features?feature_id=0&imdb_id=0&query=friends&tmdb_id=0&type=all&year=1994", r.RequestURI)
		fmt.Fprint(w, `{
			"data": [
				{
					"id": "126826"
				}
			]
		}`)
	})

	ctx := context.Background()
	p := &FeaturesParameters{
		FeatureID: Int(0),
		IMDBID: Int(0),
		Query: String("friends"),
		TMDBID: Int(0),
		Type: String("all"),
		Year: Int(1994),
	}
	a, _, err := client.Features.Search(ctx, p)
	require.NoError(t, err)

	e := &FeaturesResponse{
		Data: []*FeaturesEntity{
			{
				ID: String("126826"),
			},
		},
	}
	assert.Equal(t, e, a)
}
