@testable
import Client
import TestCase
import XCTest

final class DownloadsServiceTests: URLProtocolTestCase {
  func testPost() async throws {
    let url = URL(string: "http://localhost/download")
    let data = """
      {
        "link": "http://localhost/alien"
      }
      """
      .data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: 200)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let client = Client(session: MockedURLProtocol.session)
    client.configure(baseURL: URL(string: "http://localhost/"))
    let service = DownloadsService(client: client)
    let post = try await service.post(fileID: 0)
    XCTAssertEqual(post.link?.absoluteString, "http://localhost/alien")
  }
}
