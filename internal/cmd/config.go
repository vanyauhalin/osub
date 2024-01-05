package cmd

import (
	"fmt"
	"vanyauhalin/osub/internal/cmd/config"
)

type Config struct {
	Get  *Get  `arg:"subcommand" help:"print the value of the given configuration key"`
	List *List `arg:"subcommand" help:"print a list of configuration keys and values"`
	Set  *Set  `arg:"subcommand" help:"update configuration with a value for the given key"`
}

func (cmd *Config) run() error {
	var err error
	switch {
	case cmd.Get != nil:
		err = cmd.Get.run()
	case cmd.List != nil:
		err = cmd.List.run()
	case cmd.Set != nil:
		err = cmd.Set.run()
	}
	return err
}

type Get struct {
	Key string `arg:"positional" help:"the configuration key" placeholder:"<string>"`
}

func (cmd *Get) run() error {
	c, err := config.Read()
	if err != nil {
		return err
	}

	v, err := c.Get(cmd.Key)
	if err != nil {
		return err
	}

	fmt.Println(v)
	return nil
}

type List struct {}

func (cmd *List) run() error {
	return nil
}

type Set struct {
	Key   string `arg:"positional" help:"the configuration key"              placeholder:"<string>"`
	Value string `arg:"positional" help:"the value of the configuration key" placeholder:"<string>"`
}

func (cmd *Set) run() error {
	c, err := config.Read()
	if err != nil {
		return err
	}

	err = c.Set(cmd.Value, cmd.Key)
	if err != nil {
		return err
	}

	err = c.Write()
	if err != nil {
		return err
	}

	return nil
}
