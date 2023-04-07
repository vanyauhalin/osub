// swiftlint:disable force_unwrapping
@testable
import Downloads
import Foundation
import TestCase
import XCTest

final class DownloadsManagerTests: URLProtocolTestCase {
  func testDownloads() async throws {
    let url = URL(string: "http://localhost/file.txt")!
    let data = "content".data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: 200)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let directory = try FileManager.default.temporaryDirectory()
    let file = directory.appending2(path: "file.txt")
    let manager = DownloadsManager(
      session: MockedURLProtocol.session,
      configManager: MockedConfigurationManager(
        downloadsDirectory: directory
      )
    )
    let dist = try await manager.download(from: url)
    let content = try String(contentsOfFile: dist.path2())
    XCTAssertEqual(dist.path2(), file.path2())
    XCTAssertEqual(content, "content")
  }

  func testThrowsAnErrorThenAFileWithTheSameNameAlreadyExists() async throws {
    let url = URL(string: "http://localhost/file.txt")!
    let data = "content".data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: 200)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let directory = try FileManager.default.temporaryDirectory()
    let file = directory.appending2(path: "file.txt")
    try data?.write(to: file)
    let manager = DownloadsManager(
      session: MockedURLProtocol.session,
      configManager: MockedConfigurationManager(
        downloadsDirectory: directory
      )
    )
    do {
      _ = try await manager.download(from: url)
      XCTFail()
    } catch {}
  }
}
