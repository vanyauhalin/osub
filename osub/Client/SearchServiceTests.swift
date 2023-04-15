// swiftlint:disable xct_specific_matcher
@testable
import Client
import TestCase
import XCTest

final class SearchServiceTests: URLProtocolTestCase {
  func testFeatures() async throws {
    let url = URL(string: "http://localhost/features")
    let data = """
      {
        "data": [
          {
            "id": "126826",
            "attributes": {
              "title": "Waking",
              "year": "2008",
              "parent_title": "Waking the Dead",
              "season_number": 7,
              "episode_number": 4,
              "imdb_id": 1218285,
              "tmdb_id": 344533,
              "parent_imdb_id": 259733,
              "feature_type": "Episode"
            }
          }
        ]
      }
      """
      .data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: 200)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let client = Client(session: MockedURLProtocol.session)
    client.configure(baseURL: URL(string: "http://localhost/"))
    let service = SearchService(client: client)
    let features = try await service.features()

    XCTAssertEqual(features.data[0].id, 126826)

    let attributes = features.data[0].attributes
    XCTAssertEqual(attributes.title, "Waking")
    XCTAssertEqual(attributes.year, 2008)
    XCTAssertEqual(attributes.parentTitle, "Waking the Dead")
    XCTAssertEqual(attributes.seasonNumber, 7)
    XCTAssertEqual(attributes.episodeNumber, 4)
    XCTAssertEqual(attributes.imdbID, 1218285)
    XCTAssertEqual(attributes.tmdbID, 344533)
    XCTAssertEqual(attributes.parentIMDBID, 259733)
    XCTAssertEqual(attributes.featureType, .episode)
  }

  func testSubtitles() async throws {
    let url = URL(string: "http://localhost/subtitles")
    let data = """
      {
        "total_count": 1,
        "data": [
          {
            "id": "9000",
            "attributes": {
              "language": "en",
              "download_count": 697844,
              "hearing_impaired": false,
              "hd": false,
              "fps": 23.976,
              "votes": 4,
              "ratings": 6,
              "from_trusted": true,
              "foreign_parts_only": false,
              "upload_date": "2009-09-04T19:36:00Z",
              "ai_translated": false,
              "machine_translated": false,
              "release": "Season 1 (Whole) DVDrip.XviD-SAiNTS",
              "uploader": {
                "uploader_id": 47823,
                "name": "scooby007",
                "rank": "translator"
              },
              "feature_details": {
                "feature_id": 38367,
                "feature_type": "Episode",
                "year": 1994,
                "title": "The Pilot",
                "movie_name": "Friends - S01E01  The Pilot",
                "imdb_id": 583459,
                "tmdb_id": 85987,
                "season_number": 1,
                "episode_number": 1,
                "parent_imdb_id": 108778,
                "parent_title": "Friends",
                "parent_tmdb_id": 1668,
                "parent_feature_id": 7251
              },
              "files": [
                {
                  "file_id": 1923552,
                  "file_name": "Friends.S01E01.DVDrip.XviD-SAiNTS_(ENGLISH)_DJJ.HOME.SAPO.PT"
                }
              ]
            }
          }
        ]
      }
      """
      .data(using: .utf8)
    let response = HTTPURLResponse(url: url, statusCode: 200)
    MockedURLProtocol.urls[url] = (data, response, nil)

    let client = Client(session: MockedURLProtocol.session)
    client.configure(baseURL: URL(string: "http://localhost/"))
    let service = SearchService(client: client)
    let subtitles = try await service.subtitles()

    XCTAssertEqual(subtitles.totalCount, 1)
    XCTAssertEqual(subtitles.data[0].id, 9000)

    let attributes = subtitles.data[0].attributes
    XCTAssertEqual(attributes.language, "en")
    XCTAssertEqual(attributes.downloadCount, 697844)
    XCTAssertEqual(attributes.hearingImpaired, false)
    XCTAssertEqual(attributes.hd, false)
    XCTAssertEqual(attributes.fps, 23.976)
    XCTAssertEqual(attributes.votes, 4)
    XCTAssertEqual(attributes.ratings, 6)
    XCTAssertEqual(attributes.fromTrusted, true)
    XCTAssertEqual(attributes.foreignPartsOnly, false)
    XCTAssertEqual(attributes.uploadDate?.timeIntervalSince1970, 1252092960)
    XCTAssertEqual(attributes.aiTranslated, false)
    XCTAssertEqual(attributes.machineTranslated, false)
    XCTAssertEqual(attributes.release, "Season 1 (Whole) DVDrip.XviD-SAiNTS")

    let uploader = attributes.uploader
    XCTAssertEqual(uploader?.uploaderID, 47823)
    XCTAssertEqual(uploader?.name, "scooby007")
    XCTAssertEqual(uploader?.rank, "translator")

    let featureDetails = attributes.featureDetails
    XCTAssertEqual(featureDetails?.featureID, 38367)
    XCTAssertEqual(featureDetails?.featureType, .episode)
    XCTAssertEqual(featureDetails?.year, 1994)
    XCTAssertEqual(featureDetails?.title, "The Pilot")
    XCTAssertEqual(featureDetails?.movieName, "Friends - S01E01  The Pilot")
    XCTAssertEqual(featureDetails?.imdbID, 583459)
    XCTAssertEqual(featureDetails?.tmdbID, 85987)
    XCTAssertEqual(featureDetails?.seasonNumber, 1)
    XCTAssertEqual(featureDetails?.episodeNumber, 1)
    XCTAssertEqual(featureDetails?.parentIMDBID, 108778)
    XCTAssertEqual(featureDetails?.parentTitle, "Friends")
    XCTAssertEqual(featureDetails?.parentTMDBID, 1668)
    XCTAssertEqual(featureDetails?.parentFeatureID, 7251)

    let file = attributes.files[0]
    XCTAssertEqual(file.fileID, 1923552)
    XCTAssertEqual(file.fileName, "Friends.S01E01.DVDrip.XviD-SAiNTS_(ENGLISH)_DJJ.HOME.SAPO.PT")
  }
}
