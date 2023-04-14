// swiftlint:disable trailing_closure
@testable
import Command
import Configuration
import TestCase
import XCTest

final class ConfigurationGetCommandTests: XCTestCase {
  func testRuns() throws {
    let output = MockedTextOutputStream()
    var command = try ConfigurationGetCommand.parse(["api_key"])
    command.output = output
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration(
          apiKey: "xxx"
        )
      }
    )
    try command.run()
    XCTAssertEqual(
      output.string,
      """
      xxx\n
      """
    )
  }

  func testThrownAnErrorIfTheKeyIsNotSupported() throws {
    var command = try ConfigurationGetCommand.parse(["unknown"])
    XCTAssertThrowsError(try command.run())
  }
}

final class ConfigurationListCommandTests: XCTestCase {
  func testRuns() throws {
    let output = MockedTextOutputStream()
    var command = try ConfigurationListCommand.parse([])
    command.output = output
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration(
          apiKey: "xxx",
          username: "lynsey",
          password: "lawrence"
        )
      }
    )
    try command.run()
    XCTAssertEqual(
      output.string,
      """
      api_key=xxx
      username=lynsey
      password=lawrence\n
      """
    )
  }
}

final class ConfigurationLocationsCommandTests: XCTestCase {
  func testRuns() throws {
    let output = MockedTextOutputStream()
    let configDirectory = try FileManager.default.temporaryDirectory()
    let stateDirectory = try FileManager.default.temporaryDirectory()
    let downloadsDirectory = try FileManager.default.temporaryDirectory()
    var command = try ConfigurationLocationsCommand.parse([])
    command.output = output
    command.configManager = MockedConfigurationManager(
      configDirectory: configDirectory,
      stateDirectory: stateDirectory,
      downloadsDirectory: downloadsDirectory
    )
    command.run()
    XCTAssertEqual(
      output.string,
      """
      \(configDirectory.path2())
      \(stateDirectory.path2())
      \(downloadsDirectory.path2())\n
      """
    )
  }
}

final class ConfigurationSetCommandTests: XCTestCase {
  func testRuns() throws {
    let output = MockedTextOutputStream()
    var config: Configuration?
    var command = try ConfigurationSetCommand.parse(["api_key", "yyy"])
    command.output = output
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration(
          apiKey: "xxx"
        )
      },
      write: { writing in
        config = writing
      }
    )
    try command.run()
    XCTAssertEqual(config?.apiKey, "yyy")
    XCTAssertEqual(
      output.string,
      """
      The configuration key has been successfully updated.\n
      """
    )
  }

  func testThrownAnErrorIfTheKeyIsNotSupported() throws {
    var command = try ConfigurationSetCommand.parse(["unknown", "opa"])
    XCTAssertThrowsError(try command.run())
  }
}
