package table

import (
	"fmt"
	"io"
)

type Table struct {
	width   int
	rows    []*Row
	columns []*Column
	cells   []*Cell
	gap     string
}

type Row struct {
	index int
}

type Column struct {
	index int
	width int
	TruncateFunc func (string, int) string
}

type Cell struct {
	row    int
	column int
	text   string
}

func New(width int, gap string) *Table {
	t := &Table{
		width: width,
		gap: gap,
	}
	return t
}

func (t *Table) AddColumn() *Column {
	c := &Column{
		index: len(t.columns),
	}
	t.columns = append(t.columns, c)
	return c
}

func (t *Table) AddRow() *Row {
	r := &Row{
		index: len(t.rows),
	}
	t.rows = append(t.rows, r)
	return r
}

func (t *Table) AddCell(row *Row, column *Column, text string) {
	l := len(text)
	if l > column.width {
		column.width = l
	}
	c := &Cell{
		row: row.index,
		column: column.index,
		text: text,
	}
	t.cells = append(t.cells, c)
}

func (t *Table) Render(w io.Writer) error {
	if len(t.cells) == 0 {
		return nil
	}

	t.calc()

	err := t.print(w)
	if err != nil {
		return err
	}

	return nil
}

func (t *Table) calc() {
	total := (len(t.columns) - 1) * len(t.gap)
	available := 0

	for _, column := range t.columns {
		total += column.width
		if column.TruncateFunc != nil {
			available += column.width
		}
	}

	if total <= t.width {
		return
	}

	for _, column := range t.columns {
		if column.TruncateFunc != nil {
			column.width = column.width * (t.width - (total - available)) / available
		}
	}
}

func (t *Table) print(w io.Writer) error {
	rowIndex := 0

	for _, cell := range t.cells {
		text := ""

		if cell.row != rowIndex {
			rowIndex = cell.row
			text += "\n"
		}

		l := len(cell.text)
		column := t.columns[cell.column]

		switch {
		case l > column.width:
			text += column.TruncateFunc(cell.text, column.width)
		case l < column.width:
			text += fmt.Sprintf("%-*s", column.width, cell.text)
		default:
			text += cell.text
		}

		if cell.column != len(t.columns) - 1 {
			text += t.gap
		}

		_, err := fmt.Fprint(w, text)
		if err != nil {
			return err
		}
	}

	return nil
}
