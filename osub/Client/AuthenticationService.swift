import Foundation

public protocol AuthenticationServiceProtocol {
  func login(username: String, password: String) async throws -> Login
  func logout() async throws -> Information
}

public final class AuthenticationService: Service, AuthenticationServiceProtocol {
  weak var client: ClientProtocol?

  init(client: ClientProtocol) {
    self.client = client
  }
}

// MARK: Login

public struct Login {
  public let baseURL: URL?
  public let token: String

  public init(baseURL: URL? = nil, token: String) {
    self.baseURL = baseURL
    self.token = token
  }
}

extension Login: Decodable {
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
  public func login(username: String, password: String) async throws -> Login {
    let client = try refer()
    let url = try client.url(path: "login")
    let request = client
      .request(url: url)
      .httpMethod(.post)
      .httpBody([
        "username": username,
        "password": password
      ])
    return try await client.entity(Login.self, from: request)
  }
}

// MARK: Logout

extension AuthenticationService {
  public func logout() async throws -> Information {
    let client = try refer()
    let url = try client.url(path: "logout")
    let request = client
      .request(url: url)
      .httpMethod(.delete)
    return try await client.entity(Information.self, from: request)
  }
}
