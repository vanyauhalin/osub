import ArgumentParser
import Client
import Configuration
import Hash
import State
import TablePrinter

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
      moviehash: hash,
      languages: languages
    )

    var printer = TablePrinter()
    printer.append(Field(header: "subtitles id", truncatable: false))
    printer.append(Field(header: "release"))
    printer.append(Field(header: "language", truncatable: false))
    printer.append(Field(header: "uploaded"))
    printer.append(Field(header: "downloads"))
    printer.append(Field(header: "file id", truncatable: false))
    printer.append(Field(header: "file name"))
    printer.next()

    subtitles.data.enumerated().forEach { index, entity in
      func append() {
        printer.append(entity.id)
        printer.append(entity.attributes.release)
        printer.append(entity.attributes.language)
        printer.append(entity.attributes.uploadDate)
        printer.append(entity.attributes.downloadCount)
      }

      if entity.attributes.files.isEmpty {
        append()
        printer.append("?")
        printer.append("?")
        printer.next()
        return
      }

      entity.attributes.files.enumerated().forEach { index, file in
        append()
        printer.append(file.fileID)
        printer.append(file.fileName)
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
  }
}
