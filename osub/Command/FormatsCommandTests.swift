// swiftlint:disable trailing_closure
import Client
@testable
import Command
import Configuration
import State
import TestCase
import XCTest

final class FormatsCommandTests: XCTestCase {
  func testRuns() async throws {
    let output = MockedTextOutputStream()
    var command = try FormatsCommand.parse([])
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
        formats: {
          DatumedEntity(
            data: FormatsEntity(
              outputFormats: [
                "srt"
              ]
            )
          )
        }
      )
    )
    try await command.run()
    XCTAssertEqual(
      output.string,
      """
      srt\n
      """
    )
  }
}
