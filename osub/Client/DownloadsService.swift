import Foundation

public protocol DownloadsServiceProtocol {
  func post(fileID: Int) async throws -> DownloadEntity
}

public final class DownloadsService: Service, DownloadsServiceProtocol {
  weak var client: ClientProtocol?

  init(client: ClientProtocol) {
    self.client = client
  }
}

// MARK: Download

public struct DownloadEntity {
  public let link: URL?

  public init(link: URL? = nil) {
    self.link = link
  }
}

extension DownloadEntity: Decodable {
  enum CodingKeys: String, CodingKey {
    case link
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.link = try {
      let string = try container.decode(String.self, forKey: .link)
      return URL(string: string)
    }()
  }
}

extension DownloadsService {
  public func post(fileID: Int) async throws -> DownloadEntity {
    let client = try refer()
    let url = try client.url(path: "download")
    let request = client
      .request(url: url)
      .httpMethod(.post)
      .httpBody([
        "file_id": fileID
      ])
    return try await client.entity(DownloadEntity.self, from: request)
  }
}
