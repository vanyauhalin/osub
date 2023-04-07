// swiftlint:disable unavailable_function
import Client
import Foundation

public final class MockedClient: ClientProtocol {
  public let mockedAuth: AuthenticationServiceProtocol?
  public let mockedDownloads: DownloadsServiceProtocol?
  public let mockedInfo: InformationServiceProtocol?
  public let mockedSearch: SearchServiceProtocol?

  public init(
    auth: AuthenticationServiceProtocol? = nil,
    downloads: DownloadsServiceProtocol? = nil,
    info: InformationServiceProtocol? = nil,
    search: SearchServiceProtocol? = nil
  ) {
    self.mockedAuth = auth
    self.mockedDownloads = downloads
    self.mockedInfo = info
    self.mockedSearch = search
  }

  public var auth: AuthenticationServiceProtocol {
    guard let mockedAuth else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedAuth
  }

  public var downloads: DownloadsServiceProtocol {
    guard let mockedDownloads else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedDownloads
  }

  public var info: InformationServiceProtocol {
    guard let mockedInfo else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedInfo
  }

  public var search: SearchServiceProtocol {
    guard let mockedSearch else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedSearch
  }

  public func configure(apiKey: String?, baseURL: URL?, token: String?) {}

  public func url(path: String) throws -> URL {
    fatalError("The \(#function) is not implemented.")
  }

  public func url(path: String, with queryItems: [URLQueryItem]) throws -> URL {
    fatalError("The \(#function) is not implemented.")
  }

  public func request(url: URL) -> URLRequest {
    fatalError("The \(#function) is not implemented.")
  }

  public func entity<T>(
    _ type: T.Type,
    from request: URLRequest
  ) async throws -> T where T: Decodable {
    fatalError("The \(#function) is not implemented.")
  }
}

public final class MockedAuthenticationService: AuthenticationServiceProtocol {
  let mockedLogin: (() throws -> Login)?
  let mockedLogout: (() throws -> Information)?

  public init(
    login: (() throws -> Login)? = nil,
    logout: (() throws -> Information)? = nil
  ) {
    self.mockedLogin = login
    self.mockedLogout = logout
  }

  public func login(username: String, password: String) async throws -> Login {
    guard let mockedLogin else {
      fatalError("The \(#function) is not implemented.")
    }
    return try mockedLogin()
  }

  public func logout() async throws -> Information {
    guard let mockedLogout else {
      fatalError("The \(#function) is not implemented.")
    }
    return try mockedLogout()
  }
}

public final class MockedInformationService: InformationServiceProtocol {
  public let mockedLanguages: (() throws -> DatumedEntity<[Language]>)?
  public let mockedUser: (() throws -> DatumedEntity<User>)?

  public init(
    languages: (() throws -> DatumedEntity<[Language]>)? = nil,
    user: (() throws -> DatumedEntity<User>)? = nil
  ) {
    self.mockedLanguages = languages
    self.mockedUser = user
  }

  public func languages() async throws -> DatumedEntity<[Language]> {
    guard let mockedLanguages else {
      fatalError("The \(#function) is not implemented.")
    }
    return try mockedLanguages()
  }

  public func user() async throws -> DatumedEntity<User> {
    guard let mockedUser else {
      fatalError("The \(#function) is not implemented.")
    }
    return try mockedUser()
  }
}
