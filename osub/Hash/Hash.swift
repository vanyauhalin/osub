import Foundation

public enum Hash {
  public static let chunkSize = 65536

  public static func hash(of path: String) throws -> String {
    guard let handler = FileHandle(forReadingAtPath: path) else {
      throw HashError.cannotCalculateHash
    }
    defer {
      try? handler.close()
    }

    let startData = handler.readData(ofLength: chunkSize)

    let size = handler.seekToEndOfFile()
    guard size >= UInt64(chunkSize) else {
      throw HashError.cannotCalculateHash
    }

    handler.seek(toFileOffset: max(0, size - UInt64(chunkSize)))
    let endData = handler.readData(ofLength: chunkSize)

    var hashValue = size

    // swiftlint:disable:next line_length
    let startBytes = startData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> UnsafeBufferPointer<UInt64> in
      pointer.bindMemory(to: UInt64.self)
    }
    hashValue = startBytes.reduce(hashValue, &+)

    // swiftlint:disable:next line_length
    let endBytes = endData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> UnsafeBufferPointer<UInt64> in
      pointer.bindMemory(to: UInt64.self)
    }
    hashValue = endBytes.reduce(hashValue, &+)

    return String(format: "%016qx", hashValue)
  }
}

// MARK: Error

enum HashError: Error {
  case cannotCalculateHash
}

extension HashError: CustomStringConvertible {
  var description: String {
    switch self {
    case .cannotCalculateHash:
      // swiftlint:disable:next line_length
      return "A hash function couldn't calculate the hash of the file. Ensure that the file exists and is not corrupted."
    }
  }
}
