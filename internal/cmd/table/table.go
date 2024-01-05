package table

import (
	"fmt"
	"io"
	"strconv"
	"strings"
	"time"
	"vanyauhalin/osub/internal/table"
	"vanyauhalin/osub/internal/text"
)

type Table struct {
	*table.Table
	out io.Writer
	nil string
}

func New(out io.Writer, w int) *Table {
	return &Table{
		Table: table.New(w, "  "),
		out: out,
		nil: "n/a",
	}
}

func (t *Table) AddRow() *Row {
	return &Row{
		Row: t.Table.AddRow(),
		table: t,
	}
}

func (t *Table) Render() error {
	err := t.Table.Render(t.out)
	if err != nil {
		return err
	}
	fmt.Println()
	return nil
}

type Row struct {
	*table.Row
	table *Table
}

func (r *Row) AddTruncHead(s string) *table.Column {
	h := r.AddHead(s)
	h.TruncateFunc = text.Truncate
	return h
}

func (r *Row) AddHead(s string) *table.Column {
	s = strings.ToUpper(s)
	c := r.table.AddColumn()
	r.AddString(c, s)
	return c
}

func (r *Row) AddIntPointer(c *table.Column, i *int) {
	if i == nil {
		r.AddNil(c)
		return
	}
	r.AddInt(c, *i)
}

func (r *Row) AddInt(c *table.Column, i int) {
	s := strconv.Itoa(i)
	r.AddString(c, s)
}

func (r *Row) AddTimePointer(c *table.Column, t *time.Time) {
	if t == nil {
		r.AddNil(c)
		return
	}
	r.AddTime(c, *t)
}

func (r *Row) AddTime(c *table.Column, t time.Time) {
	s := t.Format("2 January 2006")
	r.AddString(c, s)
}

func (r *Row) AddStringPointer(c *table.Column, s *string) {
	if s == nil {
		r.AddNil(c)
		return
	}
	r.AddString(c, *s)
}

func (r *Row) AddNil(c *table.Column) {
	r.AddString(c, r.table.nil)
}

func (r *Row) AddString(c *table.Column, s string) {
	r.table.AddCell(r.Row, c, s)
}
