// swiftlint:disable force_unwrapping
@testable
import Client
import TestCase
import XCTest

final class ClientInitializationTests: XCTestCase {
  func testConfigures() {
    let client = Client()
    client.configure(
      apiKey: "xxx",
      baseURL: URL(string: "http://localhost/"),
      token: "www"
    )
    XCTAssertEqual(client.apiKey, "xxx")
    XCTAssertEqual(client.baseURL?.absoluteString, "http://localhost/")
    XCTAssertEqual(client.token, "www")
  }

  func testConfiguresWithDefaults() {
    let client = Client(
      bundle: MockedBundle(infoDictionary: [
        "API_KEY": "xxx"
      ])
    )
    client.configure()
    XCTAssertEqual(client.apiKey, "xxx")
    XCTAssertEqual(client.baseURL?.absoluteString, "https://api.opensubtitles.com/api/v1/")
    XCTAssertNil(client.token)
  }
}

final class ClientURLTests: XCTestCase {
  func testCreatesAURLRelativeToTheBaseURL() throws {
    let client = Client()
    client.configure(baseURL: URL(string: "http://localhost/"))
    let url = try client.url(path: "tango")
    XCTAssertEqual(url.absoluteString, "http://localhost/tango")
  }

  func testCreatesAURLWithQueryItemsRelativeToTheBaseURL() throws {
    let client = Client()
    client.configure(baseURL: URL(string: "http://localhost/"))
    let url = try client.url(path: "tango", with: [
      URLQueryItem(name: "cost", value: "90")
    ])
    XCTAssertEqual(url.absoluteString, "http://localhost/tango?%26&cost=90")
  }
}

final class ClientRequestTests: XCTestCase {
  func testCreatesARequest() throws {
    let client = Client()
    client.configure(
      apiKey: "xxx",
      baseURL: URL(string: "http://localhost/"),
      token: "www"
    )
    let url = try client.url(path: "tango")
    let request = client.request(url: url)
    XCTAssertEqual(request.url?.absoluteString, "http://localhost/tango")
    XCTAssertEqual(request.value(forHTTPHeaderField: "accept"), "*/*")
    XCTAssertEqual(request.value(forHTTPHeaderField: "api-key"), "xxx")
    XCTAssertEqual(request.value(forHTTPHeaderField: "authorization"), "Bearer www")
    XCTAssertEqual(request.value(forHTTPHeaderField: "content-type"), "application/json")
  }
}

final class ClientEntityTests: URLProtocolTestCase {
  func testRequestsAnEntity() async throws {
    let url = URL(string: "http://localhost/")!
    let data = """
      {
        "key": "value"
      }
      """
      .data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: 200)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let client = Client(session: MockedURLProtocol.session)
    let request = URLRequest(url: url)
    let entity = try await client.entity(DemoEntity.self, from: request)
    XCTAssertEqual(entity.key, "value")
  }

  func testThrowsAnErrorWithInformationIfTheEntityCouldNotBeRequested() async {
    let url = URL(string: "http://localhost/")!
    let data = """
      {
        "message": "misfortune"
      }
      """
      .data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: .zero)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let client = Client(session: MockedURLProtocol.session)
    let request = URLRequest(url: url)
    do {
      _ = try await client.entity(DemoEntity.self, from: request)
      XCTFail()
    } catch ClientError.cannotDecodeEntity(let status, let info) {
      XCTAssertEqual(status?.rawValue, .zero)
      XCTAssertEqual(info?.message, "misfortune")
    } catch {
      XCTFail()
    }
  }

  func testThrowsAnErrorWithoutInformationIfTheEntityCouldNotBeRequested() async {
    let url = URL(string: "http://localhost/")!
    let data = """
      """
      .data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: 420)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let client = Client(session: MockedURLProtocol.session)
    let request = URLRequest(url: url)
    do {
      _ = try await client.entity(DemoEntity.self, from: request)
      XCTFail()
    } catch ClientError.cannotDecodeEntity(let status, let info) {
      XCTAssertNil(status)
      XCTAssertNil(info)
    } catch {
      XCTFail()
    }
  }
}

struct DemoEntity: Decodable {
  let key: String
}
