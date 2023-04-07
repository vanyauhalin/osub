import Foundation

public protocol SearchServiceProtocol {
  func subtitles(
    moviehash: String?,
    languages: String?
  ) async throws -> PaginatedEntity<AttributedEntity<Subtitle>>
}

public final class SearchService: Service, SearchServiceProtocol {
  weak var client: ClientProtocol?

  init(client: ClientProtocol) {
    self.client = client
  }
}

// MARK: Subtitles

public struct Subtitle {
  public let downloadCount: Int
  public let files: [File]
  public let language: String
  public let release: String
  public let uploadDate: String

  public init(
    downloadCount: Int,
    files: [File] = [],
    language: String,
    release: String,
    uploadDate: String
  ) {
    self.downloadCount = downloadCount
    self.files = files
    self.language = language
    self.release = release
    self.uploadDate = uploadDate
  }
}

extension Subtitle: Codable {
  enum CodingKeys: String, CodingKey {
    case downloadCount = "download_count"
    case files
    case language
    case release
    case uploadDate = "upload_date"
  }
}

public struct File {
  public let fileID: Int
  public let fileName: String

  public init(fileID: Int, fileName: String) {
    self.fileID = fileID
    self.fileName = fileName
  }
}

extension File: Codable {
  enum CodingKeys: String, CodingKey {
    case fileID = "file_id"
    case fileName = "file_name"
  }
}

extension SearchService {
  public func subtitles(
    moviehash: String?,
    languages: String?
  ) async throws -> PaginatedEntity<AttributedEntity<Subtitle>> {
    let client = try refer()
    var queryItems: [URLQueryItem] = []
    if let moviehash {
      queryItems.append(URLQueryItem(name: "moviehash", value: moviehash))
    }
    if let languages {
      queryItems.append(URLQueryItem(name: "languages", value: languages))
    }
    let url = try client.url(path: "subtitles", with: queryItems)
    let request = client
      .request(url: url)
      .httpMethod(.get)
    return try await client.entity(
      PaginatedEntity<AttributedEntity<Subtitle>>.self,
      from: request
    )
  }
}
