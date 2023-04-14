// swiftlint:disable trailing_closure
import Client
@testable
import Command
import Configuration
import State
import TestCase
import XCTest

final class LanguageCommandTests: XCTestCase {
  func testRuns() async throws {
    let output = MockedTextOutputStream()
    var command = try LanguagesCommand.parse(["--no-frame"])
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
      info: MockedInformationService(
        languages: {
          DatumedEntity(
            data: [
              LanguageEntity(
                languageCode: "en",
                languageName: "English"
              )
            ]
          )
        }
      )
    )
    try await command.run()
    XCTAssertEqual(
      output.string,
      """
      SUBTAG  NAME\("   ")
      en      English\n
      """
    )
  }
}
