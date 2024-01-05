package config

import (
	"os"
	"path/filepath"
	"vanyauhalin/osub/internal/basedir"
	"vanyauhalin/osub/internal/config"
)

type Config struct {
	*config.Config
	file string
}

func Read() (*Config, error) {
	f, err := file()
	if err != nil {
		return nil, err
	}

	config, err := read(f)
	if err != nil {
		return nil, err
	}

	c := &Config{
		Config: config,
		file: f,
	}

	return c, nil
}

func file() (string, error) {
	d, err := basedir.ConfigDir()
	if err != nil {
		return "", err
	}
	f := filepath.Join(d, "config.toml")
	return f, nil
}

func read(f string) (*config.Config, error) {
	c, err := config.Read(f)
	if err != nil {
		if os.IsNotExist(err) {
			c = config.New()
			return c, nil
		}
		return nil, err
	}
	return c, nil
}

func (c *Config) Write() error {
	return c.Config.Write(c.file)
}
