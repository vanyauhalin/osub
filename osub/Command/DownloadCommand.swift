import ArgumentParser
import Client
import Configuration
import Downloads
import Foundation
import State

struct DownloadCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "download",
    abstract: "Download subtitles.",
    usage: "osub download --file-id <int> <options>"
  )

  @OptionGroup(title: "Query Options")
  var query: QueryOptions

  var output = StandardTextOutputStream.shared
  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared
  var stateManager: StateManagerProtocol = StateManager.shared
  var downloadsManager: DownloadsManagerProtocol = DownloadsManager.shared
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
    let download = try await client.downloads.post(
      fileID: query.fileID,
      fileName: query.fileName,
      inFPS: query.inFPS,
      outFPS: query.outFPS,
      subFormat: query.subFormat,
      timeshift: query.timeshift
    )

    guard let url = download.link else {
      throw DownloadCommandError.fileURLUnavailable
    }

    let dist = try await downloadsManager.download(from: url)

    print(
      "The subtitles have been successfully downloaded to",
      dist.path2(),
      to: &output
    )
  }
}

extension DownloadCommand {
  enum CodingKeys: CodingKey {
    case query
  }

  struct QueryOptions: ParsableArguments {
    @Option(
      help: ArgumentHelp(
        "File ID from subtitles search results.",
        valueName: .int
      )
    )
    var fileID: Int

    @Option(
      help: ArgumentHelp(
        "Desired subtitle file name to save on disk.",
        valueName: .string
      )
    )
    var fileName: String?

    @Option(
      name: .customLong("in-fps"),
      help: ArgumentHelp(
        "Input FPS for subtitles.",
        valueName: .int
      )
    )
    var inFPS: Int?

    @Option(
      name: .customLong("out-fps"),
      help: ArgumentHelp(
        "Output FPS for subtitles.",
        valueName: .int
      )
    )
    var outFPS: Int?

    @Option(
      help: ArgumentHelp(
        "Subtitles format from formats results.",
        valueName: .string
      )
    )
    var subFormat: String?

    @Option(
      help: ArgumentHelp(
        "Timeshift for subtitles.",
        valueName: .int
      )
    )
    var timeshift: Int?
  }
}

// MARK: Error

enum DownloadCommandError: Error {
  case fileURLUnavailable
}

extension DownloadCommandError: CustomStringConvertible {
  var description: String {
    switch self {
    case .fileURLUnavailable:
      return "The subtitles hasn't been downloaded. The file doesn't have a download URL."
    }
  }
}
