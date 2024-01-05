package downloader

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestDownloadsIfTheStatusIsOK(t *testing.T) {
	mux, url, close := setup()
	defer close()

	p := "/download"
	u := url + p

	mux.HandleFunc(p, func (w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, "hi")
	})

	d, err := os.MkdirTemp("", "osub")
	defer os.RemoveAll(d)
	require.NoError(t, err)
	to := filepath.Join(d, "hi.txt")

	err = Download(u, to)
	require.NoError(t, err)

	f, err := os.ReadFile(to)
	require.NoError(t, err)
	require.Equal(t, "hi", string(f))
}

func TestReturnsAnErrorIfTheStatusIsNotOK(t *testing.T) {
	mux, url, close := setup()
	defer close()

	p := "/download"
	u := url + p

	mux.HandleFunc(p, func (w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNotFound)
	})

	d, err := os.MkdirTemp("", "osub")
	defer os.RemoveAll(d)
	require.NoError(t, err)
	to := filepath.Join(d, "hi.txt")

	err = Download(u, to)
	require.Error(t, err)
}

func setup() (*http.ServeMux, string, func ()) {
	mux := http.NewServeMux()
	server := httptest.NewServer(mux)
	return mux, server.URL, server.Close
}
