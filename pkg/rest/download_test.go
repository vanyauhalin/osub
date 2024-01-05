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

func TestUnmarshalsMarshalsDownloadParameters(t *testing.T) {
	a0 := &DownloadParameters{}
	b0 := "{}"
	tjson.TestUnmarshalsMarshalsJSON(t, a0, b0)

	a1 := &DownloadParameters{
		FileID: Int(1),
		FileName: String("custom"),
		ForceDownload: Bool(false),
		InFPS: Int(1),
		OutFPS: Int(1),
		SubFormat: String("srt"),
		Timeshift: Int(1),
	}
	b1 := `{
		"file_id": 1,
		"file_name": "custom",
		"force_download": false,
		"in_fps": 1,
		"out_fps": 1,
		"sub_format": "srt",
		"timeshift": 1
	}`
	tjson.TestUnmarshalsMarshalsJSON(t, a1, b1)
}

func TestUnmarshalsMarshalsDownload(t *testing.T) {
	a0 := &Download{}
	b0 := "{}"
	tjson.TestUnmarshalsMarshalsJSON(t, a0, b0)

	a1 := &Download{
		Link: String("https://www.opensubtitles.com/"),
		FileName: String("custom"),
		Requests: Int(1),
		Remaining: Int(1),
		Message: String("hi"),
		ResetTime: String("year"),
		ResetTimeUTC: Time("2009-01-06T00:00:00.000Z"),
	}
	b1 := `{
		"link": "https://www.opensubtitles.com/",
		"file_name": "custom",
		"requests": 1,
		"remaining": 1,
		"message": "hi",
		"reset_time": "year",
		"reset_time_utc": "2009-01-06T00:00:00.000Z"
	}`
	tjson.TestUnmarshalsMarshalsJSON(t, a1, b1)
}

func TestDownloadsUsingTheDownloadService(t *testing.T) {
	client, mux, teardown := setup()
	defer teardown()

	mux.HandleFunc("/download", func (w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, "POST", r.Method)
		assert.Equal(t, "/download", r.RequestURI)
		fmt.Fprint(w, `{
			"link": "https://www.opensubtitles.com/"
		}`)
	})

	ctx := context.Background()
	p := &DownloadParameters{
		FileID: Int(1),
		FileName: String("test"),
		InFPS: Int(1),
		OutFPS: Int(1),
		SubFormat: String("srt"),
		Timeshift: Int(1),
	}
	a, _, err := client.Download.Download(ctx, p)
	require.NoError(t, err)

	e := &Download{
		Link: String("https://www.opensubtitles.com/"),
	}
	assert.Equal(t, e, a)
}
