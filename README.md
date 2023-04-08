# osub <!-- omit in toc -->

osub is a command line tool for downloading subtitles from [OpenSubtitles](https://www.opensubtitles.com/).

```text
$ osub auth login --username lynsey --password lawrence
The authentication token has been successfully generated.
```

```text
$ osub --file Aliens.mp4 --languages en

Printing 4 of 4 subtitles.

SUBTITLES ID  RELEASE                                                 LANGUAGE  UPLOADED              DOWNLOADS  FILE ID  FILE NAME                                               
171510        Aliens.1986.Special.Edition.720p.BRRip.XviD.AC3-ViSiON  en        2010-10-30T13:49:48Z  57706      171816   Aliens.1986.Special.Edition.720p.BRRip.XviD.AC3-ViSiON  
169952        Aliens.1986.Special.Edition.720p.BluRay.x264.DTS-WiKi   en        2010-10-02T10:51:04Z  88136      169957   Aliens.1986.Special.Edition.720p.BluRay.x264.DTS-WiKi.EN
4749878       Aliens.Vs.Predator.2.PROPER.R3.XViD-BaLD                en        2008-03-02T17:46:23Z  31408      4872906  Aliens.Vs.Predator.2.PROPER.R3.XViD-BaLD                
177188        Alien[1986]Special Edition BRRip                        en        2014-02-02T04:14:38Z  3956       178825   Alien[1986]Special Edition BRRip                        
```

```text
$ osub download --file-id 169957
The subtitles have been successfully downloaded to /Users/vanyauhalin/Downloads/Aliens.1986.Special.Edition.720p.BluRay.x264.DTS-WiKi.EN.srt
```

Feel free to open an [issue](https://github.com/vanyauhalin/osub/issues/), create a [pull request](https://github.com/vanyauhalin/osub/pulls/), or contact me via [email](mailto:vanyauhalin@mail.com) or [Telegram](https://t.me/vanyauhalin/) if you encounter any issues, have any questions, or wish to request a feature. I'll be happy to develop osub with you for us.

## Contents <!-- omit in toc -->

- [Installation](#installation)
  - [Using Homebrew](#using-homebrew)
  - [Using a release binary](#using-a-release-binary)
  - [Build from sources](#build-from-sources)
- [Usage](#usage)
  - [Manage configuration](#manage-configuration)
    - [Configuration locations](#configuration-locations)
    - [Configuration file its values](#configuration-file-its-values)
  - [Manage authentication](#manage-authentication)
  - [Search for subtitles](#search-for-subtitles)
  - [Download subtitles](#download-subtitles)
  - [Additional utilities](#additional-utilities)
    - [Calculate the hash of the file](#calculate-the-hash-of-the-file)
    - [Print a list of languages for subtitles](#print-a-list-of-languages-for-subtitles)
    - [Print the current osub version](#print-the-current-osub-version)
- [Contribution](#contribution)
- [License](#license)

## Installation

At the moment, osub is only available for macOS users. However, there are plans to add support for both Windows and Linux, thus making osub cross-platform.

### Using Homebrew

```sh
brew tap vanyauhalin/osub
```

### Using a release binary

Download the [latest release binary](https://github.com/vanyauhalin/osub/releases/) and unzip it.

### Build from sources

osub is built on the OpenSubtitles REST API, so you will need to obtain an API key before starting the build. You can learn more about how to obtain the API key in the [official documentation](https://opensubtitles.stoplight.io/docs/opensubtitles-api/e3750fd63a100-getting-started#api-key).

To build, you need the following tools with minimum versions:

- [Xcode 14.0](https://developer.apple.com/xcode/)
- [Swift 5.7.0](https://www.swift.org/)
- [Make 3.0](https://www.gnu.org/software/make/)
- [Tuist 3.12.0](https://tuist.io/)

Once you have everything installed, download the source code or clone the Git repository. Then, in the root directory, execute the following command:

```sh
make build API_KEY=<your_api_key>
```

The build result will be in the `.build` directory.

## Usage

<details>
  <summary>
    Show help message.
  </summary>

```sh
osub --help
```

```text
USAGE: osub <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  auth                    Manage authentication.
  config                  Manage configuration.
  download                Download subtitles.
  hash                    Calculate the hash of the file.
  languages               Print a list of languages for subtitles.
  search (default)        Search for subtitles.
  version                 Print the current osub version.

  See 'osub help <subcommand>' for detailed help.
```

</details>

### Manage configuration

<details>
  <summary>
    Show help messages.
  </summary>

```sh
osub config --help
```

```text
OVERVIEW: Manage configuration.

USAGE: osub config <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  get                     Print the value of the given configuration key.
  list                    Print a list of configuration keys and values.
  locations               Print a locations used by osub.
  set                     Update the configuration with a value for the given
                          key.

  See 'osub help config <subcommand>' for detailed help.
```

```sh
osub config get --help
```

```text
OVERVIEW: Print the value of the given configuration key.

USAGE: osub config get <key>

ARGUMENTS:
  <key>                   The configuration key.

OPTIONS:
  -h, --help              Show help information.
```

```sh
osub config list --help
```

```text
OVERVIEW: Print a list of configuration keys and values.

USAGE: osub config list

OPTIONS:
  -h, --help              Show help information.
```

```sh
osub config locations --help
```

```text
OVERVIEW: Print a locations used by osub.

USAGE: osub config locations

OPTIONS:
  -h, --help              Show help information.
```

```sh
osub config set --help
```

```text
OVERVIEW: Update the configuration with a value for the given key.

USAGE: osub config set <key> <value>

ARGUMENTS:
  <key>                   The configuration key.
  <value>                 The value of the configuration key.

OPTIONS:
  -h, --help              Show help information.
```

</details>

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

To find out which locations are currently in use, it is enough to execute:

```sh
osub config locations
```

#### Configuration file its values

The configuration values can be manipulated using the following commands:

```sh
osub config [get|set]
```

But at the same time, osub supports loading a configuration file in the [TOML](https://toml.io/) format with the following values:

| Value      | Type   | Description                                                                                                                                                                                                                                         |
| :--------- | :----- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `api_key`  | String | The API key is built-in by default, but you can override it. To learn more about how to obtain the API key, refer to the [official documentation](https://opensubtitles.stoplight.io/docs/opensubtitles-api/e3750fd63a100-getting-started#api-key). |
| `username` | String | The OpenSubtitles account name.                                                                                                                                                                                                                     |
| `password` | String | The OpenSubtitles account username.                                                                                                                                                                                                                 |

### Manage authentication

<details>
  <summary>
    Show help messages.
  </summary>

```sh
osub auth --help
```

```text
OVERVIEW: Manage authentication.

USAGE: osub auth <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  list                    Print a list of authentication keys and values.
  login                   Login by generating an authentication token.
  logout                  Logout by destroying the authentication token.
  refresh                 Refresh the authentication token.
  status                  Print authentication status.

  See 'osub help auth <subcommand>' for detailed help.
```

```sh
osub auth list --help
```

```text
OVERVIEW: Print a list of authentication keys and values.

USAGE: osub auth list

OPTIONS:
  -h, --help              Show help information.
```

```sh
osub auth login --help
```

```text
OVERVIEW: Login by generating an authentication token.

USAGE: osub auth login <username> <password>

ARGUMENTS:
  <username>              The account name.
  <password>              The account password.

OPTIONS:
  -h, --help              Show help information.
```

```sh
osub auth logout --help
```

```text
OVERVIEW: Logout by destroying the authentication token.

USAGE: osub auth logout

OPTIONS:
  -h, --help              Show help information.
```

```sh
osub auth refresh --help
```

```text
OVERVIEW: Refresh the authentication token.

USAGE: osub auth refresh

OPTIONS:
  -h, --help              Show help information.
```

```sh
osub auth status --help
```

```text
OVERVIEW: Print authentication status.

USAGE: osub auth status

OPTIONS:
  -h, --help              Show help information.
```

</details>

### Search for subtitles

<details>
  <summary>
    Show help messages.
  </summary>

```sh
osub search --help
```

```text
OVERVIEW: Search for subtitles.

USAGE: osub search <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  subtitles (default)     Search for subtitles.

  See 'osub help search <subcommand>' for detailed help.
```

```sh
osub search subtitles --help
```

```text
OVERVIEW: Search for subtitles.

USAGE: osub search subtitles [--file <path>] [--languages <string>]

OPTIONS:
  -f, --file <path>       The path to the file that needs subtitles.
  -l, --languages <string>
                          Comma-separated list of subtag languages for
                          subtitles.
  -h, --help              Show help information.
```

</details>

### Download subtitles

<details>
  <summary>
    Show help message.
  </summary>

```sh
osub download --help
```

```text
OVERVIEW: Download subtitles.

USAGE: osub download --file-id <int>

OPTIONS:
  -f, --file-id <int>     The file ID from subtitles search results.
  -h, --help              Show help information.
```

</details>

### Additional utilities

#### Calculate the hash of the file

<details>
  <summary>
    Show help message.
  </summary>

```sh
osub hash --help
```

```text
OVERVIEW: Calculate the hash of the file.

USAGE: osub hash <path>

ARGUMENTS:
  <path>                  The path to the file whose hash is to be calculated.

OPTIONS:
  -h, --help              Show help information.
```

</details>

OpenSubtitles uses a special hash function to match subtitle files against movie files. The hash is not dependent on the file name of the movie file. To learn more about this function, refer to the [official documentation](https://trac.opensubtitles.org/projects/opensubtitles/wiki/HashSourceCodes/).

#### Print a list of languages for subtitles

<details>
  <summary>
    Show help message.
  </summary>

```sh
osub languages --help
```

```text
OVERVIEW: Print a list of languages for subtitles.

USAGE: osub languages

OPTIONS:
  -h, --help              Show help information.
```

</details>

#### Print the current osub version

<details>
  <summary>
    Show help message.
  </summary>

```sh
osub version --help
```

```text
OVERVIEW: Print the current osub version.

USAGE: osub version

OPTIONS:
  -h, --help              Show help information.
```

</details>

## Contribution

<details>
  <summary>
    Show help message.
  </summary>

```sh
make help
```

```text
OVERVIEW: Welcome to the vanyauhalin/osub sources.

USAGE: make <subcommand> [argument=value]

SUBCOMMANDS:
  build       Build the osub via Tuist.
  clean       Clean generated Tuist files.
  dev         Generate a development workspace via Tuist.
  help        Show this message.
  install     Install dependencies via Tuist.
  lint        Lint the osub via SwiftLint.
  test        Test the osub via Tuist.
  version     Print the current osub version.

ARGUMENTS:
  API_KEY     Specify a API key for the build command.
  target      Specify a target for the lint command.
```

</details>

## License

osub is distributed under the [MIT License](./License).
