import Extensions
@testable
import Hash
import XCTest

final class HashTests: XCTestCase {
  func testHashesAValidFile() throws {
    let file = URL(filePath2: #file)
      .deletingLastPathComponent()
      .appending2(path: "Fixtures", isDirectory: true)
      .appending2(path: "file")
      .path2()
    let hash = try Hash.hash(of: file)
    XCTAssertEqual(hash, "c97e8b1573a25396")
  }

  func testThrowsAnErrorWhenTheFileDoesNotExist() {
    XCTAssertThrowsError(try Hash.hash(of: ""))
  }

  func testThrowsAnErrorWhenTheFileSizeIsBelowTheMinimum() {
    let file = URL(filePath2: #file)
      .deletingLastPathComponent()
      .appending2(path: "Fixtures", isDirectory: true)
      .appending2(path: "small-file")
      .path2()
    XCTAssertThrowsError(try Hash.hash(of: file))
  }
}
