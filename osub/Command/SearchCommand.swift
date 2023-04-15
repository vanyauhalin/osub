import ArgumentParser
import Client
import Configuration
import Hash
import State

struct SearchCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "search",
    abstract: "Search for subtitles.",
    subcommands: [
      SearchSubtitlesCommand.self
    ],
    defaultSubcommand: SearchSubtitlesCommand.self
  )
}

struct SearchSubtitlesCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "subtitles",
    abstract: "Search for subtitles."
  )

  @OptionGroup(title: "Query Options")
  var query: QueryOptions

  @OptionGroup(title: "Utility Options")
  var utility: UtilityOptions

  @OptionGroup(title: "Formatting Options")
  var formatting: FormattingOptions<Field>

  var output = StandardTextOutputStream.shared
  var configManager: ConfigurationManagerProtocol = ConfigurationManager.shared
  var stateManager: StateManagerProtocol = StateManager.shared
  var client: ClientProtocol = Client.shared

  func validate() throws {
    if
      query.moviehash != nil,
      utility.file != nil
    {
      throw ValidationError("The movehash and file options cannot be used together.")
    }
  }

  mutating func run() async throws {
    try configure()
    try await action()
  }

  func configure() throws {
    let config = try configManager.load()
    let state = try stateManager.load()
    client.configure(config: config, state: state)
  }

  mutating func action() async throws {
    let subtitles = try await client.search.subtitles(
      aiTranslated: query.aiTranslated,
      episodeNumber: query.episodeNumber,
      foreignPartsOnly: query.foreignPartsOnly,
      hearingImpaired: query.hearingImpaired,
      id: query.id,
      imdbID: query.imdbID,
      languages: query.languages.isEmpty
        ? nil
        : query.languages.joined(separator: ","),
      machineTranslated: query.machineTranslated,
      moviehashMatch: query.moviehashMatch,
      moviehash: try {
        if let moviehash = query.moviehash {
          return moviehash
        }
        if let file = utility.file {
          return try Hash.hash(of: file)
        }
        return nil
      }(),
      orderBy: query.orderBy,
      orderDirection: query.orderDirection,
      page: query.page,
      parentFeatureID: query.parentFeatureID,
      parentIMDBID: query.parentIMDBID,
      parentTMDBID: query.parentTMDBID,
      query: query.query,
      seasonNumber: query.seasonNumber,
      tmdbID: query.tmdbID,
      trustedSources: query.trustedSources,
      type: query.type,
      userID: query.userID,
      year: query.year
    )
    let languages = try await client.info.languages()

    var printer = formatting.printer(output: output)

    // swiftlint:disable:next cyclomatic_complexity
    func resolve(entity: AttributedEntity<SubtitlesEntity>, file: File? = nil) {
      formatting.fields.forEach { field in
        switch field {
        case .aiTranslated:
          printer.append(entity.attributes.aiTranslated)
        case .downloadCount:
          printer.append(entity.attributes.downloadCount)
        case .episodeNumber:
          printer.append(entity.attributes.featureDetails?.episodeNumber)
        case .featureID:
          printer.append(entity.attributes.featureDetails?.featureID)
        case .featureType:
          printer.append(entity.attributes.featureDetails?.featureType)
        case .fileID:
          printer.append(file?.fileID)
        case .fileName:
          printer.append(file?.fileName)
        case .foreignPartsOnly:
          printer.append(entity.attributes.foreignPartsOnly)
        case .fps:
          printer.append(entity.attributes.fps)
        case .fromTrusted:
          printer.append(entity.attributes.fromTrusted)
        case .hd:
          printer.append(entity.attributes.hd)
        case .hearingImpaired:
          printer.append(entity.attributes.hearingImpaired)
        case .id:
          printer.append(entity.id)
        case .imdbID:
          printer.append(entity.attributes.featureDetails?.imdbID)
        case .language:
          let language = languages.data.first { language in
            language.languageCode == entity.attributes.language
          }
          printer.append(language?.languageName)
        case .machineTranslated:
          printer.append(entity.attributes.machineTranslated)
        case .movieName:
          printer.append(entity.attributes.featureDetails?.movieName)
        case .parentFeatureID:
          printer.append(entity.attributes.featureDetails?.parentFeatureID)
        case .parentIMDBID:
          printer.append(entity.attributes.featureDetails?.parentIMDBID)
        case .parentTitle:
          printer.append(entity.attributes.featureDetails?.parentTitle)
        case .parentTMDBID:
          printer.append(entity.attributes.featureDetails?.parentTMDBID)
        case .ratings:
          printer.append(entity.attributes.ratings)
        case .release:
          printer.append(entity.attributes.release)
        case .seasonNumber:
          printer.append(entity.attributes.featureDetails?.seasonNumber)
        case .title:
          printer.append(entity.attributes.featureDetails?.title)
        case .tmdbID:
          printer.append(entity.attributes.featureDetails?.tmdbID)
        case .uploaderID:
          printer.append(entity.attributes.uploader?.uploaderID)
        case .uploaderName:
          printer.append(entity.attributes.uploader?.name)
        case .uploaderRank:
          printer.append(entity.attributes.uploader?.rank)
        case .uploadDate:
          printer.append(entity.attributes.uploadDate)
        case .votes:
          printer.append(entity.attributes.votes)
        case .year:
          printer.append(entity.attributes.featureDetails?.year)
        }
      }
    }

    subtitles.data.enumerated().forEach { index, entity in
      if entity.attributes.files.isEmpty {
        resolve(entity: entity)
      } else {
        entity.attributes.files.forEach { file in
          resolve(entity: entity, file: file)
        }
      }
      if index < subtitles.data.count - 1 {
        printer.next()
      }
    }

    let total = subtitles.totalCount
    // The documentation says 60, but in reality it's 50.
    let perPage = 50
    let page = query.page ?? 1
    let pages = Int((Double(total) / Double(perPage)).rounded(.awayFromZero))

    print(
      "\nPrinting \(page) page of \(pages) for \(total) subtitles.\n",
      to: &output
    )
    printer.print()
  }
}

extension SearchSubtitlesCommand {
  enum CodingKeys: CodingKey {
    case query
    case utility
    case formatting
  }

  struct QueryOptions: ParsableArguments {
    @Option(
      help: ArgumentHelp(
        "Restrict search to AI-translated subtitles.",
        valueName: .enum
      )
    )
    var aiTranslated: SearchSubtitlesAITranslated?

    @Option(
      help: ArgumentHelp(
        "Search by TV Show episode number.",
        valueName: .int
      )
    )
    var episodeNumber: Int?

    @Option(
      help: ArgumentHelp(
        "Restrict search to Foreign Parts Only (FPO) subtitles.",
        valueName: .enum
      )
    )
    var foreignPartsOnly: SearchSubtitlesForeignPartsOnly?

    @Option(
      help: ArgumentHelp(
        "Restrict search to subtitles for the hearing impaired.",
        valueName: .enum
      )
    )
    var hearingImpaired: SearchSubtitlesHearingImpaired?

    @Option(
      help: ArgumentHelp(
        "Search by feature ID from the features search results.",
        valueName: .int
      )
    )
    var id: Int?

    @Option(
      help: ArgumentHelp(
        "Search by feature IMDB ID.",
        valueName: .int
      )
    )
    var imdbID: Int?

    @Option(
      parsing: .upToNextOption,
      help: ArgumentHelp(
        "Search on space-separated list of subtag languages.",
        valueName: .array(.string)
      )
    )
    var languages: [String] = []

    @Option(
      help: ArgumentHelp(
        "Restrict search to machine-translated subtitles.",
        valueName: .enum
      )
    )
    var machineTranslated: SearchSubtitlesMachineTranslated?

    @Option(
      help: ArgumentHelp(
        "Restrict search to subtitles with feature hash match.",
        valueName: .enum
      )
    )
    var moviehashMatch: SearchSubtitlesMoviehashMatch?

    @Option(
      help: ArgumentHelp(
        "Search by feature hash.",
        valueName: .string
      )
    )
    var moviehash: String?

    @Option(
      help: ArgumentHelp(
        "Order of returned results by field.",
        valueName: .enum
      )
    )
    var orderBy: SearchSubtitlesOrderBy?

    @Option(
      help: ArgumentHelp(
        "Order of returned results by direction.",
        valueName: .enum
      )
    )
    var orderDirection: SearchSubtitlesOrderDirection?

    @Option(
      help: ArgumentHelp(
        "Search on the page.",
        valueName: .int
      )
    )
    var page: Int?

    @Option(
      help: ArgumentHelp(
        "Search for the TV Show by parent feature ID from the features search results.",
        valueName: .int
      )
    )
    var parentFeatureID: Int?

    @Option(
      name: .customLong("parent-imdb-id"),
      help: ArgumentHelp(
        "Search for the TV Show by parent IMDB ID.",
        valueName: .int
      )
    )
    var parentIMDBID: Int?

    @Option(
      name: .customLong("parent-tmdb-id"),
      help: ArgumentHelp(
        "Search for the TV Show by parent TMDB ID.",
        valueName: .int
      )
    )
    var parentTMDBID: Int?

    @Option(
      help: ArgumentHelp(
        "Search by file name or string query.",
        valueName: .string
      )
    )
    var query: String?

    @Option(
      help: ArgumentHelp(
        "Search for the TV Show by season number.",
        valueName: .int
      )
    )
    var seasonNumber: Int?

    @Option(
      help: ArgumentHelp(
        "Search by feature TMDB ID.",
        valueName: .int
      )
    )
    var tmdbID: Int?

    @Option(
      help: ArgumentHelp(
        "Restrict search to trusted sources.",
        valueName: .enum
      )
    )
    var trustedSources: SearchSubtitlesTrustedSources?

    @Option(
      help: ArgumentHelp(
        "Restrict search to feature type.",
        valueName: .enum
      )
    )
    var type: SearchSubtitlesFeatureType?

    @Option(
      help: ArgumentHelp(
        "Search for uploaded subtitles by user ID.",
        valueName: .int
      )
    )
    var userID: Int?

    @Option(
      help: ArgumentHelp(
        "Search by year.",
        valueName: .int
      )
    )
    var year: Int?
  }

  struct UtilityOptions: ParsableArguments {
    @Option(
      help: ArgumentHelp(
        "The path to the file that needs subtitles.",
        valueName: .path
      )
    )
    var file: String?
  }

  enum Field: String, FormattingField {
    static var defaultValues: [Self] {
      [
        .fileID,
        .fileName,
        .language,
        .uploadDate,
        .downloadCount,
        .id
      ]
    }

    case aiTranslated = "ai_translated"
    case downloadCount = "download_count"
    case episodeNumber = "episode_number"
    case featureID = "feature_id"
    case featureType = "feature_type"
    case fileID = "file_id"
    case fileName = "file_name"
    case foreignPartsOnly = "foreign_parts_only"
    case fps
    case fromTrusted = "from_trusted"
    case hd
    case hearingImpaired = "hearing_impaired"
    case id
    case imdbID = "imdb_id"
    case language
    case machineTranslated = "machine_translated"
    case movieName = "movie_name"
    case parentFeatureID = "parent_feature_id"
    case parentIMDBID = "parent_imdb_id"
    case parentTitle = "parent_title"
    case parentTMDBID = "parent_tmdb_id"
    case ratings
    case release
    case seasonNumber = "season_number"
    case title
    case tmdbID = "tmdb_id"
    case uploadDate = "upload_date"
    case uploaderID = "uploader_id"
    case uploaderName = "uploader_name"
    case uploaderRank = "uploader_rank"
    case votes
    case year

    var text: String {
      switch self {
      case .aiTranslated:
        return "AI-translated"
      case .downloadCount:
        return "downloads"
      case .episodeNumber:
        return "episode number"
      case .featureID:
        return "feature id"
      case .featureType:
        return "feature type"
      case .fileID:
        return "file id"
      case .fileName:
        return "file name"
      case .foreignPartsOnly:
        return "FPO"
      case .fps:
        return rawValue
      case .fromTrusted:
        return "trusted"
      case .hd:
        return rawValue
      case .hearingImpaired:
        return "hearing impaired"
      case .id:
        return "subtitles id"
      case .imdbID:
        return "imdb id"
      case .language:
        return rawValue
      case .machineTranslated:
        return "machine-translated"
      case .movieName:
        return "movie name"
      case .parentFeatureID:
        return "parent feature id"
      case .parentIMDBID:
        return "parent imdb id"
      case .parentTitle:
        return "parent title"
      case .parentTMDBID:
        return "parent tmdb id"
      case .ratings:
        return rawValue
      case .release:
        return rawValue
      case .seasonNumber:
        return "season number"
      case .title:
        return rawValue
      case .tmdbID:
        return "tmdb id"
      case .uploadDate:
        return "uploaded"
      case .uploaderID:
        return "uploader id"
      case .uploaderName:
        return "uploader name"
      case .uploaderRank:
        return "uploader rank"
      case .votes:
        return rawValue
      case .year:
        return rawValue
      }
    }
  }
}

// MARK: Extensions

extension SearchSubtitlesAITranslated: CaseIterable, ExpressibleByArgument {
  public static var allCases: [SearchSubtitlesAITranslated] {
    [
      .exclude,
      .include
    ]
  }
}

extension SearchSubtitlesForeignPartsOnly: CaseIterable, ExpressibleByArgument {
  public static var allCases: [SearchSubtitlesForeignPartsOnly] {
    [
      .exclude,
      .include,
      .only
    ]
  }
}

extension SearchSubtitlesHearingImpaired: CaseIterable, ExpressibleByArgument {
  public static var allCases: [SearchSubtitlesHearingImpaired] {
    [
      .exclude,
      .include,
      .only
    ]
  }
}

extension SearchSubtitlesMachineTranslated: CaseIterable, ExpressibleByArgument {
  public static var allCases: [SearchSubtitlesMachineTranslated] {
    [
      .exclude,
      .include
    ]
  }
}

extension SearchSubtitlesMoviehashMatch: CaseIterable, ExpressibleByArgument {
  public static var allCases: [SearchSubtitlesMoviehashMatch] {
    [
      .include,
      .only
    ]
  }
}

extension SearchSubtitlesOrderBy: CaseIterable, ExpressibleByArgument {
  public static var allCases: [SearchSubtitlesOrderBy] {
    [
      .aiTranslated,
      .downloadCount,
      .foreignPartsOnly,
      .fps,
      .fromTrusted,
      .hd,
      .hearingImpaired,
      .language,
      .machineTranslated,
      .points,
      .ratings,
      .release,
      .uploadDate,
      .votes
    ]
  }
}

extension SearchSubtitlesOrderDirection: CaseIterable, ExpressibleByArgument {
  public static var allCases: [SearchSubtitlesOrderDirection] {
    [
      .asc,
      .desc
    ]
  }
}

extension SearchSubtitlesTrustedSources: CaseIterable, ExpressibleByArgument {
  public static var allCases: [SearchSubtitlesTrustedSources] {
    [
      .include,
      .only
    ]
  }
}

extension SearchSubtitlesFeatureType: CaseIterable, ExpressibleByArgument {
  public static var allCases: [SearchSubtitlesFeatureType] {
    [
      .episode,
      .movie,
      .tvshow
    ]
  }
}
