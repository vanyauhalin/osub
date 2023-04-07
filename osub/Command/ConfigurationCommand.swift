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
  var key: String

  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared

  var value: Any?

  mutating func run() throws {
    guard let key = Configuration.CodingKeys(rawValue: key) else {
      throw ConfigurationCommandError.cannotGet
    }

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

    self.value = child.value

    if case Optional<Any>.none = child.value {
      print()
    } else {
      print(child.value)
    }
  }
}

extension ConfigurationGetCommand {
  enum CodingKeys: String, CodingKey {
    case key
  }
}

struct ConfigurationListCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "list",
    abstract: "Print a list of configuration keys and values."
  )

  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared

  mutating func run() throws {
    let config = try configManager.load()
    print(config.description.isEmpty ? "" : config)
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

  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared

  func run() throws {
    print(configManager.configDirectory.path2())
    print(configManager.stateDirectory.path2())
    print(configManager.downloadsDirectory.path2())
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
  var key: String

  @Argument(help: "The value of the configuration key.")
  var value: String

  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared

  var config: Configuration?

  mutating func run() throws {
    guard let key = Configuration.CodingKeys(rawValue: key) else {
      throw ConfigurationCommandError.cannotSet
    }

    let config = try configManager.load()
    let newConfig = configManager.merge(
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
    try configManager.write(config: newConfig)
    self.config = newConfig

    print("The configuration key has been successfully updated.")
  }
}

extension ConfigurationSetCommand {
  enum CodingKeys: String, CodingKey {
    case key
    case value
  }
}

// MARK: Error

enum ConfigurationCommandError: Error {
  case cannotGet
  case cannotSet
}

extension ConfigurationCommandError {
  var supportedKeys: String {
    let keys = Configuration.CodingKeys.allCases
      .map { item in
        item.stringValue
      }
      .joined(separator: ", ")
    return "List of supported keys: \(keys)."
  }
}

extension ConfigurationCommandError: CustomStringConvertible {
  var description: String {
    switch self {
    case .cannotGet:
      return "The configuration key hasn't been get. Ensure the key is supported.\n\(supportedKeys)"
    case .cannotSet:
      return "The configuration key hasn't been set. Ensure the key is supported.\n\(supportedKeys)"
    }
  }
}

// MARK: Extensions

extension Configuration: Listable {}

extension Configuration.CodingKeys: CaseIterable {
  public static var allCases: [Configuration.CodingKeys] {
    [.apiKey, .username, .password]
  }
}
