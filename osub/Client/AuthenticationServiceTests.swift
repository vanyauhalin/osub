@testable
import Client
import TestCase
import XCTest

final class AuthenticationServiceTests: URLProtocolTestCase {
  func testLogin() async throws {
    let url = URL(string: "http://localhost/login")
    let data = """
      {
        "base_url": "http://localhost/",
        "token": "www"
      }
      """
      .data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: 200)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let client = Client(session: MockedURLProtocol.session)
    client.configure(baseURL: URL(string: "http://localhost/"))
    let service = AuthenticationService(client: client)
    let login = try await service.login(username: "", password: "")
    XCTAssertEqual(login.baseURL?.absoluteString, "http://localhost/")
    XCTAssertEqual(login.token, "www")
  }

  func testLogout() async throws {
    let url = URL(string: "http://localhost/logout")
    let data = """
      {
        "message": "jackpot"
      }
      """
      .data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: 200)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let client = Client(session: MockedURLProtocol.session)
    client.configure(baseURL: URL(string: "http://localhost/"))
    let service = AuthenticationService(client: client)
    let logout = try? await service.logout()
    XCTAssertEqual(logout?.message, "jackpot")
  }
}
