import Extensions
import Foundation
import TOMLKit

public protocol ConfigurationManagerProtocol {
  var configDirectory: URL { get }
  var stateDirectory: URL { get }
  var downloadsDirectory: URL { get }
  func load() throws -> Configuration
  func write(config: Configuration) throws
  func merge(current: Configuration, with new: Configuration) -> Configuration
}

public final class ConfigurationManager: ConfigurationManagerProtocol {
  public static let shared: ConfigurationManagerProtocol = ConfigurationManager()

  private let organizationName = "me.vanyauhalin"
  private let organizationShortName = "vanyauhalin"
  private let name = "osub"
  private let fullName = "OpenSubtitles CLI"
  private let bundleIdentifier = "me.vanyauhalin.osub"

  private let processInfo: ProcessInfo
  private let fileManager: FileManager

  init(
    processInfo: ProcessInfo = .processInfo,
    fileManager: FileManager = .default
  ) {
    self.processInfo = processInfo
    self.fileManager = fileManager
  }

  public var configDirectory: URL {
    if let path = processInfo.nonEmptyEnvironment("OSUB_CONFIG_HOME") {
      return URL(filePath2: path)
        .absoluteURL
    }

    if let path = processInfo.nonEmptyEnvironment("XDG_CONFIG_HOME") {
      return URL(filePath2: path)
        .appending2(path: name, isDirectory: true)
        .absoluteURL
    }

    // #if os(macOS)
    if
      let url = fileManager
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .first,
      !url.path2().isEmpty
    {
      return url
        .appending2(path: bundleIdentifier, isDirectory: true)
        .absoluteURL
    }
    // #endif

    // #if os(Windows)
    // if let path = processInfo.nonEmptyEnvironment("AppData") {
    //   return URL(filePath2: path)
    //     .appending2(path: organizationShortName, isDirectory: true)
    //     .appending2(path: fullName, isDirectory: true)
    // }
    // #endif

    // #if os(macOS) || os(Linux)
    // if let path = processInfo.nonEmptyEnvironment("HOME") {
    //   return URL(filePath2: path)
    //     .appending2(path: ".config", isDirectory: true)
    //     .appending2(path: name, isDirectory: true)
    // }
    // #endif

    // #if os(Windows)
    // if let path = processInfo.nonEmptyEnvironment("USERPROFILE") {
    //   return URL(filePath2: path)
    //     .appending2(path: ".config", isDirectory: true)
    //     .appending2(path: name, isDirectory: true)
    // }
    // #endif

    return fileManager
      .homeDirectoryForCurrentUser
      .appending2(path: ".config", isDirectory: true)
      .appending2(path: name, isDirectory: true)
      .absoluteURL
  }

  var configFile: URL {
    configDirectory
      .appending2(path: "config.toml")
      .absoluteURL
  }

  public var stateDirectory: URL {
    if let path = processInfo.nonEmptyEnvironment("XDG_STATE_HOME") {
      return URL(filePath2: path)
        .appending2(path: name, isDirectory: true)
        .absoluteURL
    }

    // #if os(Windows)
    // if let path = processInfo.nonEmptyEnvironment("LocalAppData") {
    //   return URL(filePath2: path)
    //     .appending2(path: organizationShortName, isDirectory: true)
    //     .appending2(path: fullName, isDirectory: true)
    // }
    // #endif

    // #if os(macOS) || os(Linux)
    // if let path = processInfo.nonEmptyEnvironment("HOME") {
    //   return URL(filePath2: path)
    //     .appending2(path: ".local", isDirectory: true)
    //     .appending2(path: "state", isDirectory: true)
    //     .appending2(path: name, isDirectory: true)
    // }
    // #endif

    // #if os(Windows)
    // if let path = processInfo.nonEmptyEnvironment("USERPROFILE") {
    //   return URL(filePath2: path)
    //     .appending2(path: ".config", isDirectory: true)
    //     .appending2(path: name, isDirectory: true)
    // }
    // #endif

    return fileManager
      .homeDirectoryForCurrentUser
      .appending2(path: ".local", isDirectory: true)
      .appending2(path: "state", isDirectory: true)
      .appending2(path: name, isDirectory: true)
      .absoluteURL
  }

  public var downloadsDirectory: URL {
    if let path = processInfo.nonEmptyEnvironment("XDG_DOWNLOAD_DIR") {
      return URL(filePath2: path)
        .absoluteURL
    }

    // #if os(macOS)
    if
      let url = fileManager
        .urls(for: .downloadsDirectory, in: .userDomainMask)
        .first,
      !url.path2().isEmpty
    {
      return url
        .absoluteURL
    }
    // #endif

    return fileManager
      .homeDirectoryForCurrentUser
      .appending2(path: "Downloads", isDirectory: true)
      .absoluteURL
  }
}

// MARK: Configuration

public struct Configuration {
  public let apiKey: String?
  public let username: String?
  public let password: String?

  public init(
    apiKey: String? = nil,
    username: String? = nil,
    password: String? = nil
  ) {
    self.apiKey = apiKey
    self.username = username
    self.password = password
  }
}

extension Configuration: Codable {
  public enum CodingKeys: String, CodingKey {
    case apiKey = "api_key"
    case username
    case password
  }
}

extension ConfigurationManager {
  public func load() throws -> Configuration {
    guard let string = try? String(contentsOf: configFile) else {
      return Configuration()
    }
    return try TOMLDecoder().decode(Configuration.self, from: string)
  }

  public func write(config: Configuration) throws {
    let string = try TOMLEncoder().encode(config)
    let path = configFile.path2()
    if fileManager.fileExists(atPath: path) {
      try string.write(toFile: path, atomically: true, encoding: .utf8)
      return
    }
    try fileManager.createDirectory(
      at: configDirectory,
      withIntermediateDirectories: true
    )
    let data = string.data(using: .utf8)
    guard fileManager.createFile(atPath: path, contents: data) else {
      throw URLError(.callIsActive)
    }
  }

  public func merge(current: Configuration, with new: Configuration) -> Configuration {
    Configuration(
      apiKey: new.apiKey ?? current.apiKey,
      username: new.username ?? current.username,
      password: new.password ?? current.password
    )
  }
}

// MARK: Extensions

extension ProcessInfo {
  func nonEmptyEnvironment(_ name: String) -> String? {
    guard
      let variable = environment[name],
      !variable.isEmpty
    else {
      return nil
    }
    return variable
  }
}
