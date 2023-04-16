# osub

osub is a command line tool for downloading subtitles from [OpenSubtitles](https://www.opensubtitles.com).

```sh
$ osub auth login username password
The authentication token has been successfully generated.
```

```sh
$ osub --file Aliens.mp4 --languages en

Printing 1 page of 1 for 4 subtitles.

FILE ID  FILE NAME            LANGUAGE  UPLOADED         DOWNLOADS  SUBTITLES ID
169957   Aliens.1986.Spec...  English   2 October 2010   88136      169952      
171816   Aliens.1986.Spec...  English   30 October 2010  57706      171510      
4872906  Aliens.Vs.Predat...  English   2 March 2008     31408      4749878     
178825   Alien[1986]Speci...  English   2 February 2014  3956       177188      
```

```sh
$ osub download --file-id 169957
The subtitles have been successfully downloaded to /Users/vanyauhalin/Downloads/
Aliens.1986.Special.Edition.720p.BluRay.x264.DTS-WiKi.EN.srt
```

Feel free to open an [issue](https://github.com/vanyauhalin/osub/issues), create a [pull request](https://github.com/vanyauhalin/osub/pulls), or contact me via [email](mailto:vanyauhalin@mail.com) or [Telegram](https://t.me/vanyauhalin) if you encounter any issues, have any questions, or wish to request a feature. I'll be happy to develop osub with you for us.

## Contents

- [Installation](#installation)
  - [Using Homebrew](#using-homebrew)
  - [Using a release binary](#using-a-release-binary)
  - [Build from sources](#build-from-sources)
- [Usage](#usage)
  - [Manage configuration](#manage-configuration)
    - [Configuration locations](#configuration-locations)
    - [Configuration file its values](#configuration-file-its-values)
    - [`osub config`](#osub-config)
    - [`osub config get`](#osub-config-get)
    - [`osub config list`](#osub-config-list)
    - [`osub config locations`](#osub-config-locations)
    - [`osub config get`](#osub-config-get)
  - [Manage authentication](#manage-authentication)
    - [`osub auth`](#osub-auth)
    - [`osub auth list`](#osub-auth-list)
    - [`osub auth login`](#osub-auth-login)
    - [`osub auth logout`](#osub-auth-logout)
    - [`osub auth refresh`](#osub-auth-refresh)
    - [`osub auth status`](#osub-auth-status)
  - [Search management](#search-management)
    - [`osub search`](#osub-search)
    - [`osub search features`](#osub-search-features)
    - [`osub search subtitles`](#osub-search-subtitles)
  - [Download subtitles](#download-subtitles)
    - [`osub download`](#osub-download)
  - [Utility commands](#utility-commands)
    - [`osub formats`](#osub-formats)
    - [`osub hash`](#osub-hash)
    - [`osub languages`](#osub-languages)
    - [`osub version`](#osub-version)
  - [Formatting options](#formatting-options)
- [Contribution](#contribution)
- [Gratitude](#gratitude)
- [License](#license)

## Installation

At the moment, osub is only available for macOS users. However, there are plans to add support for both Windows and Linux, thus making osub cross-platform.

### Using Homebrew

```
$ brew tap vanyauhalin/osub
$ brew install osub
```

### Using a release binary

Download the [latest release binary](https://github.com/vanyauhalin/osub/releases) and unzip it.

### Build from sources

osub is built on the OpenSubtitles REST API, so you will need to obtain an API key before starting the build. You can learn more about how to obtain the API key in the [official documentation](https://opensubtitles.stoplight.io/docs/opensubtitles-api/e3750fd63a100-getting-started#api-key).

To build, you need the following tools with minimum versions:

- [Xcode 14.0](https://developer.apple.com/xcode)
- [Swift 5.7.0](https://www.swift.org)
- [Make 3.0](https://www.gnu.org/software/make)
- [Tuist 3.12.0](https://tuist.io)

Once you have everything installed, download the source code or clone the Git repository. Then, in the root directory, execute the following command:

```sh
$ make build API_KEY=<api-key>
```

The build result will be in the `.build` directory.

## Usage

### Manage configuration

osub can run without configuration, so if you wish, you can skip to the [next section](#manage-authentication).

#### Configuration locations

To determine the working locations, osub first accesses the environment variables. In case the environment variables are not set, it then checks the system settings.

So, the configuration location is defined as follows:

| Base path                                          | Additional path        |
| :------------------------------------------------- | :--------------------- |
| `$OSUB_CONFIG_HOME`                                |                        |
| `$XDG_CONFIG_HOME`                                 | `osub/`                |
| Application support directory for the current user | `me.vanyauhalin.osub/` |
| The home directory for the current user            | `.config/osub/`        |

The state location:

| Base path                               | Additional path      |
| :-------------------------------------- | :------------------- |
| `$XDG_STATE_HOME`                       | `osub/`              |
| The home directory for the current user | `.local/state/osub/` |

The downloads location:

| Base path                               | Additional path |
| :-------------------------------------- | :-------------- |
| `$XDG_DOWNLOAD_DIR`                     |                 |
| The downloads for the current user      |                 |
| The home directory for the current user | `Downloads/`    |

To find out which locations are currently in use, refer to the [`osub config locations`](#osub-config-locations) command.

#### Configuration file its values

The configuration values can be manipulated using the [`osub config get`](#osub-config-get) and [`osub config set`](#osub-config-set) commands. But at the same time, osub supports loading a configuration file in the [TOML](https://toml.io) format (`config.toml`) with the following values:

| Value      | Type   | Description                                                                                                                                                                                                                                         |
| :--------- | :----- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `api_key`  | String | The API key is built-in by default, but you can override it. To learn more about how to obtain the API key, refer to the [official documentation](https://opensubtitles.stoplight.io/docs/opensubtitles-api/e3750fd63a100-getting-started#api-key). |
| `username` | String | The OpenSubtitles account name.                                                                                                                                                                                                                     |
| `password` | String | The OpenSubtitles account username.                                                                                                                                                                                                                 |

#### `osub config`

Root command for configuration management.

```sh
$ osub config <subcommand>
```

#### `osub config get`

Print the [value](#configuration-file-its-values) of the given configuration [key](#configuration-file-its-values).

```sh
$ osub config get <key>
```

#### `osub config list`

Print a list of configuration [keys](#configuration-file-its-values) and [values](#configuration-file-its-values).

```sh
$ osub config list
```

#### `osub config locations`

Print a [locations](#configuration-locations) used by osub.

```sh
$ osub config locations
```

#### `osub config get`

Update the configuration with a [value](#configuration-file-its-values) for the given [key](#configuration-file-its-values).

```sh
$ osub config set <key> <value>
```

### Manage authentication

In order to be able to download subtitles, you must [log in](#osub-auth-login). Once you are authorized, a token will be generated and saved for future use. Simply [refresh](#osub-auth-refresh) the token when necessary.

#### `osub auth`

Root command for authentication management.

```sh
$ osub auth <subcommand>
```

#### `osub auth list`

Print a list of authentication keys and values.

```sh
$ osub auth list
```
  
#### `osub auth login`

Login by generating an authentication token.

```sh
$ osub auth login <username> <password>
```

#### `osub auth logout`

Logout by destroying the authentication token.

```sh
$ osub auth logout
```

#### `osub auth refresh`

Refresh the authentication token.

```sh
$ osub auth refresh
```

#### `osub auth status`

Print authentication status.

```sh
$ osub auth status
```

### Search management

With osub, you can search for both subtitles and features. A feature refers to a movie, TV show, or episode of a TV show.

#### `osub search`

Root command for search management.

```sh
$ osub search <subcommand>
```

#### `osub search features`

Search for features.

```sh
$ osub search features <options>
```

Query options:

- `--feature-id <int>`  
Search by feature ID.
- `--imdb-id <string>`  
Search by feature IMDB ID.
- `--query <string>`  
Search by file name or string query.
- `--tmdb-id <string>`  
Search by feature TMDB ID.
- `--type <enum>`  
Search on feature type: `episode`, `movie` or `tvshow`.
- `--year <int>`  
Search by year.

#### `osub search subtitles`

Search for subtitles.

```sh
$ osub search subtitles <options>
```

Query options:

- `--ai-translated <enum>`  
Restrict search to AI-translated subtitles: `exclude` or `include`.
- `--episode-number <int>`  
Search by TV Show episode number.
- `--foreign-parts-only <enum>`  
Restrict search to Foreign Parts Only (FPO) subtitles: `exclude`, `include` or `only`.
- `--hearing-impaired <enum>`  
Restrict search to subtitles for the hearing impaired: `exclude`, `include` or `only`.
- `--id <int>`  
Search by feature ID from the features search results.
- `--imdb-id <int>`  
Search by feature IMDB ID.
- `--languages <[string]>`  
Search on space-separated list of subtag languages.
- `--machine-translated <enum>`  
Restrict search to machine-translated subtitles: `exclude` or `include`.
- `--moviehash-match <enum>`  
Restrict search to subtitles with feature hash match: `include` and `only`.
- `--moviehash <string>`  
Search by feature hash.
- `--order-by <enum>`  
Order of returned results by field: `ai_translated`, `download_count`, `foreign_parts_only`, `fps`, `from_trusted`, `hd`, `hearing_impaired`, `language`, `machine_translated`, `points`, `ratings`, `release`, `upload_date`, `votes`.
- `--order-direction <enum>`  
Order of returned results by direction: `asc` or `desc`.
- `--page <int>`  
Search on the page.
- `--parent-feature-id <int>`  
Search for the TV Show by parent feature ID from the features search results.
- `--parent-imdb-id <int>`  
Search for the TV Show by parent IMDB ID.
- `--parent-tmdb-id <int>`  
Search for the TV Show by parent TMDB ID.
- `--query <string>`  
Search by file name or string query.
- `--season-number <int>`  
Search for the TV Show by season number.
- `--tmdb-id <int>`  
Search by feature TMDB ID.
- `--trusted-sources <enum>`  
Restrict search to trusted sources: `include` or `only`.
- `--type <enum>`  
Restrict search to feature type: `episode`, `movie` or `tvshow`.
- `--user-id <int>`  
Search for uploaded subtitles by user ID.
- `--year <int>`  
Search by year.

Utility options:

- `--file <path>`  
The path to the file that needs subtitles.

### Download subtitles

#### `osub download`

Root command for download subtitles.

```sh
$ osub download --file-id <int> <options>
```

Query options:

- `--file-id <int>`  
File ID from subtitles search results.
- `--file-name <string>`  
Desired subtitle file name to save on disk.
- `--in-fps <int>`  
Input FPS for subtitles.
- `--out-fps <int>`  
Output FPS for subtitles.
- `--sub-format <string>`  
Subtitles format from formats results.
- `--timeshift <int>`  
Timeshift for subtitles.

### Utility commands

Besides the primary commands, osub also includes some useful utility commands.

#### `osub formats`

Print a list of formats for subtitles.

```sh
$ osub formats
```

#### `osub hash`

Calculate the hash of the file.

```sh
$ osub hash <path>
```

#### `osub languages`

Print a list of languages for subtitles.

```sh
$ osub languages
```

#### `osub version`

Print the current osub version.

```sh
$ osub version
```

### Formatting options

Some commands offer simple formatting options:

- `--fields <[enum]>`  
Space-separated list of fields to print.
- `--frame/--no-frame`  
Consider the window size when formatting.

To view a list of available fields, run an invalid command with the `--fields` option, for example:

```sh
$ osub <subcommand> --fields ?
```

## Contribution

To contribute, you need the following tools with minimum versions:

- [Xcode 14.0](https://developer.apple.com/xcode)
- [Swift 5.7.0](https://www.swift.org)
- [Make 3.0](https://www.gnu.org/software/make)
- [Tuist 3.12.0](https://tuist.io)
- [SwiftLint 0.50.0](https://realm.github.io/SwiftLint) — optional, but recommended.

Once you have everything installed, in the root directory, execute the following commands:

```sh
$ make install
$ make dev
```

## Gratitude

I would like to express my gratitude to the OpenSubtitles team for providing such an great service. I also extend my appreciation to the authors of the wrappers, applications, and scripts that utilized the OpenSubtitles REST API. It was interesting to study your work. Furthermore, I would like to thank the authors of the [GitHub CLI](https://cli.github.com), whose product was a significant source of inspiration for me.

## License

osub is distributed under the [MIT License](./License).
