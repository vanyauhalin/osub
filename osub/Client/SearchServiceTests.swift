@testable
import Client
import TestCase
import XCTest

final class SearchServiceTests: URLProtocolTestCase {
  func testSubtitles() async throws {
    let url = URL(string: "http://localhost/subtitles")
    let data = """
      {
        "total_count": 1,
        "data": [
          {
            "id": "9000",
            "attributes": {
              "download_count": 20,
              "files": [
                {
                  "file_id": 9001,
                  "file_name": "x264.en"
                }
              ],
              "language": "en",
              "release": "x264.mp4",
              "upload_date": "2010-10-02T10:51:04Z"
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
    XCTAssertEqual(subtitles.data[0].attributes.downloadCount, 20)
    XCTAssertEqual(subtitles.data[0].attributes.files[0].fileID, 9001)
    XCTAssertEqual(subtitles.data[0].attributes.files[0].fileName, "x264.en")
    XCTAssertEqual(subtitles.data[0].attributes.language, "en")
    XCTAssertEqual(subtitles.data[0].attributes.release, "x264.mp4")
    XCTAssertEqual(subtitles.data[0].attributes.uploadDate, "2010-10-02T10:51:04Z")
  }
}
