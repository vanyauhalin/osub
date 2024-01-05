package rest

import (
	"context"
	"fmt"
	"net/http"
	"testing"
	"vanyauhalin/osub/internal/tjson"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestUnmarshalsMarshalsCredentials(t *testing.T) {
	a0 := &Credentials{}
	b0 := "{}"
	tjson.TestUnmarshalsMarshalsJSON(t, a0, b0)

	a1 := &Credentials{
		Username: String("username"),
		Password: String("password"),
	}
	b1 := `{
		"username": "username",
		"password": "password"
	}`
	tjson.TestUnmarshalsMarshalsJSON(t, a1, b1)
}

func TestUnmarshalsMarshalsLogin(t *testing.T) {
	a0 := &Login{}
	b0 := "{}"
	tjson.TestUnmarshalsMarshalsJSON(t, a0, b0)

	a1 := &Login{
		User: &User{
			AllowedDownloads: Int(100),
			AllowedTranslations: Int(5),
			Level: String("Sub leecher"),
			UserID: Int(66),
			ExtInstalled: Bool(false),
			VIP: Bool(false),
		},
		BaseURL: String("api.opensubtitles.com"),
		Token: String("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9"),
		Status: Int(200),
	}
	b1 := `{
		"user": {
			"allowed_downloads": 100,
			"allowed_translations": 5,
			"level": "Sub leecher",
			"user_id": 66,
			"ext_installed": false,
			"vip": false
		},
		"base_url": "api.opensubtitles.com",
		"token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9",
		"status": 200
	}`
	tjson.TestUnmarshalsMarshalsJSON(t, a1, b1)
}

func TestLoginsUsingTheAuthService(t *testing.T) {
	client, mux, teardown := setup()
	defer teardown()

	mux.HandleFunc("/login", func (w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, "POST", r.Method)
		fmt.Fprint(w, `{
			"token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9"
		}`)
	})

	ctx := context.Background()
	c := &Credentials{
		Username: String("username"),
		Password: String("password"),
	}
	a, _, err := client.Auth.Login(ctx, c)
	require.NoError(t, err)

	e := &Login{
		Token: String("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9"),
	}
	assert.Equal(t, e, a)
}

func TestLogoutsUsingTheAuthService(t *testing.T) {
	client, mux, teardown := setup()
	defer teardown()

	mux.HandleFunc("/logout", func (w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, "DELETE", r.Method)
		fmt.Fprint(w, `{
			"message": "token successfully destroyed",
			"status": 200
		}`)
	})

	ctx := context.Background()
	a, _, err := client.Auth.Logout(ctx)
	require.NoError(t, err)

	e := &Logout{
		Message: String("token successfully destroyed"),
		Status: Int(200),
	}
	assert.Equal(t, e, a)
}
