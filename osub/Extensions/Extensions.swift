import Foundation

extension URL {
  public init(filePath2: String) {
    if #available(macOS 13, *) {
      self.init(filePath: filePath2)
    } else {
      self.init(fileURLWithPath: filePath2)
    }
  }

  public mutating func append2(queryItems: [URLQueryItem]) -> Bool {
    if #available(macOS 13.0, *) {
      append(queryItems: queryItems)
      return true
    }
    var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
    components?.queryItems = queryItems
    guard let url = components?.url else {
      return false
    }
    self = url
    return true
  }

  public func appending2(path: String) -> URL {
    if #available(macOS 13, *) {
      return appending(path: path)
    }
    return appendingPathComponent(path)
  }

  public func appending2(path: String, isDirectory: Bool) -> URL {
    if #available(macOS 13, *) {
      return appending(path: path, directoryHint: .isDirectory)
    }
    return appendingPathComponent(path, isDirectory: isDirectory)
  }

  public func path2() -> String {
    if #available(macOS 13, *) {
      return path()
    }
    return path
  }
}

extension URLSession {
  public func data2(for request: URLRequest) async throws -> (Data, URLResponse) {
    if #available(macOS 12.0, *) {
      return try await data(for: request, delegate: nil)
    }
    return try await withCheckedThrowingContinuation { continuation in
      let task = dataTask(with: request) { data, response, error in
        guard
          let data,
          let response
        else {
          let error = error ?? URLError(.unknown)
          return continuation.resume(throwing: error)
        }
        continuation.resume(returning: (data, response))
      }
      task.resume()
    }
  }

  public func download2(for request: URLRequest) async throws -> (URL, URLResponse) {
    if #available(macOS 12.0, *) {
      return try await download(for: request, delegate: nil)
    }
    return try await withCheckedThrowingContinuation { continuation in
      let task = downloadTask(with: request) { url, response, error in
        guard
          let url,
          let response
        else {
          let error = error ?? URLError(.unknown)
          return continuation.resume(throwing: error)
        }
        continuation.resume(returning: (url, response))
      }
      task.resume()
    }
  }
}
