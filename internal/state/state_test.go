package state

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestUnmarshalsState(t *testing.T) {
	e := stubStruct()
	a := &State{}
	s := []byte(stubString())
	err := json.Unmarshal(s, &a)
	require.NoError(t, err)
	assert.Equal(t, e, a)
}

func TestMarshalsState(t *testing.T) {
	e := stubString()
	c := stubStruct()
	a, err := json.MarshalIndent(c, "", "  ")
	require.NoError(t, err)
	assert.Equal(t, e, string(a))
}

func TestReadsState(t *testing.T) {
	e := stubStruct()
	s := []byte(stubString())

	d, err := os.MkdirTemp("", "osub")
	require.NoError(t, err)
	defer os.RemoveAll(d)
	f := filepath.Join(d, "state.json")
	err = os.WriteFile(f, s, 0600)
	require.NoError(t, err)

	a, err := Read(f)
	require.NoError(t, err)
	assert.Equal(t, e, a)
}

func TestWritesState(t *testing.T) {
	e := stubString()
	c := stubStruct()

	d, err := os.MkdirTemp("", "osub")
	require.NoError(t, err)
	defer os.RemoveAll(d)
	f := filepath.Join(d, "state.json")
	err = c.Write(f)
	require.NoError(t, err)

	a, err := os.ReadFile(f)
	require.NoError(t, err)
	assert.Equal(t, e, string(a))

	fi, err := os.Stat(f)
	require.NoError(t, err)
	assert.Equal(t, os.FileMode(0600), fi.Mode())
}

func stubStruct() *State {
	return &State{
		BaseURL: "http://localhost/",
		Token: "zojwa9-zeCgov-farcep",
	}
}

func stubString() string {
	return `{
  "base_url": "http://localhost/",
  "token": "zojwa9-zeCgov-farcep"
}`
}
