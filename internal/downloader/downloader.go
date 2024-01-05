package downloader

import (
	"fmt"
	"io"
	"net/http"
	"os"
)

func Download(url string, to string) error {
	f, err := os.Create(to)
	if err != nil {
		return err
	}
	defer f.Close()

	res, err := http.Get(url)
	if err != nil {
		return err
	}
	defer res.Body.Close()

	if res.StatusCode != http.StatusOK {
		return fmt.Errorf("downloader: failed to download the file, status code %d", res.StatusCode)
	}

	_, err = io.Copy(f, res.Body)
	if err != nil {
		return err
	}

	return nil
}
