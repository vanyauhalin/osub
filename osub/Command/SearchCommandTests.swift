// swiftlint:disable trailing_closure
import Client
@testable
import Command
import Configuration
import State
import TestCase
import XCTest

final class SearchFeaturesCommandTests: XCTestCase {
  func testRuns() async throws {
    let output = MockedTextOutputStream()
    var command = try SearchFeaturesCommand.parse(["--no-frame"])
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
        features: {
          DatumedEntity(
            data: [
              AttributedEntity(
                id: 126826,
                attributes: FeatureEntity(
                  episodeNumber: 4,
                  featureType: .episode,
                  imdbID: 1218285,
                  parentIMDBID: 259733,
                  parentTitle: "Waking the Dead",
                  seasonNumber: 7,
                  title: "Waking",
                  tmdbID: 344533,
                  year: 2008
                )
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
      \nPrinting 1 features.\n
      FEATURE ID  TITLE   FEATURE TYPE  IMDB ID  INDEX   PARENT TITLE\("   ")
      126826      Waking  Episode       1218285  S07E04  Waking the Dead\n
      """
    )
  }
}

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
      ),
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
                  uploadDate: Date(timeIntervalSince1970: 1252092960)
                )
              )
            ],
            totalCount: 60
          )
        }
      )
    )
    try await command.run()
    XCTAssertEqual(
      output.string,
      """
      \nPrinting 1 page of 2 for 60 subtitles.\n
      FILE ID  FILE NAME                    LANGUAGE  UPLOADED          DOWNLOADS  SUBTITLES ID
      171816   Aliens.1986.Special.Edition  English   4 September 2009  57706      171510      \n
      """
    )
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
