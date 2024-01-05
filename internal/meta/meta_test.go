package meta

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestDescribesTheLatestData(t *testing.T) {
	assert.Equal(t, "0.4.0", Version)
	assert.Equal(t, "v0.4.0", Tag)
	assert.Equal(t, "vanyauhalin", Owner)
	assert.Equal(t, "osub", Name)
	assert.Equal(t, "me.vanyauhalin.osub", ID)
	assert.Equal(t, "OpenSubtitles CLI", Title)
}
