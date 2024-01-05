package term

import (
	"os"

	"golang.org/x/term"
)

type Term struct {
	out *os.File
}

func New(out *os.File) *Term {
	return &Term{
		out: out,
	}
}

func (t *Term) Out() *os.File {
	return t.out
}

func (t *Term) Width() (int, error) {
	fd := int(t.out.Fd())
	w, _, err := term.GetSize(fd)
	if err != nil {
		return 0, err
	}
	return w, nil
}
