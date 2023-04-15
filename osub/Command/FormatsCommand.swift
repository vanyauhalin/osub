import ArgumentParser
import Client
import Configuration
import State

struct FormatsCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "formats",
    abstract: "Print a list of formats for subtitles."
  )

  var output = StandardTextOutputStream.shared
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
    let formats = try await client.info.formats()

    if formats.data.outputFormats.isEmpty {
      print("", to: &output)
    } else {
      formats.data.outputFormats.forEach { format in
        print(format, to: &output)
      }
    }
  }
}

extension FormatsCommand {
  init(from decoder: Decoder) throws {}
}
