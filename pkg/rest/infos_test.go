package rest

import (
	"context"
	"fmt"
	"net/http"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestInfosService_Formats(t *testing.T) {
	client, mux, teardown := setup()
	defer teardown()

	mux.HandleFunc("/infos/formats", func (w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, "GET", r.Method)
		fmt.Fprint(w, `{
			"data": {
				"output_formats": ["srt"]
			},
			"status": 200
		}`)
	})

	ctx := context.Background()
	a, _, err := client.Infos.Formats(ctx)
	require.NoError(t, err)

	e := &FormatsResponse{
		Data: &FormatsData{
			OutputFormats: []*string{String("srt")},
		},
	}
	assert.Equal(t, e, a)
}

func TestInfosService_Languages(t *testing.T) {
	client, mux, teardown := setup()
	defer teardown()

	mux.HandleFunc("/infos/languages", func (w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, "GET", r.Method)
		fmt.Fprint(w, `{
			"data": [{
				"language_code": "en",
				"language_name": "English"
			}],
			"status": 200
		}`)
	})

	ctx := context.Background()
	a, _, err := client.Infos.Languages(ctx)
	require.NoError(t, err)

	e := &LanguagesResponse{
		Data: []*Language{
			{
				LanguageCode: String("en"),
				LanguageName: String("English"),
			},
		},
	}
	assert.Equal(t, e, a)
}

func TestInfosService_User(t *testing.T) {
	client, mux, teardown := setup()
	defer teardown()

	mux.HandleFunc("/infos/user", func (w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, "GET", r.Method)
		fmt.Fprint(w, `{
			"data": {
				"allowed_downloads": 100,
				"level": "Sub leecher",
				"user_id": 66,
				"ext_installed": false,
				"vip": false,
				"downloads_count": 1,
				"remaining_downloads": 99
			},
			"status": 200
		}`)
	})

	ctx := context.Background()
	a, _, err := client.Infos.User(ctx)
	require.NoError(t, err)

	e := &UserResponse{
		Data: &User{
			AllowedDownloads: Int(100),
			Level: String("Sub leecher"),
			UserID: Int(66),
			ExtInstalled: Bool(false),
			VIP: Bool(false),
			DownloadsCount: Int(1),
			RemainingDownloads: Int(99),
		},
	}
	assert.Equal(t, e, a)
}
