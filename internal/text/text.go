package text

import (
	"github.com/muesli/reflow/ansi"
	"github.com/muesli/reflow/truncate"
)

const (
	ellipsis = "…"
)

// Truncate returns a copy of the string that has been shortened to fit the
// maximum display width.
func Truncate(s string, to int) string {
	sw := ansi.PrintableRuneWidth(s)
	if sw <= to {
		return s
	}

	t := ""
	ew := ansi.PrintableRuneWidth(ellipsis) + 2
	if to >= ew {
		t = ellipsis
	}

	r := truncate.StringWithTail(s, uint(to), t)
	rw := ansi.PrintableRuneWidth(r)
	if rw < to {
		r += " "
	}

	return r
}
