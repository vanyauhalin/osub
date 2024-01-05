package downloader

import (
	"path/filepath"
	"vanyauhalin/osub/internal/basedir"
	"vanyauhalin/osub/internal/downloader"
)

func Download(url string, name string) (string, error) {
	d, err := basedir.DownloadDir()
	if err != nil {
		return "", err
	}

	f := filepath.Join(d, name)
	err = downloader.Download(url, f)
	if err != nil {
		return "", err
	}

	return f, err
}
