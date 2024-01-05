package state

import (
	"encoding/json"
	"os"
	"sync"
)

type State struct {
	BaseURL string `json:"base_url,omitempty"`
	Token   string `json:"token,omitempty"`

	mu sync.Mutex
}

func New() *State {
	return &State{}
}

func Read(file string) (*State, error) {
	s := New()

	j, err := os.ReadFile(file)
	if err != nil {
		return nil, err
	}

	err = json.Unmarshal(j, &s)
	if err != nil {
		return nil, err
	}

	return s, nil
}

func (s *State) Write(file string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	j, err := json.MarshalIndent(s, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(file, j, 0600)
}
