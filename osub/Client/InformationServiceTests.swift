// swiftlint:disable xct_specific_matcher
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
          "allowed_downloads": 100,
          "level": "Sub leecher",
          "user_id": 66,
          "ext_installed": false,
          "vip": false,
          "downloads_count": 1,
          "remaining_downloads": 99
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
    XCTAssertEqual(user.data.allowedDownloads, 100)
    XCTAssertEqual(user.data.level, "Sub leecher")
    XCTAssertEqual(user.data.userID, 66)
    XCTAssertEqual(user.data.extInstalled, false)
    XCTAssertEqual(user.data.vip, false)
    XCTAssertEqual(user.data.downloadsCount, 1)
    XCTAssertEqual(user.data.remainingDownloads, 99)
  }
}
