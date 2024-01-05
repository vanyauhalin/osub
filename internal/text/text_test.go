package text

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestTruncates(t *testing.T) {
	s := "This is a long string"
	e := "This is a…"
	a := Truncate(s, 10)
	assert.Equal(t, e, a)
}
