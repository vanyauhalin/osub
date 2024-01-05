package state

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"vanyauhalin/osub/internal/basedir"
	"vanyauhalin/osub/pkg/rest"
	"vanyauhalin/osub/internal/state"
)

type State struct {
	*state.State
	file string
}

func New() (*State, error) {
	f, err := file()
	if err != nil {
		return nil, err
	}
	s := &State{
		file: f,
	}
	return s, nil
}

func Read() (*State, error) {
	f, err := file()
	if err != nil {
		return nil, err
	}

	state, err := read(f)
	if err != nil {
		return nil, err
	}

	s := &State{
		State: state,
		file: f,
	}

	return s, nil
}

func file() (string, error) {
	d, err := basedir.StateDir()
	if err != nil {
		return "", err
	}
	f := filepath.Join(d, "state.json")
	return f, nil
}

func read(f string) (*state.State, error) {
	c, err := state.Read(f)
	if err != nil {
		if os.IsNotExist(err) {
			c = state.New()
			return c, nil
		}
		return nil, err
	}
	return c, nil
}

func (s *State) Write() error {
	return s.State.Write(s.file)
}

func (s *State) Remove() error {
	return os.Remove(s.file)
}

func (s *State) NewClient() *rest.Client {
	cl := rest.NewClient()
	return cl.WithJWT(s.Token)
}

func (s *State) Validate() error {
	t := []error{}
	if s.BaseURL == "" {
		e := fmt.Errorf("BaseURL is empty")
		t = append(t, e)
	}
	if s.Token == "" {
		e := fmt.Errorf("Token is empty")
		t = append(t, e)
	}
	return errors.Join(t...)
}
