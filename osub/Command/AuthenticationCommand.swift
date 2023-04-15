import ArgumentParser
import Client
import Configuration
import Listable
import State

struct AuthenticationCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "auth",
    abstract: "Manage authentication.",
    subcommands: [
      AuthenticationListCommand.self,
      AuthenticationLoginCommand.self,
      AuthenticationLogoutCommand.self,
      AuthenticationRefreshCommand.self,
      AuthenticationStatusCommand.self
    ]
  )
}

struct AuthenticationListCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "list",
    abstract: "Print a list of authentication keys and values."
  )

  var output = StandardTextOutputStream.shared
  var stateManager: StateManagerProtocol = StateManager.shared

  mutating func run() throws {
    let state = try stateManager.load()
    print(state.description.isEmpty ? "" : state, to: &output)
  }
}

extension AuthenticationListCommand {
  init(from decoder: Decoder) throws {}
}

struct AuthenticationLoginCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "login",
    abstract: "Login by generating an authentication token."
  )

  @Argument(help: "The account name.")
  var username: String

  @Argument(help: "The account password.")
  var password: String

  var output = StandardTextOutputStream.shared
  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared
  var stateManager: StateManagerProtocol = StateManager.shared
  var client: ClientProtocol = Client.shared

  mutating func run() async throws {
    let (config, state) = try configure()
    try await action(config: config, state: state)
  }

  func configure() throws -> (Configuration, State) {
    let config = try configManager.load()
    let state = try stateManager.load()
    client.configure(config: config, state: state)
    return (config, state)
  }

  mutating func action(config: Configuration, state: State) async throws {
    let login = try await client.auth.login(
      username: username,
      password: password
    )
    try configManager.write(
      config: configManager.merge(
        current: config,
        with: Configuration(
          username: username,
          password: password
        )
      )
    )
    try stateManager.write(
      state: stateManager.merge(
        current: state,
        with: State(
          baseURL: login.baseURL,
          token: login.token
        )
      )
    )
    print(
      "The authentication token has been successfully generated.",
      to: &output
    )
  }
}

extension AuthenticationLoginCommand {
  enum CodingKeys: CodingKey {
    case username
    case password
  }
}

struct AuthenticationLogoutCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "logout",
    abstract: "Logout by destroying the authentication token."
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
    let logout = try await client.auth.logout()
    try stateManager.write(state: State())

    print(
      "The authentication token has been successfully destroyed.",
      to: &output
    )
    if let message = logout.message {
      print(message, to: &output)
    }
  }
}

extension AuthenticationLogoutCommand {
  init(from decoder: Decoder) throws {}
}

struct AuthenticationRefreshCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "refresh",
    abstract: "Refresh the authentication token."
  )

  var output = StandardTextOutputStream.shared
  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared
  var stateManager: StateManagerProtocol = StateManager.shared
  var client: ClientProtocol = Client.shared

  mutating func run() async throws {
    let (config, state) = try configure()
    try await action(config: config, state: state)
  }

  func configure() throws -> (Configuration, State) {
    let config = try configManager.load()
    let state = try stateManager.load()
    client.configure(config: config, state: state)
    return (config, state)
  }

  mutating func action(config: Configuration, state: State) async throws {
    guard
      let username = config.username,
      let password = config.password
    else {
      throw AuthenticationCommandError.cannotRefreshToken
    }

    let login = try await client.auth.login(
      username: username,
      password: password
    )
    try stateManager.write(
      state: stateManager.merge(
        current: state,
        with: State(
          baseURL: login.baseURL,
          token: login.token
        )
      )
    )

    print(
      "The authentication token has been successfully refreshed.",
      to: &output
    )
  }
}

extension AuthenticationRefreshCommand {
  init(from decoder: Decoder) throws {}
}

struct AuthenticationStatusCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "status",
    abstract: "Print authentication status.",
    usage: "osub auth status <options>"
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
    let user = try await client.info.user()

    var printer = formatting.printer(output: output)
    formatting.fields.forEach { field in
      switch field {
      case .allowedDownloads:
        printer.append(user.data.allowedDownloads)
      case .downloadsCount:
        printer.append(user.data.downloadsCount)
      case .extInstalled:
        printer.append(user.data.extInstalled)
      case .level:
        printer.append(user.data.level)
      case .remainingDownloads:
        printer.append(user.data.remainingDownloads)
      case .userID:
        printer.append(user.data.userID)
      case .vip:
        printer.append(user.data.vip)
      }
    }
    printer.print()
  }
}

extension AuthenticationStatusCommand {
  enum CodingKeys: CodingKey {
    case formatting
  }

  enum Field: String, FormattingField {
    case allowedDownloads = "allowed_downloads"
    case downloadsCount = "downloads_count"
    case extInstalled = "ext_installed"
    case level
    case remainingDownloads = "remaining_downloads"
    case userID = "user_id"
    case vip

    static var defaultValues: [Self] {
      [
        .userID,
        .remainingDownloads,
        .allowedDownloads,
        .level
      ]
    }

    var text: String {
      switch self {
      case .allowedDownloads:
        return "allowed downloads"
      case .downloadsCount:
        return "downloads"
      case .extInstalled:
        return "extension installed"
      case .level:
        return rawValue
      case .remainingDownloads:
        return "remaining downloads"
      case .userID:
        return "user id"
      case .vip:
        return rawValue
      }
    }
  }
}

// MARK: Error

enum AuthenticationCommandError: Error {
  case cannotRefreshToken
}

extension AuthenticationCommandError: CustomStringConvertible {
  var description: String {
    switch self {
    case .cannotRefreshToken:
      // swiftlint:disable:next line_length
      return "The authentication token hasn't been refreshed. Ensure that the user credentials exist."
    }
  }
}

// MARK: Extensions

extension State: Listable {}
