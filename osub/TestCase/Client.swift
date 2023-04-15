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
  let mockedLogin: (() -> LoginEntity)?
  let mockedLogout: (() -> InformationEntity)?

  public init(
    login: (() -> LoginEntity)? = nil,
    logout: (() -> InformationEntity)? = nil
  ) {
    self.mockedLogin = login
    self.mockedLogout = logout
  }

  public func login(username: String, password: String) async throws -> LoginEntity {
    guard let mockedLogin else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedLogin()
  }

  public func logout() async throws -> InformationEntity {
    guard let mockedLogout else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedLogout()
  }
}

public final class MockedDownloadsService: DownloadsServiceProtocol {
  public let mockedPost: (() -> DownloadEntity)?

  public init(post: (() -> DownloadEntity)? = nil) {
    self.mockedPost = post
  }

  public func post(
    fileID: Int,
    fileName: String? = nil,
    inFPS: Int? = nil,
    outFPS: Int? = nil,
    subFormat: String? = nil,
    timeshift: Int? = nil
  ) async throws -> DownloadEntity {
    guard let mockedPost else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedPost()
  }
}

public final class MockedInformationService: InformationServiceProtocol {
  public let mockedFormats: (() -> DatumedEntity<FormatsEntity>)?
  public let mockedLanguages: (() -> DatumedEntity<[LanguageEntity]>)?
  public let mockedUser: (() -> DatumedEntity<UserEntity>)?

  public init(
    formats: (() -> DatumedEntity<FormatsEntity>)? = nil,
    languages: (() -> DatumedEntity<[LanguageEntity]>)? = nil,
    user: (() -> DatumedEntity<UserEntity>)? = nil
  ) {
    self.mockedFormats = formats
    self.mockedLanguages = languages
    self.mockedUser = user
  }

  public func formats() async throws -> DatumedEntity<FormatsEntity> {
    guard let mockedFormats else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedFormats()
  }

  public func languages() async throws -> DatumedEntity<[LanguageEntity]> {
    guard let mockedLanguages else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedLanguages()
  }

  public func user() async throws -> DatumedEntity<UserEntity> {
    guard let mockedUser else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedUser()
  }
}

public final class MockedSearchService: SearchServiceProtocol {
  public let mockedFeatures: (() -> DatumedEntity<[AttributedEntity<FeatureEntity>]>)?
  public let mockedSubtitles: (() -> PaginatedEntity<AttributedEntity<SubtitlesEntity>>)?

  public init(
    features: (() -> DatumedEntity<[AttributedEntity<FeatureEntity>]>)? = nil,
    subtitles: (() -> PaginatedEntity<AttributedEntity<SubtitlesEntity>>)? = nil
  ) {
    self.mockedFeatures = features
    self.mockedSubtitles = subtitles
  }

  public func features(
    featureID: Int? = nil,
    imdbID: String? = nil,
    query: String? = nil,
    tmdbID: Int? = nil,
    type: SearchServiceType? = nil,
    year: Int? = nil
  ) async throws -> DatumedEntity<[AttributedEntity<FeatureEntity>]> {
    guard let mockedFeatures else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedFeatures()
  }

  // swiftlint:disable:next function_parameter_count
  public func subtitles(
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
  ) async throws -> PaginatedEntity<AttributedEntity<SubtitlesEntity>> {
    guard let mockedSubtitles else {
      fatalError("The \(#function) is not implemented.")
    }
    return mockedSubtitles()
  }
}
