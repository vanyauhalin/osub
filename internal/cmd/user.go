package cmd

import (
	"context"
	"vanyauhalin/osub/internal/cmd/state"
	"vanyauhalin/osub/internal/cmd/term"
)

type User struct {}

func (cmd *User) run() error {
	state, err := state.Read()
	if err != nil {
		return err
	}

	client := state.NewClient()
	ctx := context.Background()

	u, _, err := client.Infos.User(ctx)
	if err != nil {
		return err
	}

	term := term.New()

	table, err := term.NewTable()
	if err != nil {
		return err
	}

	h := table.AddRow()
	c0 := h.AddHead("User ID")
	c1 := h.AddTruncHead("Remaining Downloads")
	c2 := h.AddTruncHead("Allowed Downloads")
	c3 := h.AddHead("Level")

	b := table.AddRow()
	b.AddIntPointer(c0, u.Data.UserID)
	b.AddIntPointer(c1, u.Data.RemainingDownloads)
	b.AddIntPointer(c2, u.Data.AllowedDownloads)
	b.AddStringPointer(c3, u.Data.Level)

	err = table.Render()
	if err != nil {
		return err
	}

	return nil
}
