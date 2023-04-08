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
