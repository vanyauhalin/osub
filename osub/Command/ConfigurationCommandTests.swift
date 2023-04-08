// swiftlint:disable trailing_closure
@testable
import Command
import Configuration
import TestCase
import XCTest

final class ConfigurationGetCommandTests: XCTestCase {
  func testGets() throws {
    var command = try ConfigurationGetCommand.parse(["api_key"])
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration(
          apiKey: "xxx"
        )
      }
    )
    try command.run()
    XCTAssertEqual(command.value as? String, "xxx")
  }

  func testThrownAnErrorIfTheKeyIsNotSupported() throws {
    var command = try ConfigurationGetCommand.parse(["unknown"])
    XCTAssertThrowsError(try command.run())
  }
}

final class ConfigurationSetCommandTests: XCTestCase {
  func testSets() throws {
    var command = try ConfigurationSetCommand.parse(["api_key", "yyy"])
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration(
          apiKey: "xxx"
        )
      }
    )
    try command.run()
    XCTAssertEqual(command.config?.apiKey, "yyy")
  }

  func testThrownAnErrorIfTheKeyIsNotSupported() throws {
    var command = try ConfigurationSetCommand.parse(["unknown", "opa"])
    XCTAssertThrowsError(try command.run())
  }
}
