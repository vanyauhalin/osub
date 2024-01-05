// Package moviehash implements a hash function to match subtitle files against
// movie files.
//
// [OpenSubtitles Reference]
//
// [OpenSubtitles Reference]: https://opensubtitles.stoplight.io/docs/opensubtitles-api/e3750fd63a100-getting-started#calculating-moviehash-of-video-file
package moviehash

import (
	"bytes"
	"encoding/binary"
	"errors"
	"os"
	"strconv"
	"strings"
)

const (
	ChunkSize     =      65536 // byte
	FileMaxSize   = 9000000000 // byte
	FileMinSize   =     131072 // byte
	HashMinLength =         16 // char
)

var (
	ErrFileTooSmall   = errors.New("moviehash: file is too small")
	ErrFileTooLarge   = errors.New("moviehash: file is too large")
	ErrFirstChunkSize = errors.New("moviehash: reads wrong number of bytes from the first chunk")
	ErrLastChunkSize  = errors.New("moviehash: reads wrong number of bytes from the last chunk")
)

type file interface {
	Stat() (os.FileInfo, error)
	ReadAt(b []byte, off int64) (n int, err error)
}

// Sum calculates the hash value of a file using the moviehash algorithm.
func Sum(file file) (string, error) {
	fi, err := file.Stat()
	if err != nil {
		return "", err
	}

	s := fi.Size()
	if s < FileMinSize {
		return "", ErrFileTooSmall
	}
	if s > FileMaxSize {
		return "", ErrFileTooLarge
	}

	c := uint64(s)

	b := make([]byte, ChunkSize * 2)

	n, err := file.ReadAt(b[:ChunkSize], 0)
	if err != nil {
		return "", err
	}
	if n != ChunkSize {
		return "", ErrFirstChunkSize
	}

	n, err = file.ReadAt(b[ChunkSize:], s - ChunkSize)
	if err != nil {
		return "", err
	}
	if n != ChunkSize {
		return "", ErrLastChunkSize
	}

	var d [ChunkSize * 2 / 8]uint64
	r := bytes.NewReader(b)
	err = binary.Read(r, binary.LittleEndian, &d)
	if err != nil {
		return "", err
	}

	for _, p := range d {
		c += p
	}

	h := strconv.FormatUint(c, 16)
	l := len(h)
	if l < HashMinLength {
		o := strings.Repeat("0", HashMinLength - l)
		h = o + h
	}

	return h, nil
}
