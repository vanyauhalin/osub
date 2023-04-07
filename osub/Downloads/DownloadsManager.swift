import Configuration
import Extensions
import Foundation

public protocol DownloadsManagerProtocol {
  func download(from url: URL) async throws -> URL
}

public final class DownloadsManager: DownloadsManagerProtocol {
  public static let shared: DownloadsManagerProtocol = DownloadsManager()

  private let fileManager: FileManager
  private let session: URLSession
  private let configManager: ConfigurationManagerProtocol

  init(
    fileManager: FileManager = .default,
    session: URLSession = .shared,
    configManager: ConfigurationManagerProtocol = ConfigurationManager.shared
  ) {
    self.fileManager = fileManager
    self.session = session
    self.configManager = configManager
  }

  public func download(from url: URL) async throws -> URL {
    let request = URLRequest(url: url)
    let (source, _) = try await session.download2(for: request)
    let dist = configManager.downloadsDirectory.appending2(path: url.lastPathComponent)
    try fileManager.copyItem(at: source, to: dist)
    return dist
  }
}
