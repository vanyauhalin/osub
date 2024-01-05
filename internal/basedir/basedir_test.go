package basedir

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestDetectsTheCustomConfigDir(t *testing.T) {
	v := "OSUB_CONFIG_DIR"
	d := "/to/config"
	os.Setenv(v, d)
	defer os.Unsetenv(v)

	a, err := ConfigDir()
	require.NoError(t, err)
	assert.Equal(t, d, a)
}

func TestDetectsTheXDGConfigDir(t *testing.T) {
	v := "XDG_CONFIG_HOME"
	d := "/to/config"
	os.Setenv(v, d)
	defer os.Unsetenv(v)

	e := filepath.Join(d, "osub")
	a, err := ConfigDir()
	require.NoError(t, err)
	assert.Equal(t, e, a)
}

func TestReturnsTheXDGConfigDirIfTheCustomDirIsNotSet(t *testing.T) {
	v := "OSUB_CONFIG_DIR"
	os.Unsetenv(v)

	v1 := "XDG_CONFIG_HOME"
	d1 := "/to/config"
	os.Setenv(v1, d1)
	defer os.Unsetenv(v1)

	e := filepath.Join(d1, "osub")
	a, err := ConfigDir()
	require.NoError(t, err)
	assert.Equal(t, e, a)
}

func TestReturnsTheXDGConfigDirIfTheCustomDirIsEmpty(t *testing.T) {
	v0 := "OSUB_CONFIG_DIR"
	d0 := ""
	os.Setenv(v0, d0)
	defer os.Unsetenv(v0)

	v1 := "XDG_CONFIG_HOME"
	d1 := "/to/config"
	os.Setenv(v1, d1)
	defer os.Unsetenv(v1)

	e := filepath.Join(d1, "osub")
	a, err := ConfigDir()
	require.NoError(t, err)
	assert.Equal(t, e, a)
}

func TestDetectsTheCustomDownloadDir(t *testing.T) {
	v := "OSUB_DOWNLOAD_DIR"
	d := "/to/downloads"
	os.Setenv(v, d)
	defer os.Unsetenv(v)

	a, err := DownloadDir()
	require.NoError(t, err)
	assert.Equal(t, d, a)
}

func TestDetectsTheXDGDownloadDir(t *testing.T) {
	v := "XDG_DOWNLOAD_DIR"
	d := "/to/downloads"
	os.Setenv(v, d)
	defer os.Unsetenv(v)

	a, err := DownloadDir()
	require.NoError(t, err)
	assert.Equal(t, d, a)
}

func TestReturnsTheXDGDownloadDirIfTheCustomDirIsNotSet(t *testing.T) {
	v := "OSUB_DOWNLOAD_DIR"
	os.Unsetenv(v)

	v1 := "XDG_DOWNLOAD_DIR"
	d1 := "/to/downloads"
	os.Setenv(v1, d1)
	defer os.Unsetenv(v1)

	a, err := DownloadDir()
	require.NoError(t, err)
	assert.Equal(t, d1, a)
}

func TestReturnsTheXDGDownloadDirIfTheCustomDirIsEmpty(t *testing.T) {
	v0 := "OSUB_DOWNLOAD_DIR"
	d0 := ""
	os.Setenv(v0, d0)
	defer os.Unsetenv(v0)

	v1 := "XDG_DOWNLOAD_DIR"
	d1 := "/to/downloads"
	os.Setenv(v1, d1)
	defer os.Unsetenv(v1)

	a, err := DownloadDir()
	require.NoError(t, err)
	assert.Equal(t, d1, a)
}

func TestDetectsTheCustomStateDir(t *testing.T) {
	v := "OSUB_STATE_DIR"
	d := "/to/state"
	os.Setenv(v, d)
	defer os.Unsetenv(v)

	a, err := StateDir()
	require.NoError(t, err)
	assert.Equal(t, d, a)
}

func TestDetectsTheXDGStateDir(t *testing.T) {
	v := "XDG_STATE_HOME"
	d := "/to/state"
	os.Setenv(v, d)
	defer os.Unsetenv(v)

	e := filepath.Join(d, "osub")
	a, err := StateDir()
	require.NoError(t, err)
	assert.Equal(t, e, a)
}

func TestReturnsTheXDGStateDirIfTheCustomDirIsNotSet(t *testing.T) {
	v := "OSUB_STATE_DIR"
	os.Unsetenv(v)

	v1 := "XDG_STATE_HOME"
	d1 := "/to/state"
	os.Setenv(v1, d1)
	defer os.Unsetenv(v1)

	e := filepath.Join(d1, "osub")
	a, err := StateDir()
	require.NoError(t, err)
	assert.Equal(t, e, a)
}

func TestReturnsTheXDGStateDirIfTheCustomDirIsEmpty(t *testing.T) {
	v0 := "OSUB_STATE_DIR"
	d0 := ""
	os.Setenv(v0, d0)
	defer os.Unsetenv(v0)

	v1 := "XDG_STATE_HOME"
	d1 := "/to/state"
	os.Setenv(v1, d1)
	defer os.Unsetenv(v1)

	e := filepath.Join(d1, "osub")
	a, err := StateDir()
	require.NoError(t, err)
	assert.Equal(t, e, a)
}
