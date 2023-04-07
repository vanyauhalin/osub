import Extensions
import Foundation
import XCTest

open class URLProtocolTestCase: XCTestCase {
  override public func setUp() {
    super.setUp()
    MockedURLProtocol.register()
  }

  override public func tearDown() {
    super.tearDown()
    MockedURLProtocol.unregister()
  }
}

public final class MockedBundle: Bundle {
  public let mockedInfoDictionary: [String: Any]

  public init(infoDictionary: [String: Any] = [:]) {
    self.mockedInfoDictionary = infoDictionary
    super.init()
  }

  // swiftlint:disable:next discouraged_optional_collection
  override public var infoDictionary: [String: Any]? {
    mockedInfoDictionary
  }
}

public final class MockedFileManager: FileManager {
  public let mockedHomeDirectoryForCurrentUser: URL?
  public let mockedURLs: [URL]

  public init(
    homeDirectoryForCurrentUser: URL? = nil,
    urls: [URL] = []
  ) {
    self.mockedHomeDirectoryForCurrentUser = homeDirectoryForCurrentUser
    self.mockedURLs = urls
    super.init()
  }

  override public var homeDirectoryForCurrentUser: URL {
    mockedHomeDirectoryForCurrentUser
      ?? FileManager.default.homeDirectoryForCurrentUser
  }

  override public func urls(
    for directory: SearchPathDirectory,
    in domainMask: SearchPathDomainMask
  ) -> [URL] {
    mockedURLs
  }
}

public final class MockedProcessInfo: ProcessInfo {
  public let mockedEnvironment: [String: String]

  public init(environment: [String: String] = [:]) {
    self.mockedEnvironment = environment
    super.init()
  }

  override public var environment: [String: String] {
    mockedEnvironment
  }
}

public final class MockedURLProtocol: URLProtocol {
  public static let session = {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockedURLProtocol.self]
    configuration.timeoutIntervalForRequest = 1
    return URLSession(configuration: configuration)
  }()

  public static var urls: [URL?: (Data?, URLResponse?, Error?)] = [:]

  public static func register() {
    URLProtocol.registerClass(MockedURLProtocol.self)
  }

  public static func unregister() {
    URLProtocol.unregisterClass(MockedURLProtocol.self)
  }

  override public class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override public func startLoading() {
    guard
      let url = request.url,
      let (data, response, error) = MockedURLProtocol.urls[url]
    else {
      return
    }

    if let data {
      client?.urlProtocol(self, didLoad: data)
    }
    if let response {
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    }
    if let error {
      client?.urlProtocol(self, didFailWithError: error)
    }

    client?.urlProtocolDidFinishLoading(self)
  }

  override public func stopLoading() {}
}

// MARK: Extensions

extension FileManager {
  static var letters: String {
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  }

  public func temporaryDirectory(
    for path: String = "me.vanyauhalin.osub"
  ) throws -> URL {
    let directory = temporaryDirectory
      .appending2(path: path, isDirectory: true)
      .appending2(
        path: String((0..<5).compactMap { _ in
          FileManager.letters.randomElement()
        }),
        isDirectory: true
      )
    try createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
  }
}

extension HTTPURLResponse {
  public convenience init?(url: URL? = nil, statusCode: Int) {
    guard let url else {
      return nil
    }
    self.init(
      url: url,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: nil
    )
  }
}
