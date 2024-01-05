package basedir

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestReturnsAPlatformSpecificConfigDirIfTheUserDirIsNotSet(t *testing.T) {
	v0 := "OSUB_CONFIG_DIR"
	os.Unsetenv(v0)

	v1 := "XDG_CONFIG_HOME"
	os.Unsetenv(v1)

	h := os.Getenv("HOME")
	e := filepath.Join(h, "Library/Application Support", "me.vanyauhalin.osub")
	a, err := ConfigDir()
	require.NoError(t, err)
	assert.Equal(t, e, a)
}

func TestReturnsAPlatformSpecificConfigDirIfTheUserDirIsEmpty(t *testing.T) {
	v0 := "OSUB_CONFIG_DIR"
	d0 := ""
	os.Setenv(v0, d0)
	defer os.Unsetenv(v0)

	v1 := "XDG_CONFIG_HOME"
	d1 := ""
	os.Setenv(v1, d1)
	defer os.Unsetenv(v1)

	h := os.Getenv("HOME")
	e := filepath.Join(h, "Library/Application Support", "me.vanyauhalin.osub")
	a, err := ConfigDir()
	require.NoError(t, err)
	assert.Equal(t, e, a)
}
