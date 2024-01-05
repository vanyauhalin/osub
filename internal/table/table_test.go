package table

import (
	"bytes"
	"testing"
	"vanyauhalin/osub/internal/text"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestRenders(t *testing.T) {
	table := New(15, "  ")

	h := table.AddRow()
	c0 := table.AddColumn()
	table.AddCell(h, c0, "SUBTAG")
	c1 := table.AddColumn()
	table.AddCell(h, c1, "NAME")

	b := table.AddRow()
	table.AddCell(b, c0, "en")
	table.AddCell(b, c1, "English")

	e := "" +
		"SUBTAG  NAME   \n" +
		"en      English"
	a := &bytes.Buffer{}
	err := table.Render(a)
	require.NoError(t, err)
	assert.Equal(t, e, a.String())
}

func TestRendersWithTruncation(t *testing.T) {
	table := New(12, "  ")

	h := table.AddRow()
	c0 := table.AddColumn()
	table.AddCell(h, c0, "SUBTAG")
	c1 := table.AddColumn()
	c1.TruncateFunc = text.Truncate
	table.AddCell(h, c1, "NAME")

	b := table.AddRow()
	table.AddCell(b, c0, "en")
	table.AddCell(b, c1, "English")

	e := "" +
		"SUBTAG  NAME\n" +
		"en      Eng…"
	a := &bytes.Buffer{}
	err := table.Render(a)
	require.NoError(t, err)
	assert.Equal(t, e, a.String())
}
