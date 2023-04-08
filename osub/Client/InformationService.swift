import Foundation

public protocol InformationServiceProtocol {
  func languages() async throws -> DatumedEntity<[Language]>
  func user() async throws -> DatumedEntity<User>
}

public final class InformationService: Service, InformationServiceProtocol {
  weak var client: ClientProtocol?

  init(client: ClientProtocol) {
    self.client = client
  }
}

// MARK: Language

public struct Language {
  public let languageCode: String
  public let languageName: String

  public init(languageCode: String, languageName: String) {
    self.languageCode = languageCode
    self.languageName = languageName
  }
}

extension Language: Decodable {
  enum CodingKeys: String, CodingKey {
    case languageCode = "language_code"
    case languageName = "language_name"
  }
}

extension InformationService {
  public func languages() async throws -> DatumedEntity<[Language]> {
    let client = try refer()
    let url = try client.url(path: "infos/languages")
    let request = client
      .request(url: url)
      .httpMethod(.get)
    return try await client.entity(
      DatumedEntity<[Language]>.self,
      from: request
    )
  }
}

// MARK: User

public struct User {
  public let userID: Int
  public let remainingDownloads: Int

  public init(userID: Int, remainingDownloads: Int) {
    self.userID = userID
    self.remainingDownloads = remainingDownloads
  }
}

extension User: Decodable {
  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case remainingDownloads = "remaining_downloads"
  }
}

extension InformationService {
  public func user() async throws -> DatumedEntity<User> {
    let client = try refer()
    let url = try client.url(path: "infos/user")
    let request = client
      .request(url: url)
      .httpMethod(.get)
    return try await client.entity(
      DatumedEntity<User>.self,
      from: request
    )
  }
}
