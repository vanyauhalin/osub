package config

import (
	"fmt"
	"os"
	"sync"

	"github.com/pelletier/go-toml/v2"
)

type Config struct {
	APIKey   string `toml:"api_key,omitempty"`
	Username string `toml:"username,omitempty"`
	Password string `toml:"password,omitempty"`

	mu sync.Mutex
}

func New() *Config {
	return &Config{}
}

func Read(file string) (*Config, error) {
	c := New()

	t, err := os.ReadFile(file)
	if err != nil {
		return nil, err
	}

	err = toml.Unmarshal(t, &c)
	if err != nil {
		return nil, err
	}

	return c, nil
}

func (c *Config) Write(file string) error {
	c.mu.Lock()
	defer c.mu.Unlock()

	t, err := toml.Marshal(c)
	if err != nil {
		return err
	}

	err = os.WriteFile(file, t, 0600)
	if err != nil {
		return err
	}

	return nil
}

func (c *Config) Get(k string) (string, error) {
	switch k {
	case "api_key":
		return c.APIKey, nil
	case "username":
		return c.Username, nil
	case "password":
		return c.Password, nil
	}
	return "", fmt.Errorf("unknown key: %s", k)
}

func (c *Config) Set(v string, k string) error {
	switch k {
	case "api_key":
		c.APIKey = v
		return nil
	case "username":
		c.Username = v
		return nil
	case "password":
		c.Password = v
		return nil
	}
	return fmt.Errorf("unknown key: %s", k)
}
