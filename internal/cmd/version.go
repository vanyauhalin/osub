package cmd

import (
	"fmt"
	"vanyauhalin/osub/internal/meta"
)

type Version struct {}

func (cmd *Version) run() {
	fmt.Printf("%s %s\n", meta.Name, meta.Version)
}
