package moviehash

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockFile struct {
	*os.File
	MockSize int
	MockReadAt func (b []byte, off int64) (n int, err error)
}

func (m mockFile) ReadAt(b []byte, off int64) (n int, err error) {
	return m.MockReadAt(b, off)
}

func (f mockFile) Stat() (os.FileInfo, error) {
	s, err := f.File.Stat()
	if err != nil {
		return s, err
	}
	m := mockFileInfo{
		FileInfo: s,
		MockSize: f.MockSize,
	}
	return m, err
}

type mockFileInfo struct {
	fs.FileInfo
	MockSize int
}

func (m mockFileInfo) Size() int64 {
	return int64(m.MockSize)
}

func TestSums(t *testing.T) {
	l := [][]string{
		{"breakdance.avi", "8e245d9679d31e12"},
		{"dummy.bin", "61f7751fc2a72bfb"},
	}
	for _, i := range l {
		p := filepath.Join("./testdata", i[0])
		f, err := os.Open(p)
		if err == nil {
			h, err := Sum(f)
			require.NoError(t, err)
			assert.Equal(t, i[1], h)
		} else {
			if os.IsNotExist(err) {
				fmt.Printf("warn: %s not found\n", p)
			} else {
				require.NoError(t, err)
			}
		}
	}
}

func TestSumsWithTheLeadingPadding(t *testing.T) {
	f, teardown := setup(t)
	defer teardown()

	f.MockSize = FileMinSize
	f.MockReadAt = func (b []byte, off int64) (n int, err error) {
		return ChunkSize, nil
	}

	h, err := Sum(f)
	require.NoError(t, err)
	assert.Equal(t, "0000000000020000", h)
}

func TestReturnsAnErrorIfTheFileIsTooSmall(t *testing.T) {
	f, teardown := setup(t)
	defer teardown()

	f.MockSize = FileMinSize - 1

	_, err := Sum(f)
	assert.Equal(t, ErrFileTooSmall, err)
}

func TestReturnsAnErrorIfTheFileIsTooLarge(t *testing.T) {
	f, teardown := setup(t)
	defer teardown()

	f.MockSize = FileMaxSize + 1

	_, err := Sum(f)
	assert.Equal(t, ErrFileTooLarge, err)
}

func TestReturnsAnErrorIfItReadsTheWrongNumberOfBytesFromTheFirstChunk(t *testing.T) {
	f, teardown := setup(t)
	defer teardown()

	f.MockSize = FileMinSize
	f.MockReadAt = func (b []byte, off int64) (n int, err error) {
		return ChunkSize - 1, nil
	}

	_, err := Sum(f)
	assert.Equal(t, ErrFirstChunkSize, err)
}

func TestReturnsAnErrorIfItReadsTheWrongNumberOfBytesFromTheLastChunk(t *testing.T) {
	f, teardown := setup(t)
	defer teardown()

	f.MockSize = FileMinSize
	f.MockReadAt = func (b []byte, off int64) (n int, err error) {
		if off == 0 {
			return ChunkSize, nil
		}
		return ChunkSize - 1, nil
	}

	_, err := Sum(f)
	assert.Equal(t, ErrLastChunkSize, err)
}

func setup(t *testing.T) (*mockFile, func ()) {
	d, err := os.MkdirTemp("", "osub")
	if err != nil {
		os.RemoveAll(d)
	}
	require.NoError(t, err)

	f, err := os.CreateTemp(d, "osub")
	if err != nil {
		f.Close()
	}
	require.NoError(t, err)

	m := &mockFile{
		File: f,
	}
	teardown := func () {
		os.RemoveAll(d)
		f.Close()
	}
	return m, teardown
}
