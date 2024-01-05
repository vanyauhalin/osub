package cmd

import (
	"context"
	"sort"
	"vanyauhalin/osub/internal/cmd/state"
	"vanyauhalin/osub/internal/cmd/term"
)

type Languages struct {}

func (cmd *Languages) run() error {
	state, err := state.Read()
	if err != nil {
		return err
	}

	client := state.NewClient()
	ctx := context.Background()

	languages, _, err := client.Infos.Languages(ctx)
	if err != nil {
		return err
	}

	term := term.New()

	table, err := term.NewTable()
	if err != nil {
		return err
	}

	h := table.AddRow()
	c0 := h.AddHead("Name")
	c1 := h.AddHead("Subtag")

	sort.Slice(languages.Data, func (i int, j int) bool {
		a := *languages.Data[i]
		b := *languages.Data[j]
		return *a.LanguageName < *b.LanguageName
	})

	for _, l := range languages.Data {
		b := table.AddRow()
		b.AddStringPointer(c0, l.LanguageName)
		b.AddStringPointer(c1, l.LanguageCode)
	}

	err = table.Render()
	if err != nil {
		return err
	}

	return nil
}
