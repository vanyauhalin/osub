package config

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/pelletier/go-toml/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestUnmarshalsConfig(t *testing.T) {
	e := stubStruct()
	a := &Config{}
	s := []byte(stubString())
	err := toml.Unmarshal(s, &a)
	require.NoError(t, err)
	assert.Equal(t, e, a)
}

func TestMarshalsConfig(t *testing.T) {
	e := stubString()
	c := stubStruct()
	a, err := toml.Marshal(c)
	require.NoError(t, err)
	assert.Equal(t, e, string(a))
}

func TestReadsConfig(t *testing.T) {
	e := stubStruct()
	s := []byte(stubString())

	d, err := os.MkdirTemp("", "osub")
	require.NoError(t, err)
	defer os.RemoveAll(d)
	f := filepath.Join(d, "config.toml")
	err = os.WriteFile(f, s, 0600)
	require.NoError(t, err)

	a, err := Read(f)
	require.NoError(t, err)
	assert.Equal(t, e, a)
}

func TestWritesConfig(t *testing.T) {
	e := stubString()
	c := stubStruct()

	d, err := os.MkdirTemp("", "osub")
	require.NoError(t, err)
	defer os.RemoveAll(d)
	f := filepath.Join(d, "config.toml")
	err = c.Write(f)
	require.NoError(t, err)

	a, err := os.ReadFile(f)
	require.NoError(t, err)
	assert.Equal(t, e, string(a))

	fi, err := os.Stat(f)
	require.NoError(t, err)
	assert.Equal(t, os.FileMode(0600), fi.Mode())
}

func stubStruct() *Config {
	return &Config{
		APIKey: "api-key",
		Username: "username",
		Password: "password",
	}
}

func stubString() string {
	return `api_key = "api-key"
username = "username"
password = "password"`
}
