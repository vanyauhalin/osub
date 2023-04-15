import Foundation

public protocol DownloadsServiceProtocol {
  // swiftlint:disable:next function_parameter_count
  func post(
    fileID: Int,
    fileName: String?,
    inFPS: Int?,
    outFPS: Int?,
    subFormat: String?,
    timeshift: Int?
  ) async throws -> DownloadEntity
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
  public func post(
    fileID: Int,
    fileName: String? = nil,
    inFPS: Int? = nil,
    outFPS: Int? = nil,
    subFormat: String? = nil,
    timeshift: Int? = nil
  ) async throws -> DownloadEntity {
    let client = try refer()
    let url = try client.url(path: "download")

    var body: [String: Any] = [
      "file_id": fileID
    ]
    if let fileName {
      body["file_name"] = fileName
    }
    if let inFPS {
      body["in_fps"] = inFPS
    }
    if let outFPS {
      body["out_fps"] = outFPS
    }
    if let subFormat {
      body["sub_format"] = subFormat
    }
    if let timeshift {
      body["timeshift"] = timeshift
    }

    let request = client
      .request(url: url)
      .httpMethod(.post)
      .httpBody(body)
    return try await client.entity(DownloadEntity.self, from: request)
  }
}
