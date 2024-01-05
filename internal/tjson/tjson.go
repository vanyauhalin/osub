package tjson

import (
	"encoding/json"
	"reflect"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestUnmarshalsMarshalsJSON(t *testing.T, a interface {}, b string) {
	i := reflect.New(reflect.TypeOf(a)).Interface()
	err := json.Unmarshal([]byte(b), &i)
	require.NoError(t, err)

	x, err := json.MarshalIndent(a, "", "  ")
	require.NoError(t, err)

	y, err := json.MarshalIndent(i, "", "  ")
	require.NoError(t, err)

	assert.Equal(t, string(x), string(y))
}
