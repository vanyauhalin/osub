import ArgumentParser
import Configuration
import Extensions
import Listable
import State

struct ConfigurationCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "config",
    abstract: "Manage configuration.",
    subcommands: [
      ConfigurationGetCommand.self,
      ConfigurationListCommand.self,
      ConfigurationLocationsCommand.self,
      ConfigurationSetCommand.self
    ]
  )
}

struct ConfigurationGetCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "get",
    abstract: "Print the value of the given configuration key."
  )

  @Argument(help: "The configuration key.")
  var key: Configuration.CodingKeys

  var output = StandardTextOutputStream.shared
  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared

  mutating func run() throws {
    let config = try configManager.load()

    let mirror = Mirror(reflecting: config)
    let keyLabel = {
      switch key {
      case .apiKey:
        return "apiKey"
      case .username:
        return "username"
      case .password:
        return "password"
      }
    }()
    guard
      let child = mirror.children.first(where: { label, _ in
        label == keyLabel
      })
    else {
      throw ConfigurationCommandError.cannotGet
    }

    if case Optional<Any>.none = child.value {
      print("", to: &output)
    } else if let string = child.value as? String {
      print(string, to: &output)
    }
  }
}

extension ConfigurationGetCommand {
  enum CodingKeys: CodingKey {
    case key
  }
}

struct ConfigurationListCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "list",
    abstract: "Print a list of configuration keys and values."
  )

  var output = StandardTextOutputStream.shared
  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared

  mutating func run() throws {
    let config = try configManager.load()
    print(config.description.isEmpty ? "" : config, to: &output)
  }
}

extension ConfigurationListCommand {
  init(from decoder: Decoder) throws {}
}

struct ConfigurationLocationsCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "locations",
    abstract: "Print a locations used by osub."
  )

  var output = StandardTextOutputStream.shared
  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared

  mutating func run() {
    print(configManager.configDirectory.path2(), to: &output)
    print(configManager.stateDirectory.path2(), to: &output)
    print(configManager.downloadsDirectory.path2(), to: &output)
  }
}

extension ConfigurationLocationsCommand {
  init(from decoder: Decoder) throws {}
}

struct ConfigurationSetCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "set",
    abstract: "Update the configuration with a value for the given key."
  )

  @Argument(help: "The configuration key.")
  var key: Configuration.CodingKeys

  @Argument(help: "The value of the configuration key.")
  var value: String

  var output = StandardTextOutputStream.shared
  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared

  mutating func run() throws {
    let config = try configManager.load()

    try configManager.write(
      config: configManager.merge(
        current: config,
        with: {
          switch key {
          case .apiKey:
            return Configuration(apiKey: value)
          case .username:
            return Configuration(username: value)
          case .password:
            return Configuration(password: value)
          }
        }()
      )
    )

    print("The configuration key has been successfully updated.", to: &output)
  }
}

extension ConfigurationSetCommand {
  enum CodingKeys: CodingKey {
    case key
    case value
  }
}

// MARK: Error

enum ConfigurationCommandError: Error {
  case cannotGet
}

extension ConfigurationCommandError: CustomStringConvertible {
  var description: String {
    switch self {
    case .cannotGet:
      return "The configuration key hasn't been get."
    }
  }
}

// MARK: Extensions

extension Configuration: Listable {}

extension Configuration.CodingKeys: CaseIterable, ExpressibleByArgument {
  public static var allCases: [Configuration.CodingKeys] {
    [
      .apiKey,
      .username,
      .password
    ]
  }
}
