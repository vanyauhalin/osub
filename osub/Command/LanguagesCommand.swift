import ArgumentParser
import Client
import Configuration
import State

struct LanguagesCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "languages",
    abstract: "Print a list of languages for subtitles.",
    usage: "osub languages <options>"
  )

  @OptionGroup(title: "Formatting Options")
  var formatting: FormattingOptions<Field>

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
    let languages = try await client.info.languages()

    var printer = formatting.printer(output: output)
    languages.data.enumerated().forEach { index, language in
      formatting.fields.forEach { field in
        switch field {
        case .name:
          printer.append(language.languageName)
        case .subtag:
          printer.append(language.languageCode)
        }
      }
      if index < languages.data.count - 1 {
        printer.next()
      }
    }
    printer.print()
  }
}

extension LanguagesCommand {
  enum CodingKeys: CodingKey {
    case formatting
  }

  enum Field: String, FormattingField {
    case name
    case subtag

    static var defaultValues: [Self] {
      [
        .subtag,
        .name
      ]
    }

    var text: String {
      rawValue
    }
  }
}
