package cmd

// core:
//   download
//   search
//
// management:
//   auth
//   config
//
// additional:
//   features
//   formats
//   languages
//   user
//
// utils:
//   moviehash
//   version

type Osub struct {
	Auth      *Auth      `arg:"subcommand" help:"manage authentication"`
	Config    *Config    `arg:"subcommand" help:"manage configuration"`
	Download  *Download  `arg:"subcommand" help:"download subtitles"`
	Features  *Features  `arg:"subcommand" help:"search features"`
	Formats   *Formats   `arg:"subcommand" help:"print a list of formats for subtitles"`
	Languages *Languages `arg:"subcommand" help:"print a list of languages for subtitles"`
	User      *User      `arg:"subcommand" help:"print the current user"`
	Moviehash *Moviehash `arg:"subcommand" help:"calculate the hash of the file"`
	Search    *Search    `arg:"subcommand" help:"search for subtitles"`
	Version   *Version   `arg:"subcommand" help:"print the current osub version"`
}

func (cmd *Osub) Run() error {
	var err error
	switch {
	case cmd.Auth != nil:
		err = cmd.Auth.run()
	case cmd.Config != nil:
		err = cmd.Config.run()
	case cmd.Download != nil:
		err = cmd.Download.run()
	case cmd.Features != nil:
		err = cmd.Features.run()
	case cmd.Formats != nil:
		err = cmd.Formats.run()
	case cmd.Languages != nil:
		err = cmd.Languages.run()
	case cmd.User != nil:
		err = cmd.User.run()
	case cmd.Moviehash != nil:
		err = cmd.Moviehash.run()
	case cmd.Search != nil:
		err = cmd.Search.run()
	case cmd.Version != nil:
		cmd.Version.run()
	}
	return err
}
