package cmd

import (
	"context"
	"sort"
	"vanyauhalin/osub/internal/cmd/state"
	"vanyauhalin/osub/internal/cmd/term"
)

type Formats struct {}

func (cmd *Formats) run() error {
	state, err := state.Read()
	if err != nil {
		return err
	}

	client := state.NewClient()
	ctx := context.Background()

	formats, _, err := client.Infos.Formats(ctx)
	if err != nil {
		return err
	}

	term := term.New()

	table, err := term.NewTable()
	if err != nil {
		return err
	}

	h := table.AddRow()
	c0 := h.AddHead("Format")

	sort.Slice(formats.Data.OutputFormats, func (i int, j int) bool {
		a := *formats.Data.OutputFormats[i]
		b := *formats.Data.OutputFormats[j]
		return a < b
	})

	for _, f := range formats.Data.OutputFormats {
		b := table.AddRow()
		b.AddStringPointer(c0, f)
	}

	err = table.Render()
	if err != nil {
		return err
	}

	return nil
}
