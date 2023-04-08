@testable
import Listable
import XCTest

final class ListableTests: XCTestCase {
  func testDescription() {
    let demo = DemoListable(first: "a", second: nil, third: "c")
    XCTAssertEqual(
      demo.description,
      """
      first=a
      third=c
      """
    )
  }
}

struct DemoListable: Listable {
  let first: String
  let second: String?
  let third: String
}
