import Configuration
import Extensions
import Foundation

public protocol StateManagerProtocol {
  func load() throws -> State
  func write(state: State) throws
  func merge(current: State, with new: State) -> State
}

public final class StateManager: StateManagerProtocol {
  public static let shared: StateManagerProtocol = StateManager()

  private let fileManager: FileManager
  private let configManager: ConfigurationManagerProtocol

  init(
    fileManager: FileManager = .default,
    configManager: ConfigurationManagerProtocol = ConfigurationManager.shared
  ) {
    self.fileManager = fileManager
    self.configManager = configManager
  }

  var stateFile: URL {
    configManager
      .stateDirectory
      .appending2(path: "state.json")
      .absoluteURL
  }
}

// MARK: State

public struct State {
  public let baseURL: URL?
  public let token: String?

  public init(baseURL: URL? = nil, token: String? = nil) {
    self.baseURL = baseURL
    self.token = token
  }
}

extension State: Codable {
  enum CodingKeys: String, CodingKey {
    case baseURL = "base_url"
    case token
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.baseURL = try {
      guard let string = try container.decodeIfPresent(String.self, forKey: .baseURL) else {
        return nil
      }
      return URL(string: string)
    }()
    self.token = try container.decodeIfPresent(String.self, forKey: .token)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(baseURL?.absoluteString, forKey: .baseURL)
    try container.encode(token, forKey: .token)
  }
}

extension StateManager {
  public func load() throws -> State {
    guard
      let string = try? String(contentsOf: stateFile),
      let data = string.data(using: .utf8)
    else {
      return State()
    }
    return try JSONDecoder().decode(State.self, from: data)
  }

  public func write(state: State) throws {
    let data = try JSONEncoder().encode(state)
    let path = stateFile.path2()
    if fileManager.fileExists(atPath: path) {
      let string = String(data: data, encoding: .utf8)
      try string?.write(toFile: path, atomically: true, encoding: .utf8)
      return
    }
    try fileManager.createDirectory(
      at: configManager.stateDirectory,
      withIntermediateDirectories: true
    )
    guard fileManager.createFile(atPath: path, contents: data) else {
      throw URLError(.callIsActive)
    }
  }

  public func merge(current: State, with new: State) -> State {
    State(
      baseURL: new.baseURL ?? current.baseURL,
      token: new.token ?? current.token
    )
  }
}
