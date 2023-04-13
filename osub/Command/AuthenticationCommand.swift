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

  var stateManager: StateManagerProtocol = StateManager.shared

  mutating func run() throws {
    let state = try stateManager.load()
    print(state.description.isEmpty ? "" : state)
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

  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared
  var stateManager: StateManagerProtocol = StateManager.shared
  var client: ClientProtocol = Client.shared

  var config: Configuration?
  var state: State?

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

    let newConfig = configManager.merge(
      current: config,
      with: Configuration(
        username: username,
        password: password
      )
    )
    try configManager.write(config: newConfig)
    self.config = newConfig

    let newState = stateManager.merge(
      current: state,
      with: State(
        baseURL: login.baseURL,
        token: login.token
      )
    )
    try stateManager.write(state: newState)
    self.state = newState

    print("The authentication token has been successfully generated.")
  }
}

extension AuthenticationLoginCommand {
  enum CodingKeys: String, CodingKey {
    case username
    case password
  }
}

struct AuthenticationLogoutCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "logout",
    abstract: "Logout by destroying the authentication token."
  )

  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared
  var stateManager: StateManagerProtocol = StateManager.shared
  var client: ClientProtocol = Client.shared

  var state: State?

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

    let newState = State()
    try stateManager.write(state: newState)
    self.state = newState

    print("The authentication token has been successfully destroyed.")
    print(logout.message)
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

  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared
  var stateManager: StateManagerProtocol = StateManager.shared
  var client: ClientProtocol = Client.shared

  var state: State?

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

    let newState = stateManager.merge(
      current: state,
      with: State(
        baseURL: login.baseURL,
        token: login.token
      )
    )
    try stateManager.write(state: newState)
    self.state = newState

    print("The authentication token has been successfully refreshed.")
  }
}

extension AuthenticationRefreshCommand {
  init(from decoder: Decoder) throws {}
}

struct AuthenticationStatusCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "status",
    abstract: "Print authentication status."
  )

  @OptionGroup(title: "Formatting Options")
  var formatting: FormattingOptions<Field>

  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared
  var stateManager: StateManagerProtocol = StateManager.shared
  var client: ClientProtocol = Client.shared

  var user: DatumedEntity<User>?

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
    self.user = user

    var printer = formatting.printer()
    formatting.fields.forEach { field in
      switch field {
      case .remainingDownloads:
        printer.append(user.data.remainingDownloads)
      case .userID:
        printer.append(user.data.userID)
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
    case remainingDownloads = "remaining_downloads"
    case userID = "user_id"

    static var defaultValues: [Self] {
      [
        .userID,
        .remainingDownloads
      ]
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
