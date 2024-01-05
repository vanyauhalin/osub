// Provides functions for determining the base directories for configuration,
// downloads, and state files in different operating systems.
package basedir

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"vanyauhalin/osub/internal/meta"
)

// Returns the base directory for configuration files.
func ConfigDir() (string, error) {
	d := os.Getenv("OSUB_CONFIG_DIR")
	if d != "" {
		return d, nil
	}

	d = os.Getenv("XDG_CONFIG_HOME")
	if d != "" {
		d = filepath.Join(d, meta.Name)
		return d, nil
	}

	switch runtime.GOOS {
	case "windows":
		d = os.Getenv("AppData")
		if d == "" {
			err := notDefined("%AppData%")
			return d, err
		}
		d = filepath.Join(d, meta.Owner, meta.Title)

	case "darwin":
		d = os.Getenv("HOME")
		if d == "" {
			err := notDefined("$HOME")
			return d, err
		}
		d = filepath.Join(d, "Library/Application Support", meta.ID)

	case "plan9":
		d = os.Getenv("home")
		if d == "" {
			err := notDefined("$home")
			return d, err
		}
		d = filepath.Join(d, "lib", meta.Name)

	default:
		d = os.Getenv("HOME")
		if d == "" {
			err := notDefined("$HOME")
			return d, err
		}
		d = filepath.Join(d, "." + meta.Name)
	}

	return d, nil
}

// Returns the base directory for downloaded files.
func DownloadDir() (string, error) {
	d := os.Getenv("OSUB_DOWNLOAD_DIR")
	if d != "" {
		return d, nil
	}

	d = os.Getenv("XDG_DOWNLOAD_DIR")
	if d != "" {
		return d, nil
	}

	switch runtime.GOOS {
	case "windows":
		d = os.Getenv("UserProfile")
		if d == "" {
			err := notDefined("%%UserProfile%")
			return d, err
		}
		d = filepath.Join(d, "Downloads")

	case "darwin":
		d = os.Getenv("HOME")
		if d == "" {
			err := notDefined("$HOME")
			return d, err
		}
		d = filepath.Join(d, "Downloads")

	case "plan9":
		d = os.Getenv("home")
		if d == "" {
			err := notDefined("$home")
			return d, err
		}
		d = filepath.Join(d, "downloads")

	default:
		d = os.Getenv("HOME")
		if d == "" {
			err := notDefined("$HOME")
			return d, err
		}
		d = filepath.Join(d, "Downloads")
	}

	return d, nil
}

// Returns the base directory for state files.
func StateDir() (string, error) {
	d := os.Getenv("OSUB_STATE_DIR")
	if d != "" {
		return d, nil
	}

	d = os.Getenv("XDG_STATE_HOME")
	if d != "" {
		d = filepath.Join(d, meta.Name)
		return d, nil
	}

	switch runtime.GOOS {
	case "windows":
		d = os.Getenv("LocalAppData")
		if d == "" {
			err := notDefined("%LocalAppData%")
			return d, err
		}
		d = filepath.Join(d, meta.Owner, meta.Title)

	case "darwin":
		d = os.Getenv("HOME")
		if d == "" {
			err := notDefined("$HOME")
			return d, err
		}
		d = filepath.Join(d, "Library/Application Support", meta.ID, "state")

	case "plan9":
		d = os.Getenv("home")
		if d == "" {
			err := notDefined("$home")
			return d, err
		}
		d = filepath.Join(d, "lib/state", meta.Name)

	default:
		d = os.Getenv("HOME")
		if d == "" {
			err := notDefined("$HOME")
			return d, err
		}
		d = filepath.Join(d, "." + meta.Name, "state")
	}

	return d, nil
}

// Returns an error indicating that a specific environment variable is not
// defined.
func notDefined(name string) error {
	return fmt.Errorf("basedir: %s is not defined", name)
}
