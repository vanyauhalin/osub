package cmd

import (
	"context"
	"fmt"
	"vanyauhalin/osub/internal/cmd/config"
	"vanyauhalin/osub/internal/cmd/state"
	"vanyauhalin/osub/pkg/rest"
)

type Auth struct {
	Login   *Login   `arg:"subcommand" help:"login by generating an authentication token"`
	Logout  *Logout  `arg:"subcommand" help:"logout by destroying the authentication token"`
	Refresh *Refresh `arg:"subcommand" help:"refresh the authentication token"`
	Status  *Status  `arg:"subcommand" help:"print the current authentication status"`
}

func (cmd *Auth) run() error {
	var err error
	switch {
	case cmd.Login != nil:
		err = cmd.Login.run()
	case cmd.Logout != nil:
		err = cmd.Logout.run()
	case cmd.Refresh != nil:
		err = cmd.Refresh.run()
	case cmd.Status != nil:
		err = cmd.Status.run()
	}
	return err
}

type Login struct {
	Username string `arg:"positional" help:"the account username" placeholder:"<string>"`
	Password string `arg:"positional" help:"the account password" placeholder:"<string>"`
}

func (cmd *Login) run() error {
	config, err := config.Read()
	if err != nil {
		return err
	}

	client := rest.NewClient()
	ctx := context.Background()

	cr := &rest.Credentials{}

	if cmd.Username != "" {
		cr.Username = cmd.Username
	} else if config.Username != "" {
		cr.Username = config.Username
	} else {
		return fmt.Errorf("username is required")
	}

	if cmd.Password != "" {
		cr.Password = cmd.Password
	} else if config.Password != "" {
		cr.Password = config.Password
	} else {
		return fmt.Errorf("password is required")
	}

	l, _, err := client.Auth.Login(ctx, cr)
	if err != nil {
		return err
	}

	state, err := state.New()
	if err != nil {
		return err
	}

	state.BaseURL = *l.BaseURL
	state.Token = *l.Token

	// err = state.Validate()
	// if err != nil {
	// 	return err
	// }

	err = state.Write()
	if err != nil {
		return err
	}

	return nil
}

type Logout struct {}

func (cmd *Logout) run() error {
	state, err := state.Read()
	if err != nil {
		return err
	}

	client := state.NewClient()
	ctx := context.Background()

	_, _, err = client.Auth.Logout(ctx)
	if err != nil {
		// l.Message
		return err
	}

	err = state.Remove()
	if err != nil {
		return err
	}

	return nil
}

type Refresh struct {}

func (cmd *Refresh) run() error {
	config, err := config.Read()
	if err != nil {
		return err
	}

	client := rest.NewClient()
	ctx := context.Background()

	cr := &rest.Credentials{}

	if config.Username != "" {
		cr.Username = config.Username
	} else {
		return fmt.Errorf("username is required")
	}

	if config.Password != "" {
		cr.Password = config.Password
	} else {
		return fmt.Errorf("password is required")
	}

	l, _, err := client.Auth.Login(ctx, cr)
	if err != nil {
		return err
	}

	state, err := state.New()
	if err != nil {
		return err
	}

	state.BaseURL = *l.BaseURL
	state.Token = *l.Token

	// err = state.Validate()
	// if err != nil {
	// 	return err
	// }

	err = state.Write()
	if err != nil {
		return err
	}

	return nil
}

type Status struct {}

func (cmd *Status) run() error {
	state, err := state.Read()
	if err != nil {
		return err
	}

	client := state.NewClient()
	ctx := context.Background()

	_, res, err := client.Infos.User(ctx)
	if err != nil {
		return err
	}

	s := res.Status
	if res.StatusCode == 200 {
		s += " " + state.BaseURL
	}

	fmt.Print(s)
	return nil
}
