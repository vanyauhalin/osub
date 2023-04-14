@testable
import Command
import TestCase
import XCTest

final class HashCommandTests: XCTestCase {
  func testRuns() throws {
    let output = MockedTextOutputStream()
    let file = URL(filePath2: #file)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending2(path: "Hash", isDirectory: true)
      .appending2(path: "Fixtures", isDirectory: true)
      .appending2(path: "file")
      .path2()
    var command = try HashCommand.parse([file])
    command.output = output
    try command.run()
    XCTAssertEqual(
      output.string,
      """
      c97e8b1573a25396\n
      """
    )
  }
}
