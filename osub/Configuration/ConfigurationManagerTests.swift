@testable
import Configuration
import TestCase
import XCTest

final class ConfigurationManagerConfigDirectoryTests: XCTestCase {
  func testSetsUsingTheOSUB() throws {
    let home = try FileManager.default.temporaryDirectory()
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(
        environment: [
          "OSUB_CONFIG_HOME": home.path2()
        ]
      )
    )
    XCTAssertEqual(manager.configDirectory.path2(), home.path2())
  }

  func testSetsUsingTheXDG() throws {
    let home = try FileManager.default.temporaryDirectory()
    let directory = home
      .appending2(path: "osub", isDirectory: true)
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(
        environment: [
          "XDG_CONFIG_HOME": home.path2()
        ]
      )
    )
    XCTAssertEqual(manager.configDirectory.path2(), directory.path2())
  }

  func testSetsUsingTheApplicationSupportDirectory() throws {
    let home = try FileManager.default.temporaryDirectory()
    let directory = home
      .appending2(path: "me.vanyauhalin.osub", isDirectory: true)
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(),
      fileManager: MockedFileManager(
        urls: [home]
      )
    )
    XCTAssertEqual(manager.configDirectory.path2(), directory.path2())
  }

  func testSetsUsingTheHomeDirectoryForCurrentUser() throws {
    let home = try FileManager.default.temporaryDirectory()
    let directory = home
      .appending2(path: ".config", isDirectory: true)
      .appending2(path: "osub", isDirectory: true)
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(),
      fileManager: MockedFileManager(
        homeDirectoryForCurrentUser: home
      )
    )
    XCTAssertEqual(manager.configDirectory.path2(), directory.path2())
  }
}

final class ConfigurationManagerConfigFileTests: XCTestCase {
  func testSets() {
    let manager = ConfigurationManager()
    XCTAssertEqual(manager.configFile.lastPathComponent, "config.toml")
  }
}

final class ConfigurationManagerStateDirectoryTests: XCTestCase {
  func testSetsUsingTheXDG() throws {
    let home = try FileManager.default.temporaryDirectory()
    let directory = home
      .appending2(path: "osub", isDirectory: true)
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(
        environment: [
          "XDG_STATE_HOME": home.path2()
        ]
      )
    )
    XCTAssertEqual(manager.stateDirectory.path2(), directory.path2())
  }

  func testSetsUsingTheHomeDirectoryForCurrentUser() throws {
    let home = try FileManager.default.temporaryDirectory()
    let directory = home
      .appending2(path: ".local", isDirectory: true)
      .appending2(path: "state", isDirectory: true)
      .appending2(path: "osub", isDirectory: true)
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(),
      fileManager: MockedFileManager(
        homeDirectoryForCurrentUser: home
      )
    )
    XCTAssertEqual(manager.stateDirectory.path2(), directory.path2())
  }
}

final class ConfigurationManagerDownloadsDirectoryTests: XCTestCase {
  func testSetsUsingTheXDG() throws {
    let home = try FileManager.default.temporaryDirectory()
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(
        environment: [
          "XDG_DOWNLOAD_DIR": home.path2()
        ]
      )
    )
    XCTAssertEqual(manager.downloadsDirectory.path2(), home.path2())
  }

  func testSetsUsingTheDownloadsDirectory() throws {
    let home = try FileManager.default.temporaryDirectory()
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(),
      fileManager: MockedFileManager(
        urls: [home]
      )
    )
    XCTAssertEqual(manager.downloadsDirectory.path2(), home.path2())
  }

  func testSetsUsingTheHomeDirectoryForCurrentUser() throws {
    let home = try FileManager.default.temporaryDirectory()
    let directory = home
      .appending2(path: "Downloads", isDirectory: true)
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(),
      fileManager: MockedFileManager(
        homeDirectoryForCurrentUser: home
      )
    )
    XCTAssertEqual(manager.downloadsDirectory.path2(), directory.path2())
  }
}

final class ConfigurationManagerLoadTests: XCTestCase {
  func testLoadsAnEmptyConfigurationIfItDoesNotExist() throws {
    let home = try FileManager.default.temporaryDirectory()
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(
        environment: [
          "OSUB_CONFIG_HOME": home.path2()
        ]
      )
    )
    let config = try manager.load()
    XCTAssertNil(config.apiKey)
    XCTAssertNil(config.username)
    XCTAssertNil(config.password)
  }

  func testLoadsAValidConfiguration() throws {
    let home = try FileManager.default.temporaryDirectory()
    let file = home.appending2(path: "config.toml")
    let content = """
      api_key = "xxx"
      username = "lynsey"
      password = "lawrence"
      """
    try content.write(to: file, atomically: true, encoding: .utf8)
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(
        environment: [
          "OSUB_CONFIG_HOME": home.path2()
        ]
      )
    )
    let config = try manager.load()
    XCTAssertEqual(config.apiKey, "xxx")
    XCTAssertEqual(config.username, "lynsey")
    XCTAssertEqual(config.password, "lawrence")
  }

  func testThrowsAnErrorWhenLoadingAnInvalidConfiguration() throws {
    let home = try FileManager.default.temporaryDirectory()
    let file = home.appending2(path: "config.toml")
    let content = """
      invalid
      """
    try content.write(to: file, atomically: true, encoding: .utf8)
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(
        environment: [
          "OSUB_CONFIG_HOME": home.path2()
        ]
      )
    )
    XCTAssertThrowsError(try manager.load())
  }
}

final class ConfigurationManagerWriteTests: XCTestCase {
  func testWritesTheConfiguration() throws {
    let home = (try FileManager.default.temporaryDirectory())
      .appending2(path: "non-existing-directory", isDirectory: true)
    let manager = ConfigurationManager(
      processInfo: MockedProcessInfo(
        environment: [
          "OSUB_CONFIG_HOME": home.path2()
        ]
      )
    )
    try manager.write(
      config: Configuration(
        apiKey: "xxx",
        username: "lynsey",
        password: "lawrence"
      )
    )
    let config = try manager.load()
    XCTAssertEqual(config.apiKey, "xxx")
    XCTAssertEqual(config.username, "lynsey")
    XCTAssertEqual(config.password, "lawrence")
  }
}

final class ConfigurationManagerMergeTests: XCTestCase {
  func testMergesTheConfiguration() {
    let manager = ConfigurationManager()
    let config = manager.merge(
      current: Configuration(
        apiKey: "xxx",
        username: "lynsey",
        password: "lawrence"
      ),
      with: Configuration()
    )
    XCTAssertEqual(config.apiKey, "xxx")
    XCTAssertEqual(config.username, "lynsey")
    XCTAssertEqual(config.password, "lawrence")
  }
}
