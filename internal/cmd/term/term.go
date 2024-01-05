package term

import (
	"os"
	"vanyauhalin/osub/internal/cmd/table"
	"vanyauhalin/osub/internal/term"
)

type Term struct {
	*term.Term
}

func New() *Term {
	return &Term{
		term.New(os.Stdout),
	}
}

func (t *Term) NewTable() (*table.Table, error) {
	w, err := t.Width()
	if err != nil {
		return nil, err
	}
	tb := table.New(t.Out(), w)
	return tb, nil
}
