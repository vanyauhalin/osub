@testable
import Client
import Foundation
import XCTest

final class ServiceTests: XCTestCase {
  func testThrowsAnErrorWhenTheClientIsUnavailable() {
    let service = DemoService()
    XCTAssertThrowsError(try service.refer())
  }
}

final class DemoService: Service {
  var client: ClientProtocol?

  init(client: ClientProtocol? = nil) {
    self.client = client
  }
}
