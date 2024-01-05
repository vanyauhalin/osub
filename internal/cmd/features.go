package cmd

import (
	"context"
	"fmt"
	"vanyauhalin/osub/internal/cmd/state"
	"vanyauhalin/osub/internal/cmd/term"
	"vanyauhalin/osub/pkg/rest"
)

type Features struct {
	FeatureID *int    `arg:"--feature-id" help:"search by feature ID"                placeholder:"<int>"`
	IMDBID    *int    `arg:"--imdb-id"    help:"search by feature IMDB ID"           placeholder:"<string>"`
	Query     *string `arg:"--query"      help:"search by file name or string query" placeholder:"<string>"`
	TMDBID    *int    `arg:"--tmdb-id"    help:"search by feature TMDB ID"           placeholder:"<string>"`
	Type      *string `arg:"--type"       help:"search on feature type"              placeholder:"<episode|movie|tvshow>"`
	Year      *int    `arg:"--year"       help:"search by year"                      placeholder:"<int>"`
}

func (cmd *Features) run() error {
	state, err := state.Read()
	if err != nil {
		return err
	}

	client := state.NewClient()
	ctx := context.Background()

	p := cmd.parameters()
	features, _, err := client.Features.Search(ctx, p)
	if err != nil {
		return err
	}

	term := term.New()

	table, err := term.NewTable()
	if err != nil {
		return err
	}

	h := table.AddRow()
	c0 := h.AddHead("Feature ID")
	c1 := h.AddTruncHead("Title")
	c2 := h.AddTruncHead("Feature Type")
	c3 := h.AddHead("IMDB ID")
	c4 := h.AddHead("Index")
	c5 := h.AddTruncHead("Parent Title")

	for _, f := range features.Data {
		b := table.AddRow()
		b.AddStringPointer(c0, f.ID)
		b.AddStringPointer(c1, f.Attributes.Title)
		b.AddStringPointer(c2, f.Attributes.FeatureType)
		b.AddIntPointer(c3, f.Attributes.IMDBID)

		i := cmd.index(f.Attributes)
		b.AddStringPointer(c4, i)

		b.AddStringPointer(c5, f.Attributes.ParentTitle)
	}

	err = table.Render()
	if err != nil {
		return err
	}

	return nil
}

func (cmd *Features) parameters() *rest.FeaturesParameters {
	return &rest.FeaturesParameters{
		FeatureID: cmd.FeatureID,
		IMDBID:    cmd.IMDBID,
		Query:     cmd.Query,
		TMDBID:    cmd.TMDBID,
		Type:      cmd.Type,
		Year:      cmd.Year,
	}
}

func (cmd *Features) index(f *rest.Features) *string {
	var i *string
	if f.SeasonNumber != nil {
		s := fmt.Sprintf("S%d", f.SeasonNumber)
		i = &s
	}
	if f.EpisodeNumber != nil {
		e := fmt.Sprintf("E%d", f.EpisodeNumber)
		if i != nil {
			*i = *i + e
		} else {
			i = &e
		}
	}
	return i
}
