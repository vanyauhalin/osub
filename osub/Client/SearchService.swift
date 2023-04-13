import Foundation

public protocol SearchServiceProtocol {
  // swiftlint:disable:next function_parameter_count
  func subtitles(
    aiTranslated: SearchSubtitlesAITranslated?,
    episodeNumber: Int?,
    foreignPartsOnly: SearchSubtitlesForeignPartsOnly?,
    hearingImpaired: SearchSubtitlesHearingImpaired?,
    id: Int?,
    imdbID: Int?,
    languages: String?,
    machineTranslated: SearchSubtitlesMachineTranslated?,
    moviehashMatch: SearchSubtitlesMoviehashMatch?,
    moviehash: String?,
    orderBy: SearchSubtitlesOrderBy?,
    orderDirection: SearchSubtitlesOrderDirection?,
    page: Int?,
    parentFeatureID: Int?,
    parentIMDBID: Int?,
    parentTMDBID: Int?,
    query: String?,
    seasonNumber: Int?,
    tmdbID: Int?,
    trustedSources: SearchSubtitlesTrustedSources?,
    type: SearchSubtitlesFeatureType?,
    userID: Int?,
    year: Int?
  ) async throws -> PaginatedEntity<AttributedEntity<SubtitlesEntity>>
}

public final class SearchService: Service, SearchServiceProtocol {
  weak var client: ClientProtocol?

  init(client: ClientProtocol) {
    self.client = client
  }
}

// MARK: Subtitles

public struct SubtitlesEntity {
  public let aiTranslated: Bool?
  public let downloadCount: Int?
  public let featureDetails: FeatureDetails?
  public let files: [File]
  public let foreignPartsOnly: Bool?
  public let fps: Double?
  public let fromTrusted: Bool?
  public let hd: Bool?
  public let hearingImpaired: Bool?
  public let language: String?
  public let machineTranslated: Bool?
  public let ratings: Double?
  public let release: String?
  public let uploadDate: String?
  public let uploader: Uploader?
  public let votes: Int?

  public init(
    aiTranslated: Bool? = nil,
    downloadCount: Int? = nil,
    featureDetails: FeatureDetails? = nil,
    files: [File] = [],
    foreignPartsOnly: Bool? = nil,
    fps: Double? = nil,
    fromTrusted: Bool? = nil,
    hd: Bool? = nil,
    hearingImpaired: Bool? = nil,
    language: String? = nil,
    machineTranslated: Bool? = nil,
    ratings: Double? = nil,
    release: String? = nil,
    uploadDate: String? = nil,
    uploader: Uploader? = nil,
    votes: Int? = nil
  ) {
    self.aiTranslated = aiTranslated
    self.downloadCount = downloadCount
    self.featureDetails = featureDetails
    self.files = files
    self.foreignPartsOnly = foreignPartsOnly
    self.fps = fps
    self.fromTrusted = fromTrusted
    self.hd = hd
    self.hearingImpaired = hearingImpaired
    self.language = language
    self.machineTranslated = machineTranslated
    self.ratings = ratings
    self.release = release
    self.uploadDate = uploadDate
    self.uploader = uploader
    self.votes = votes
  }
}

extension SubtitlesEntity: Codable {
  enum CodingKeys: String, CodingKey {
    case aiTranslated = "ai_translated"
    case downloadCount = "download_count"
    case featureDetails = "feature_details"
    case files
    case foreignPartsOnly = "foreign_parts_only"
    case fps
    case fromTrusted = "from_trusted"
    case hd
    case hearingImpaired = "hearing_impaired"
    case language
    case machineTranslated = "machine_translated"
    case ratings
    case release
    case uploadDate = "upload_date"
    case uploader
    case votes
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.aiTranslated = try container.decodeIfPresent(Bool.self, forKey: .aiTranslated)
    self.downloadCount = try container.decodeIfPresent(Int.self, forKey: .downloadCount)
    // swiftlint:disable:next line_length
    self.featureDetails = try container.decodeIfPresent(FeatureDetails.self, forKey: .featureDetails)
    self.files = (try container.decodeIfPresent([File].self, forKey: .files)) ?? []
    self.foreignPartsOnly = try container.decodeIfPresent(Bool.self, forKey: .foreignPartsOnly)
    self.fps = try container.decodeIfPresent(Double.self, forKey: .fps)
    self.fromTrusted = try container.decodeIfPresent(Bool.self, forKey: .fromTrusted)
    self.hd = try container.decodeIfPresent(Bool.self, forKey: .hd)
    self.hearingImpaired = try container.decodeIfPresent(Bool.self, forKey: .hearingImpaired)
    self.language = try container.decodeIfPresent(String.self, forKey: .language)
    self.machineTranslated = try container.decodeIfPresent(Bool.self, forKey: .machineTranslated)
    self.ratings = try container.decodeIfPresent(Double.self, forKey: .ratings)
    self.release = try container.decodeIfPresent(String.self, forKey: .release)
    self.uploadDate = try container.decodeIfPresent(String.self, forKey: .uploadDate)
    self.uploader = try container.decodeIfPresent(Uploader.self, forKey: .uploader)
    self.votes = try container.decodeIfPresent(Int.self, forKey: .votes)
  }
}

public struct FeatureDetails {
  public let episodeNumber: Int?
  public let featureID: Int?
  public let featureType: FeatureType?
  public let imdbID: Int?
  public let movieName: String?
  public let parentFeatureID: Int?
  public let parentIMDBID: Int?
  public let parentTitle: String?
  public let parentTMDBID: Int?
  public let seasonNumber: Int?
  public let title: String?
  public let tmdbID: Int?
  public let year: Int?

  public init(
    episodeNumber: Int? = nil,
    featureID: Int? = nil,
    featureType: FeatureType? = nil,
    imdbID: Int? = nil,
    movieName: String? = nil,
    parentFeatureID: Int? = nil,
    parentIMDBID: Int? = nil,
    parentTitle: String? = nil,
    parentTMDBID: Int? = nil,
    seasonNumber: Int? = nil,
    title: String? = nil,
    tmdbID: Int? = nil,
    year: Int? = nil
  ) {
    self.episodeNumber = episodeNumber
    self.featureID = featureID
    self.featureType = featureType
    self.imdbID = imdbID
    self.movieName = movieName
    self.parentFeatureID = parentFeatureID
    self.parentIMDBID = parentIMDBID
    self.parentTitle = parentTitle
    self.parentTMDBID = parentTMDBID
    self.seasonNumber = seasonNumber
    self.title = title
    self.tmdbID = tmdbID
    self.year = year
  }
}

extension FeatureDetails: Codable {
  enum CodingKeys: String, CodingKey {
    case episodeNumber = "episode_number"
    case featureID = "feature_id"
    case featureType = "feature_type"
    case imdbID = "imdb_id"
    case movieName = "movie_name"
    case parentFeatureID = "parent_feature_id"
    case parentIMDBID = "parent_imdb_id"
    case parentTitle = "parent_title"
    case parentTMDBID = "parent_tmdb_id"
    case seasonNumber = "season_number"
    case title
    case tmdbID = "tmdb_id"
    case year
  }
}

public enum FeatureType: String, Codable {
  case episode = "Episode"
  case movie = "Movie"
  case tvshow = "Tvshow"
}

public struct File {
  public let fileID: Int?
  public let fileName: String?

  public init(fileID: Int? = nil, fileName: String? = nil) {
    self.fileID = fileID
    self.fileName = fileName
  }
}

extension File: Codable {
  enum CodingKeys: String, CodingKey {
    case fileID = "file_id"
    case fileName = "file_name"
  }
}

public struct Uploader {
  public let name: String?
  public let rank: String?
  public let uploaderID: Int?

  public init(
    name: String? = nil,
    rank: String? = nil,
    uploaderID: Int? = nil
  ) {
    self.name = name
    self.rank = rank
    self.uploaderID = uploaderID
  }
}

extension Uploader: Codable {
  enum CodingKeys: String, CodingKey {
    case name
    case rank
    case uploaderID = "uploader_id"
  }
}

public enum SearchSubtitlesAITranslated: String {
  case exclude
  case include
}

public enum SearchSubtitlesForeignPartsOnly: String {
  case exclude
  case include
  case only
}

public enum SearchSubtitlesHearingImpaired: String {
  case exclude
  case include
  case only
}

public enum SearchSubtitlesMachineTranslated: String {
  case exclude
  case include
}

public enum SearchSubtitlesMoviehashMatch: String {
  case include
  case only
}

public enum SearchSubtitlesOrderBy: String {
  case aiTranslated = "ai_translated"
  case downloadCount = "download_count"
  case foreignPartsOnly = "foreign_parts_only"
  case fps
  case fromTrusted = "from_trusted"
  case hd
  case hearingImpaired = "hearing_impaired"
  case language
  case machineTranslated = "machine_translated"
  case points
  case ratings
  case release
  case uploadDate = "upload_date"
  case votes
}

public enum SearchSubtitlesOrderDirection: String {
  case asc
  case desc
}

public enum SearchSubtitlesTrustedSources: String {
  case include
  case only
}

public enum SearchSubtitlesFeatureType: String {
  case episode
  case movie
  case tvshow
}

extension SearchService {
  // swiftlint:disable:next cyclomatic_complexity
  public func subtitles(
    aiTranslated: SearchSubtitlesAITranslated? = nil,
    episodeNumber: Int? = nil,
    foreignPartsOnly: SearchSubtitlesForeignPartsOnly? = nil,
    hearingImpaired: SearchSubtitlesHearingImpaired? = nil,
    id: Int? = nil,
    imdbID: Int? = nil,
    languages: String? = nil,
    machineTranslated: SearchSubtitlesMachineTranslated? = nil,
    moviehashMatch: SearchSubtitlesMoviehashMatch? = nil,
    moviehash: String? = nil,
    orderBy: SearchSubtitlesOrderBy? = nil,
    orderDirection: SearchSubtitlesOrderDirection? = nil,
    page: Int? = nil,
    parentFeatureID: Int? = nil,
    parentIMDBID: Int? = nil,
    parentTMDBID: Int? = nil,
    query: String? = nil,
    seasonNumber: Int? = nil,
    tmdbID: Int? = nil,
    trustedSources: SearchSubtitlesTrustedSources? = nil,
    type: SearchSubtitlesFeatureType? = nil,
    userID: Int? = nil,
    year: Int? = nil
  ) async throws -> PaginatedEntity<AttributedEntity<SubtitlesEntity>> {
    let client = try refer()

    var queryItems: [URLQueryItem] = []
    if let aiTranslated {
      queryItems.append(URLQueryItem(name: "ai_translated", value: aiTranslated))
    }
    if let episodeNumber {
      queryItems.append(URLQueryItem(name: "episode_number", value: episodeNumber))
    }
    if let foreignPartsOnly {
      queryItems.append(URLQueryItem(name: "foreign_parts_only", value: foreignPartsOnly))
    }
    if let hearingImpaired {
      queryItems.append(URLQueryItem(name: "hearing_impaired", value: hearingImpaired))
    }
    if let id {
      queryItems.append(URLQueryItem(name: "id", value: id))
    }
    if let imdbID {
      queryItems.append(URLQueryItem(name: "imdb_id", value: imdbID))
    }
    if let languages {
      queryItems.append(URLQueryItem(name: "languages", value: languages))
    }
    if let machineTranslated {
      queryItems.append(URLQueryItem(name: "machine_translated", value: machineTranslated))
    }
    if let moviehashMatch {
      queryItems.append(URLQueryItem(name: "moviehash_match", value: moviehashMatch))
    }
    if let moviehash {
      queryItems.append(URLQueryItem(name: "moviehash", value: moviehash))
    }
    if let orderBy {
      queryItems.append(URLQueryItem(name: "order_by", value: orderBy))
    }
    if let orderDirection {
      queryItems.append(URLQueryItem(name: "order_direction", value: orderDirection))
    }
    if let page {
      queryItems.append(URLQueryItem(name: "page", value: page))
    }
    if let parentFeatureID {
      queryItems.append(URLQueryItem(name: "parent_feature_id", value: parentFeatureID))
    }
    if let parentIMDBID {
      queryItems.append(URLQueryItem(name: "parent_imdb_id", value: parentIMDBID))
    }
    if let parentTMDBID {
      queryItems.append(URLQueryItem(name: "parent_tmdb_id", value: parentTMDBID))
    }
    if let query {
      queryItems.append(URLQueryItem(name: "query", value: query))
    }
    if let seasonNumber {
      queryItems.append(URLQueryItem(name: "season_number", value: seasonNumber))
    }
    if let tmdbID {
      queryItems.append(URLQueryItem(name: "tmdb_id", value: tmdbID))
    }
    if let trustedSources {
      queryItems.append(URLQueryItem(name: "trusted_sources", value: trustedSources))
    }
    if let type {
      queryItems.append(URLQueryItem(name: "type", value: type))
    }
    if let userID {
      queryItems.append(URLQueryItem(name: "user_id", value: userID))
    }
    if let year {
      queryItems.append(URLQueryItem(name: "year", value: year))
    }

    let url = try client.url(path: "subtitles", with: queryItems)
    let request = client
      .request(url: url)
      .httpMethod(.get)
    return try await client.entity(
      PaginatedEntity<AttributedEntity<SubtitlesEntity>>.self,
      from: request
    )
  }
}
