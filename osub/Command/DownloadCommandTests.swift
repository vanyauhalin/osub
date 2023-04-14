// swiftlint:disable trailing_closure
import Client
@testable
import Command
import Configuration
import Downloads
import State
import TestCase
import XCTest

final class DownloadCommandTests: XCTestCase {
  func testRuns() async throws {
    let output = MockedTextOutputStream()
    var command = try DownloadCommand.parse(["--file-id", "9000"])
    command.output = output
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration()
      }
    )
    command.stateManager = MockedStateManager(
      load: {
        State()
      }
    )
    command.downloadsManager = MockedDownloadsManager(
      download: {
        URL(filePath2: "/Downloads")
      }
    )
    command.client = MockedClient(
      downloads: MockedDownloadsService(
        post: {
          DownloadEntity(
            link: URL(string: "http://localhost/login")
          )
        }
      )
    )
    try await command.run()
    XCTAssertEqual(
      output.string,
      """
      The subtitles have been successfully downloaded to /Downloads\n
      """
    )
  }

  func testThrowsAnErrorIfTheFileURLDoesNotExist() async throws {
    var command = try DownloadCommand.parse(["--file-id", "9000"])
    command.configManager = MockedConfigurationManager(
      load: {
        Configuration()
      }
    )
    command.stateManager = MockedStateManager(
      load: {
        State()
      }
    )
    command.client = MockedClient(
      downloads: MockedDownloadsService(
        post: {
          DownloadEntity()
        }
      )
    )
    do {
      try await command.run()
      XCTFail()
    } catch {}
  }
}
