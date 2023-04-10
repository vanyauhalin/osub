import ArgumentParser
import Client
import Configuration
import State
import TablePrinter

struct LanguagesCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "languages",
    abstract: "Print a list of languages for subtitles."
  )

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
    let languages = try await client.info.languages()

    var printer = TablePrinter()
    printer.append(Field(header: "subtag", truncatable: false))
    printer.append(Field(header: "name"))
    printer.next()

    languages.data.forEach { language in
      printer.append(language.languageCode)
      printer.append(language.languageName)
      printer.next()
    }

    printer.print()
  }
}

extension LanguagesCommand {
  init(from decoder: Decoder) throws {}
}
