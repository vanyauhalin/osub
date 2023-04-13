import Foundation

public protocol AuthenticationServiceProtocol {
  func login(username: String, password: String) async throws -> LoginEntity
  func logout() async throws -> InformationEntity
}

public final class AuthenticationService: Service, AuthenticationServiceProtocol {
  weak var client: ClientProtocol?

  init(client: ClientProtocol) {
    self.client = client
  }
}

// MARK: Login

public struct LoginEntity {
  public let baseURL: URL?
  public let token: String?

  public init(baseURL: URL? = nil, token: String? = nil) {
    self.baseURL = baseURL
    self.token = token
  }
}

extension LoginEntity: Decodable {
  enum CodingKeys: String, CodingKey {
    case baseURL = "base_url"
    case token
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.baseURL = try {
      guard let string = try container.decodeIfPresent(String.self, forKey: .baseURL) else {
        return nil
      }
      return URL(string: string)
    }()
    self.token = try container.decode(String.self, forKey: .token)
  }
}

extension AuthenticationService {
  public func login(username: String, password: String) async throws -> LoginEntity {
    let client = try refer()
    let url = try client.url(path: "login")
    let request = client
      .request(url: url)
      .httpMethod(.post)
      .httpBody([
        "username": username,
        "password": password
      ])
    return try await client.entity(LoginEntity.self, from: request)
  }
}

// MARK: Logout

extension AuthenticationService {
  public func logout() async throws -> InformationEntity {
    let client = try refer()
    let url = try client.url(path: "logout")
    let request = client
      .request(url: url)
      .httpMethod(.delete)
    return try await client.entity(InformationEntity.self, from: request)
  }
}
