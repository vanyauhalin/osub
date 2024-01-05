package cmd

import (
	"fmt"
	"os"
	"vanyauhalin/osub/pkg/moviehash"
)

type Moviehash struct {
	Path string `arg:"positional" help:"the path to the file whose hash needs to be calculated" placeholder:"path"`
}

func (cmd *Moviehash) run() error {
	f, err := os.Open(cmd.Path)
	if err != nil {
		return err
	}

	h, err := moviehash.Sum(f)
	if err != nil {
		return err
	}

	fmt.Print(h)
	return nil
}
