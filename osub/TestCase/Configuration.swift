import Configuration
import Foundation

public final class MockedConfigurationManager: ConfigurationManagerProtocol {
  public let mockedConfigDirectory: URL?
  public let mockedStateDirectory: URL?
  public let mockedDownloadsDirectory: URL?
  public let mockedLoad: (() -> Configuration)?
  public let mockedWrite: ((Configuration) -> Void)?

  public var configDirectory: URL {
    guard let mockedConfigDirectory else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedConfigDirectory
  }

  public var stateDirectory: URL {
    guard let mockedStateDirectory else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedStateDirectory
  }

  public var downloadsDirectory: URL {
    guard let mockedDownloadsDirectory else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedDownloadsDirectory
  }

  public init(
    configDirectory: URL? = nil,
    stateDirectory: URL? = nil,
    downloadsDirectory: URL? = nil,
    load: (() -> Configuration)? = nil,
    write: ((Configuration) -> Void)? = nil
  ) {
    self.mockedConfigDirectory = configDirectory
    self.mockedStateDirectory = stateDirectory
    self.mockedDownloadsDirectory = downloadsDirectory
    self.mockedLoad = load
    self.mockedWrite = write
  }

  public func load() throws -> Configuration {
    guard let mockedLoad else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedLoad()
  }

  public func write(config: Configuration) throws {
    guard let mockedWrite else {
      fatalError("The \(#function) is not implemented.")
    }
    mockedWrite(config)
  }

  public func merge(current: Configuration, with new: Configuration) -> Configuration {
    ConfigurationManager.shared.merge(current: current, with: new)
  }
}
