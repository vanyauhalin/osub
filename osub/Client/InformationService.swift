import Foundation

public protocol InformationServiceProtocol {
  func languages() async throws -> DatumedEntity<[LanguageEntity]>
  func user() async throws -> DatumedEntity<UserEntity>
}

public final class InformationService: Service, InformationServiceProtocol {
  weak var client: ClientProtocol?

  init(client: ClientProtocol) {
    self.client = client
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
  public let userID: Int?
  public let remainingDownloads: Int?

  public init(userID: Int? = nil, remainingDownloads: Int? = nil) {
    self.userID = userID
    self.remainingDownloads = remainingDownloads
  }
}

extension UserEntity: Decodable {
  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case remainingDownloads = "remaining_downloads"
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
