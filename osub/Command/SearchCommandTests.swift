// swiftlint:disable trailing_closure
import Client
@testable
import Command
import Configuration
import State
import TestCase
import XCTest

final class SearchSubtitlesCommandTests: XCTestCase {
  func testRuns() async throws {
    let output = MockedTextOutputStream()
    var command = try SearchSubtitlesCommand.parse(["--no-frame"])
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
    command.client = MockedClient(
      search: MockedSearchService(
        subtitles: {
          PaginatedEntity(
            data: [
              AttributedEntity(
                id: 171510,
                attributes: SubtitlesEntity(
                  downloadCount: 57706,
                  files: [
                    File(
                      fileID: 171816,
                      fileName: "Aliens.1986.Special.Edition"
                    )
                  ],
                  language: "en",
                  uploadDate: "2010-10-30T13:49:48Z"
                )
              )
            ],
            totalCount: 60
          )
        }
      )
    )
    try await command.run()
    // swiftlint:disable line_length
    XCTAssertEqual(
      output.string,
      """
      \nPrinting 1 page of 2 for 60 subtitles.\n
      FILE ID  FILE NAME                    LANGUAGE  UPLOADED              DOWNLOADS  SUBTITLES ID
      171816   Aliens.1986.Special.Edition  en        2010-10-30T13:49:48Z  57706      171510      \n
      """
    )
    // swiftlint:enable line_length
  }

  func testThrowsAnErrorIfPassedTheFileAndMovehashOptions() {
    XCTAssertThrowsError(
      try SearchSubtitlesCommand.parse([
        "--moviehash", "c8",
        "--file", "/"
      ])
    )
  }
}
