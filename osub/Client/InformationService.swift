import Foundation

public protocol InformationServiceProtocol {
  func formats() async throws -> DatumedEntity<FormatsEntity>
  func languages() async throws -> DatumedEntity<[LanguageEntity]>
  func user() async throws -> DatumedEntity<UserEntity>
}

public final class InformationService: Service, InformationServiceProtocol {
  weak var client: ClientProtocol?

  init(client: ClientProtocol) {
    self.client = client
  }
}

// MARK: Formats

public struct FormatsEntity {
  public let outputFormats: [String]

  public init(outputFormats: [String] = []) {
    self.outputFormats = outputFormats
  }
}

extension FormatsEntity: Decodable {
  enum CodingKeys: String, CodingKey {
    case outputFormats = "output_formats"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    // swiftlint:disable:next line_length
    self.outputFormats = (try container.decodeIfPresent([String].self, forKey: .outputFormats)) ?? []
  }
}

extension InformationService {
  public func formats() async throws -> DatumedEntity<FormatsEntity> {
    let client = try refer()
    let url = try client.url(path: "infos/formats")
    let request = client
      .request(url: url)
      .httpMethod(.get)
    return try await client.entity(
      DatumedEntity<FormatsEntity>.self,
      from: request
    )
  }
}

// MARK: Language

public struct LanguageEntity {
  public let languageCode: String?
  public let languageName: String?

  public init(languageCode: String? = nil, languageName: String? = nil) {
    self.languageCode = languageCode
    self.languageName = languageName
  }
}

extension LanguageEntity: Decodable {
  enum CodingKeys: String, CodingKey {
    case languageCode = "language_code"
    case languageName = "language_name"
  }
}

extension InformationService {
  public func languages() async throws -> DatumedEntity<[LanguageEntity]> {
    let client = try refer()
    let url = try client.url(path: "infos/languages")
    let request = client
      .request(url: url)
      .httpMethod(.get)
    return try await client.entity(
      DatumedEntity<[LanguageEntity]>.self,
      from: request
    )
  }
}

// MARK: User

public struct UserEntity {
  public let allowedDownloads: Int?
  public let downloadsCount: Int?
  public let extInstalled: Bool?
  public let level: String?
  public let remainingDownloads: Int?
  public let userID: Int?
  public let vip: Bool?

  public init(
    allowedDownloads: Int? = nil,
    downloadsCount: Int? = nil,
    extInstalled: Bool? = nil,
    level: String? = nil,
    remainingDownloads: Int? = nil,
    userID: Int? = nil,
    vip: Bool? = nil
  ) {
    self.allowedDownloads = allowedDownloads
    self.downloadsCount = downloadsCount
    self.extInstalled = extInstalled
    self.level = level
    self.remainingDownloads = remainingDownloads
    self.userID = userID
    self.vip = vip
  }
}

extension UserEntity: Decodable {
  enum CodingKeys: String, CodingKey {
    case allowedDownloads = "allowed_downloads"
    case downloadsCount = "downloads_count"
    case extInstalled = "ext_installed"
    case level
    case remainingDownloads = "remaining_downloads"
    case userID = "user_id"
    case vip
  }
}

extension InformationService {
  public func user() async throws -> DatumedEntity<UserEntity> {
    let client = try refer()
    let url = try client.url(path: "infos/user")
    let request = client
      .request(url: url)
      .httpMethod(.get)
    return try await client.entity(
      DatumedEntity<UserEntity>.self,
      from: request
    )
  }
}
