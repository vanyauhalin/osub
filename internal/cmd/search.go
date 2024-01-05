package cmd

import (
	"context"
	"vanyauhalin/osub/internal/cmd/state"
	"vanyauhalin/osub/internal/cmd/term"
	"vanyauhalin/osub/pkg/rest"
)

type Search struct {
	AITranslated      *string `arg:"--ai-translated"      help:"restrict search to AI-translated subtitles (default: include)"                placeholder:"<exclude|include>"`
	EpisodeNumber     *int    `arg:"--episode-number"     help:"search by TV Show episode number"                                             placeholder:"<int>"`
	ForeignPartsOnly  *string `arg:"--foreign-parts-only" help:"restrict search to Foreign Parts Only (FPO) subtitles (default: include)"     placeholder:"<exclude|include|only>"`
	HearingImpaired   *string `arg:"--hearing-impaired"   help:"restrict search to subtitles for the hearing impaired (default: include)"     placeholder:"<exclude|include|only>"`
	ID                *int    `arg:"--id"                 help:"search by feature ID from the features search results"                        placeholder:"<int>"`
	IMDBID            *int    `arg:"--imdb-id"            help:"search by feature IMDB ID"                                                    placeholder:"<int>"`
	Languages         *string `arg:"--languages"          help:"search on coma-separated list of subtag languages"                            placeholder:"<string>"`
	MachineTranslated *string `arg:"--machine-translated" help:"restrict search to machine-translated subtitles (default: exclude)"           placeholder:"<exclude|include>"`
	Moviehash         *string `arg:"--moviehash"          help:"search by feature hash"                                                       placeholder:"<string>"`
	MoviehashMatch    *string `arg:"--moviehash-match"    help:"restrict search to subtitles with feature hash match (default: include)"      placeholder:"<include|only>"`
	OrderBy           *string `arg:"--order-by"           help:"order of returned results by field"                                           placeholder:"<ai_translated|comment|download_count|foreign_parts_only|fps|from_trusted|hd|hearing_impaired|language|machine_translated|new_download_count|points|ratings|release|upload_date|votes>"`
	OrderDirection    *string `arg:"--order-direction"    help:"order of returned results by direction"                                       placeholder:"<asc|desc>"`
	Page              *int    `arg:"--page"               help:"search on the page"                                                           placeholder:"<int>"`
	ParentFeatureID   *int    `arg:"--parent-feature-id"  help:"search for the TV Show by parent feature ID from the features search results" placeholder:"<int>"`
	ParentIMDBID      *int    `arg:"--parent-imdb-id"     help:"search for the TV Show by parent IMDB ID"                                     placeholder:"<int>"`
	ParentTMDBID      *int    `arg:"--parent-tmdb-id"     help:"search for the TV Show by parent TMDB ID"                                     placeholder:"<int>"`
	Query             *string `arg:"--query"              help:"search by file name or string query"                                          placeholder:"<string>"`
	SeasonNumber      *int    `arg:"--season-number"      help:"search for the TV Show by season number"                                      placeholder:"<int>"`
	TMDBID            *int    `arg:"--tmdb-id"            help:"search by feature TMDB ID"                                                    placeholder:"<int>"`
	TrustedSources    *string `arg:"--trusted-sources"    help:"restrict search to trusted sources (default: include)"                        placeholder:"<include|only>"`
	Type              *string `arg:"--type"               help:"restrict search to feature type (default: all)"                               placeholder:"<all|episode|movie>"`
	UserID            *int    `arg:"--user-id"            help:"search for uploaded subtitles by user ID"                                     placeholder:"<int>"`
	Year              *int    `arg:"--year"               help:"search by year"                                                               placeholder:"<int>"`
}

func (cmd *Search) run() error {
	state, err := state.Read()
	if err != nil {
		return err
	}

	client := state.NewClient()
	ctx := context.Background()

	p := cmd.parameters()
	subtitles, _, err := client.Subtitles.Search(ctx, p)
	if err != nil {
		return err
	}

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
	c0 := h.AddHead("File ID")
	c1 := h.AddTruncHead("File Name")
	c2 := h.AddHead("Language")
	c3 := h.AddHead("Uploaded")
	c4 := h.AddHead("Downloads")

	for _, s := range subtitles.Data {
		for _, f := range s.Attributes.Files {
			b := table.AddRow()
			b.AddIntPointer(c0, f.FileID)
			b.AddStringPointer(c1, f.FileName)

			l := cmd.language(languages.Data, s.Attributes)
			b.AddStringPointer(c2, l)

			b.AddTimePointer(c3, s.Attributes.UploadDate)
			b.AddIntPointer(c4, s.Attributes.DownloadCount)
		}
	}

	err = table.Render()
	if err != nil {
		return err
	}

	return nil
}

func (cmd *Search) parameters() *rest.SubtitlesParameters {
	return &rest.SubtitlesParameters{
		AITranslated:      cmd.AITranslated,
		EpisodeNumber:     cmd.EpisodeNumber,
		ForeignPartsOnly:  cmd.ForeignPartsOnly,
		HearingImpaired:   cmd.HearingImpaired,
		ID:                cmd.ID,
		IMDBID:            cmd.IMDBID,
		Languages:         cmd.Languages,
		MachineTranslated: cmd.MachineTranslated,
		Moviehash:         cmd.Moviehash,
		MoviehashMatch:    cmd.MoviehashMatch,
		OrderBy:           cmd.OrderBy,
		OrderDirection:    cmd.OrderDirection,
		Page:              cmd.Page,
		ParentFeatureID:   cmd.ParentFeatureID,
		ParentIMDBID:      cmd.ParentIMDBID,
		ParentTMDBID:      cmd.ParentTMDBID,
		Query:             cmd.Query,
		SeasonNumber:      cmd.SeasonNumber,
		TMDBID:            cmd.TMDBID,
		TrustedSources:    cmd.TrustedSources,
		Type:              cmd.Type,
		UserID:            cmd.UserID,
		Year:              cmd.Year,
	}
}

func (cmd *Search) language(ls []*rest.Language, s *rest.Subtitles) *string {
	var lang *string
	for _, l := range ls {
		if l.LanguageCode == nil || s.Language == nil {
			continue
		}
		if *l.LanguageCode == *s.Language {
			lang = l.LanguageName
			break
		}
	}
	return lang
}
