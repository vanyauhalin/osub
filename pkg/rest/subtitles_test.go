package rest

import (
	// "context"
	// "fmt"
	// "net/http"
	// "testing"

	// "github.com/stretchr/testify/assert"
	// "github.com/stretchr/testify/require"
)

// func TestSubtitlesService_Search(t *testing.T) {
// 	client, mux, teardown := setup()
// 	defer teardown()

// 	mux.HandleFunc("/subtitles", func(w http.ResponseWriter, r *http.Request) {
// 		assert.Equal(t, "GET", r.Method)
// 		assert.Equal(t, "/subtitles?ai_translated=include&episode_number=0&foreign_parts_only=include&hearing_impaired=include&id=0&imdb_id=0&languages=en%2Cru&machine_translated=exclude&moviehash=b4d8&moviehash_match=include&order_by=download_count&order_direction=asc&page=0&parent_feature_id=0&parent_imdb_id=0&parent_tmdb_id=0&query=friends&season_number=0&tmdb_id=0&trusted_sources=include&type=all&user_id=0&year=1994", r.RequestURI)
// 		fmt.Fprint(w, `{
// 			"data": [
// 				{
// 					"id": "9000",
// 					"attributes": {
// 						"language": "en",
// 						"download_count": 697844,
// 						"hearing_impaired": false,
// 						"hd": false,
// 						"fps": 23.976,
// 						"votes": 4,
// 						"ratings": 6,
// 						"from_trusted": true,
// 						"foreign_parts_only": false,
// 						"upload_date": "2009-09-04T19:36:00Z",
// 						"ai_translated": false,
// 						"machine_translated": false,
// 						"release": "Season 1 (Whole) DVDrip.XviD-SAiNTS",
// 						"uploader": {
// 							"uploader_id": 47823,
// 							"name": "scooby007",
// 							"rank": "translator"
// 						},
// 						"feature_details": {
// 							"feature_id": 38367,
// 							"feature_type": "Episode",
// 							"year": 1994,
// 							"title": "The Pilot",
// 							"movie_name": "Friends - S01E01  The Pilot",
// 							"imdb_id": 583459,
// 							"tmdb_id": 85987,
// 							"season_number": 1,
// 							"episode_number": 1,
// 							"parent_imdb_id": 108778,
// 							"parent_title": "Friends",
// 							"parent_tmdb_id": 1668,
// 							"parent_feature_id": 7251
// 						},
// 						"files": [
// 							{
// 								"file_id": 1923552,
// 								"file_name": "Friends.S01E01.DVDrip.XviD-SAiNTS_(ENGLISH)_DJJ.HOME.SAPO.PT"
// 							}
// 						]
// 					}
// 				}
// 			],
// 			"total_count": 1
// 		}`)
// 	})

// 	ctx := context.Background()
// 	p := &SubtitlesParameters{
// 		AITranslated: "include",
// 		EpisodeNumber: 0,
// 		ForeignPartsOnly: "include",
// 		HearingImpaired: "include",
// 		ID: 0,
// 		IMDBID: 0,
// 		Languages: "en,ru",
// 		MachineTranslated: "exclude",
// 		Moviehash: "b4d8",
// 		MoviehashMatch: "include",
// 		OrderBy: "download_count",
// 		OrderDirection: "asc",
// 		Page: 0,
// 		ParentFeatureID: 0,
// 		ParentIMDBID: 0,
// 		ParentTMDBID: 0,
// 		Query: "friends",
// 		SeasonNumber: 0,
// 		TMDBID: 0,
// 		TrustedSources: "include",
// 		Type: "all",
// 		UserID: 0,
// 		Year: 1994,
// 	}
// 	a, _, err := client.Subtitles.Search(ctx, p)
// 	require.NoError(t, err)

// 	e := &SubtitlesResponse{
// 		Data: []*SubtitlesEntity{
// 			{
// 				ID: String("9000"),
// 				Attributes: &Subtitles{
// 					Language: String("en"),
// 					DownloadCount: Int(697844),
// 					HearingImpaired: Bool(false),
// 					HD: Bool(false),
// 					FPS: Float32(23.976),
// 					Votes: Int(4),
// 					Ratings: Int(6),
// 					FromTrusted: Bool(true),
// 					ForeignPartsOnly: Bool(false),
// 					UploadDate: Time("2009-09-04T19:36:00Z"),
// 					AITranslated: Bool(false),
// 					MachineTranslated: Bool(false),
// 					Release: String("Season 1 (Whole) DVDrip.XviD-SAiNTS"),
// 					Uploader: &Uploader{
// 						UploaderID: Int(47823),
// 						Name: String("scooby007"),
// 						Rank: String("translator"),
// 					},
// 					FeatureDetails: &FeatureDetails{
// 						FeatureID: Int(38367),
// 						FeatureType: String("Episode"),
// 						Year: Int(1994),
// 						Title: String("The Pilot"),
// 						MovieName: String("Friends - S01E01  The Pilot"),
// 						IMDBID: Int(583459),
// 						TMDBID: Int(85987),
// 						SeasonNumber: Int(1),
// 						EpisodeNumber: Int(1),
// 						ParentIMDBID: Int(108778),
// 						ParentTitle: String("Friends"),
// 						ParentTMDBID: Int(1668),
// 						ParentFeatureID: Int(7251),
// 					},
// 					Files: []*File{
// 						{
// 							FileID: Int(1923552),
// 							FileName: String("Friends.S01E01.DVDrip.XviD-SAiNTS_(ENGLISH)_DJJ.HOME.SAPO.PT"),
// 						},
// 					},
// 				},
// 			},
// 		},
// 		TotalCount: Int(1),
// 	}
// 	assert.Equal(t, e, a)
// }
