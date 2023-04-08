@testable
import Command
import TestCase
import XCTest

final class VersionCommandTests: XCTestCase {
  func test() throws {
    var command = try VersionCommand.parse([])
    command.bundle = MockedBundle(infoDictionary: ["CFBundleVersion": "0.1.0"])
    XCTAssertEqual(command.version, "0.1.0")
  }
}
