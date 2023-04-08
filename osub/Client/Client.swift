import Extensions
import Foundation
import Network

public protocol ClientProtocol: AnyObject {
  var auth: AuthenticationServiceProtocol { get }
  var downloads: DownloadsServiceProtocol { get }
  var info: InformationServiceProtocol { get }
  var search: SearchServiceProtocol { get }
  func configure(apiKey: String?, baseURL: URL?, token: String?)
  func url(path: String) throws -> URL
  func url(path: String, with queryItems: [URLQueryItem]) throws -> URL
  func request(url: URL) -> URLRequest
  func entity<T>(
    _ type: T.Type,
    from request: URLRequest
  ) async throws -> T where T: Decodable
}

public final class Client: ClientProtocol {
  public static let shared: ClientProtocol = Client()

  public lazy var auth: AuthenticationServiceProtocol = AuthenticationService(client: self)
  public lazy var downloads: DownloadsServiceProtocol = DownloadsService(client: self)
  public lazy var info: InformationServiceProtocol = InformationService(client: self)
  public lazy var search: SearchServiceProtocol = SearchService(client: self)

  private let bundle: Bundle
  private let session: URLSession

  var apiKey: String?
  var baseURL: URL?
  var token: String?

  public init(
    bundle: Bundle = .main,
    session: URLSession = .shared
  ) {
    self.bundle = bundle
    self.session = session
  }

  public func configure(
    apiKey: String? = nil,
    baseURL: URL? = nil,
    token: String? = nil
  ) {
    self.apiKey = apiKey ?? bundle.nonEmptyInfo("API_KEY")
    self.baseURL = baseURL ?? URL(string: "https://api.opensubtitles.com/api/v1/")
    self.token = token
  }

  public func url(path: String) throws -> URL {
    var components = URLComponents()
    components.path = path
    guard let baseURL else {
      throw ClientError.cannotCreateURL
    }
    guard let url = components.url(relativeTo: baseURL) else {
      throw ClientError.cannotCreateURL
    }
    return url.absoluteURL
  }

  public func url(path: String, with queryItems: [URLQueryItem]) throws -> URL {
    guard
      let url = try url(path: path).appending2(queryItems: queryItems)
    else {
      throw ClientError.cannotCreateURL
    }
    return url.absoluteURL
  }

  public func request(url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.setValue("*/*", forHTTPHeaderField: "accept")
    if let apiKey {
      request.setValue(apiKey, forHTTPHeaderField: "api-key")
    }
    if let token {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
    }
    request.setValue("application/json", forHTTPHeaderField: "content-type")
    return request
  }

  public func entity<T>(
    _ type: T.Type,
    from request: URLRequest
  ) async throws -> T where T: Decodable {
    let (data, response) = try await session.data2(for: request)
    let decoder = JSONDecoder()
    if let resource = try? decoder.decode(T.self, from: data) {
      return resource
    }
    let statusCode = (response as? HTTPURLResponse)?.statusCode
    let status = HTTPStatus(rawValue: statusCode ?? .zero)
    let info = try? decoder.decode(Information.self, from: data)
    throw ClientError.cannotDecodeEntity(status, info)
  }
}

// MARK: Error

enum ClientError: Error {
  case clientUnavailable
  case cannotCreateURL
  case cannotDecodeProperty
  case cannotDecodeEntity(HTTPStatus?, Information?)
}

extension ClientError: CustomStringConvertible {
  var description: String {
    switch self {
    case .clientUnavailable:
      return "The referred client couldn't be retrieved."
    case .cannotCreateURL:
      return "A client was unable to create a URL to send a request."
    case .cannotDecodeProperty:
      return "A client was unable to decode a property."
    case .cannotDecodeEntity(let status, let info):
      var description = "A client was unable to decode an entity from the request."
      if let status {
        description += "\n\(status)."
      }
      if let info {
        description += "\n\(info.message)"
      }
      return description
    }
  }
}

// MARK: Extensions

extension Bundle {
  func nonEmptyInfo(_ name: String) -> String? {
    guard
      let string = infoDictionary?[name] as? String,
      !string.isEmpty
    else {
      return nil
    }
    return string
  }
}

extension URLQueryItem {
  init(name: String, value: Int) {
    self.init(name: name, value: String(value))
  }
}

extension URLRequest {
  func httpMethod(_ method: HTTPMethod) -> Self {
    var copy = self
    copy.httpMethod = method.rawValue
    return copy
  }

  func httpBody(_ json: [String: Any]) -> Self {
    var copy = self
    copy.httpBody = try? JSONSerialization.data(withJSONObject: json)
    return copy
  }
}
