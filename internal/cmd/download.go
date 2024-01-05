package cmd

import (
	"context"
	"fmt"
	"vanyauhalin/osub/internal/cmd/downloader"
	"vanyauhalin/osub/internal/cmd/state"
	"vanyauhalin/osub/internal/cmd/term"
	"vanyauhalin/osub/pkg/rest"
)

type Download struct {
	FileID    *int    `arg:"--file-id"    help:"file ID from subtitles search results"      placeholder:"<int>"`
	FileName  *string `arg:"--file-name"  help:"desired subtitle file name to save on disk" placeholder:"<string>"`
	InFPS     *int    `arg:"--in-fps"     help:"input FPS for subtitles"                    placeholder:"<int>"`
	OutFPS    *int    `arg:"--out-fps"    help:"output FPS for subtitles"                   placeholder:"<int>"`
	SubFormat *string `arg:"--sub-format" help:"subtitles format from formats results"      placeholder:"<string>"`
	Timeshift *int    `arg:"--timeshift"  help:"timeshift for subtitles"                    placeholder:"<int>"`
}

func (cmd *Download) run() error {
	state, err := state.Read()
	if err != nil {
		return err
	}

	client := state.NewClient()
	ctx := context.Background()

	p := cmd.parameters()
	d, _, err := client.Download.Download(ctx, p)
	if err != nil {
		return err
	}

	term := term.New()

	table, err := term.NewTable()
	if err != nil {
		return err
	}

	h := table.AddRow()
	c0 := h.AddTruncHead("Remaining")
	c1 := h.AddHead("Reset Time")

	b := table.AddRow()
	b.AddIntPointer(c0, d.Remaining)
	b.AddStringPointer(c1, d.ResetTime)

	err = table.Render()
	if err != nil {
		return err
	}

	if d.Link == nil {
		return fmt.Errorf("todo")
	}
	if d.FileName == nil {
		return fmt.Errorf("todo")
	}

	f, err := downloader.Download(*d.Link, *d.FileName)
	if err != nil {
		return err
	}

	fmt.Println(f)

	return nil
}

func (cmd *Download) parameters() *rest.DownloadParameters {
	return &rest.DownloadParameters{
		FileID:    cmd.FileID,
		FileName:  cmd.FileName,
		InFPS:     cmd.InFPS,
		OutFPS:    cmd.OutFPS,
		SubFormat: cmd.SubFormat,
		Timeshift: cmd.Timeshift,
	}
}
