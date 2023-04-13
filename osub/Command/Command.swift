import ArgumentParser
import Client
import Configuration
import State

public struct Command: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "osub",
    subcommands: [
      AuthenticationCommand.self,
      ConfigurationCommand.self,
      DownloadCommand.self,
      HashCommand.self,
      LanguagesCommand.self,
      SearchCommand.self,
      VersionCommand.self
    ],
    defaultSubcommand: SearchCommand.self
  )

  public init() {}
}

// MARK: Extensions

extension ClientProtocol {
  func configure(config: Configuration, state: State) {
    self.configure(
      apiKey: config.apiKey,
      baseURL: state.baseURL,
      token: state.token
    )
  }
}

indirect enum ValueName {
  case array(ValueName)
  case `enum`
  case int
  case path
  case string

  var rawValue: String {
    switch self {
    case .array(let valueName):
      return "[\(valueName.rawValue)]"
    case .enum:
      return "enum"
    case .int:
      return "int"
    case .path:
      return "path"
    case .string:
      return "string"
    }
  }
}

extension ArgumentHelp {
  init(
    _ abstract: String = "",
    discussion: String = "",
    valueName: ValueName? = nil
  ) {
    self.init(
      abstract,
      discussion: discussion,
      valueName: valueName?.rawValue
    )
  }
}
