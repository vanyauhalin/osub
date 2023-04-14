import Downloads
import Foundation

public final class MockedDownloadsManager: DownloadsManagerProtocol {
  let mockedDownload: (() -> URL)?

  public init(download: (() -> URL)? = nil) {
    self.mockedDownload = download
  }

  public func download(from url: URL) async throws -> URL {
    guard let mockedDownload else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedDownload()
  }
}
