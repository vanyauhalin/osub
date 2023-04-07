@testable
import Client
import TestCase
import XCTest

final class InformationServiceTests: URLProtocolTestCase {
  func testLanguages() async throws {
    let url = URL(string: "http://localhost/infos/languages")
    let data = """
      {
        "data": [
          {
            "language_code": "en",
            "language_name": "English"
          }
        ]
      }
      """
      .data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: 200)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let client = Client(session: MockedURLProtocol.session)
    client.configure(baseURL: URL(string: "http://localhost/"))
    let service = InformationService(client: client)
    let languages = try await service.languages()
    XCTAssertEqual(languages.data[0].languageCode, "en")
    XCTAssertEqual(languages.data[0].languageName, "English")
  }

  func testUser() async throws {
    let url = URL(string: "http://localhost/infos/user")
    let data = """
      {
        "data": {
          "user_id": 9000,
          "remaining_downloads": 20
        }
      }
      """
      .data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: 200)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let client = Client(session: MockedURLProtocol.session)
    client.configure(baseURL: URL(string: "http://localhost/"))
    let service = InformationService(client: client)
    let user = try await service.user()
    XCTAssertEqual(user.data.userID, 9000)
    XCTAssertEqual(user.data.remainingDownloads, 20)
  }
}
