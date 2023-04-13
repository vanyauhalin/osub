import ArgumentParser
import Client
import Configuration
import Hash
import State

struct SearchCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "search",
    abstract: "Search for subtitles.",
    subcommands: [
      SearchSubtitlesCommand.self
    ],
    defaultSubcommand: SearchSubtitlesCommand.self
  )
}

struct SearchSubtitlesCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "subtitles",
    abstract: "Search for subtitles."
  )

  @Option(
    name: .shortAndLong,
    help: ArgumentHelp(
      "The path to the file that needs subtitles.",
      valueName: "path"
    )
  )
  var file: String?

  @Option(
    name: .shortAndLong,
    help: ArgumentHelp(
      "Comma-separated list of subtag languages for subtitles.",
      valueName: "string"
    )
  )
  var languages: String?

  @OptionGroup(title: "Formatting Options")
  var formatting: FormattingOptions<Field>

  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared
  var stateManager: StateManagerProtocol = StateManager.shared
  var client: ClientProtocol = Client.shared

  mutating func run() async throws {
    try configure()
    try await action()
  }

  func configure() throws {
    let config = try configManager.load()
    let state = try stateManager.load()
    client.configure(config: config, state: state)
  }

  mutating func action() async throws {
    var hash: String?
    if let file {
      hash = try Hash.hash(of: file)
    }
    let subtitles = try await client.search.subtitles(
      aiTranslated: nil,
      episodeNumber: nil,
      foreignPartsOnly: nil,
      hearingImpaired: nil,
      id: nil,
      imdbID: nil,
      languages: languages,
      machineTranslated: nil,
      moviehashMatch: nil,
      moviehash: hash,
      orderBy: nil,
      orderDirection: nil,
      page: nil,
      parentFeatureID: nil,
      parentIMDBID: nil,
      parentTMDBID: nil,
      query: nil,
      seasonNumber: nil,
      tmdbID: nil,
      trustedSources: nil,
      type: nil,
      userID: nil,
      year: nil
    )

    var printer = formatting.printer()
    subtitles.data.forEach { entity in
      if entity.attributes.files.isEmpty {
        formatting.fields.forEach { field in
          switch field {
          case .downloads:
            printer.append(entity.attributes.downloadCount)
          case .fileID:
            printer.append("?")
          case .fileName:
            printer.append("?")
          case .language:
            printer.append(entity.attributes.language)
          case .release:
            printer.append(entity.attributes.release)
          case .subtitlesID:
            printer.append(entity.id)
          case .uploaded:
            printer.append(entity.attributes.uploadDate)
          }
        }
        printer.next()
        return
      }

      entity.attributes.files.forEach { file in
        formatting.fields.forEach { field in
          switch field {
          case .downloads:
            printer.append(entity.attributes.downloadCount)
          case .fileID:
            printer.append(file.fileID)
          case .fileName:
            printer.append(file.fileName)
          case .language:
            printer.append(entity.attributes.language)
          case .release:
            printer.append(entity.attributes.release)
          case .subtitlesID:
            printer.append(entity.id)
          case .uploaded:
            printer.append(entity.attributes.uploadDate)
          }
        }
        printer.next()
      }
    }

    print()
    print("Printing \(subtitles.data.count) of \(subtitles.totalCount) subtitles.")
    print()
    printer.print()
  }
}

extension SearchSubtitlesCommand {
  enum CodingKeys: String, CodingKey {
    case file
    case languages
    case formatting
  }

  enum Field: String, FormattingField {
    case downloads
    case fileID = "file_id"
    case fileName = "file_name"
    case language
    case release
    case subtitlesID = "subtitles_id"
    case uploaded

    static var defaultValues: [Self] {
      [
        .fileID,
        .fileName,
        .language,
        .uploaded,
        .downloads,
        .subtitlesID
      ]
    }
  }
}
