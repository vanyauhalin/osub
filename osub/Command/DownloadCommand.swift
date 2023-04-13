import ArgumentParser
import Client
import Configuration
import Downloads
import Foundation
import State

struct DownloadCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "download",
    abstract: "Download subtitles."
  )

  @Option(
    name: .shortAndLong,
    help: ArgumentHelp(
      "The file ID from subtitles search results.",
      valueName: .int
    )
  )
  var fileID: Int

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
    let download = try await client.downloads.post(fileID: fileID)
    guard let url = download.link else {
      throw DownloadCommandError.fileURLUnavailable
    }

    let dist = try await downloadsManager.download(from: url)

    print("The subtitles have been successfully downloaded to", dist.path2())
  }
}

extension DownloadCommand {
  enum CodingKeys: String, CodingKey {
    case fileID
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
