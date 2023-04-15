@testable
import Command
import TestCase
import XCTest

final class VersionCommandTests: XCTestCase {
  func testRuns() throws {
    let output = MockedTextOutputStream()
    var command = try VersionCommand.parse([])
    command.bundle = MockedBundle(infoDictionary: ["CFBundleVersion": "0.2.0"])
    command.output = output
    command.run()
    XCTAssertEqual(
      output.string,
      """
      0.2.0
      https://github.com/vanyauhalin/osub/releases/tag/v0.2.0\n
      """
    )
  }
}
