package main

import (
	"vanyauhalin/osub/internal/cmd"

	arg "github.com/alexflint/go-arg"
)

func main() {
	var osub cmd.Osub
	arg.MustParse(&osub)
	err := osub.Run()
	if err != nil {
		panic(err)
	}
}
