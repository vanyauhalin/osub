protocol Service {
  var client: ClientProtocol? { get set }
}

extension Service {
  func refer() throws -> ClientProtocol {
    guard let client else {
      throw ClientError.clientUnavailable
    }
    return client
  }
}

// MARK: Generic Entities

public struct DatumedEntity<T>: Decodable where T: Decodable {
  public let data: T

  public init(data: T) {
    self.data = data
  }
}

public struct AttributedEntity<T>: Decodable where T: Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case attributes
  }

  public let id: Int
  public let attributes: T

  public init(id: Int, attributes: T) {
    self.id = id
    self.attributes = attributes
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try {
      let string = try container.decode(String.self, forKey: .id)
      guard let int = Int(string) else {
        throw ClientError.cannotDecodeProperty
      }
      return int
    }()
    self.attributes = try container.decode(T.self, forKey: .attributes)
  }
}

public struct PaginatedEntity<T>: Decodable where T: Decodable {
  enum CodingKeys: String, CodingKey {
    case data
    case totalCount = "total_count"
  }

  public let data: [T]
  public let totalCount: Int

  public init(data: [T], totalCount: Int) {
    self.data = data
    self.totalCount = totalCount
  }
}

public struct InformationEntity: Decodable {
  public let message: String?

  public init(message: String? = nil) {
    self.message = message
  }
}
