import ArgumentParser
import Client
import Configuration
import State
import TablePrinter

public struct Command: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "osub",
    abstract: "OpenSubtitles in your terminal.",
    subcommands: [
      AuthenticationCommand.self,
      ConfigurationCommand.self,
      DownloadCommand.self,
      HashCommand.self,
      LanguagesCommand.self,
      SearchCommand.self,
      VersionCommand.self
    ],
    defaultSubcommand: SearchCommand.self
  )

  public init() {}
}

// MARK: Formatting

protocol FormattingField:
  RawRepresentable<String>,
  CaseIterable,
  ExpressibleByArgument
{
  static var defaultValues: [Self] { get }
  var text: String { get }
}

struct FormattingOptions<Field>: ParsableArguments
where Field: FormattingField {
  @Option(
    parsing: .upToNextOption,
    help: ArgumentHelp(
      "Space-separated list of fields to print.",
      valueName: .array(.enum)
    )
  )
  var fields = Field.defaultValues

  @Flag(
    inversion: .prefixedNo,
    help: "Consider the window size when formatting."
  )
  var frame = true

  func printer() -> TablePrinter {
    let window = frame ? Window.shared : Window(columns: .max)
    var printer = TablePrinter(window: window)
    fields.forEach { field in
      let header = field.text.uppercased()
      printer.append(header)
    }
    printer.next()
    return printer
  }
}

extension FormattingOptions {
  enum CodingKeys: CodingKey {
    case fields
    case frame
  }
}

// MARK: Extensions

extension ClientProtocol {
  func configure(config: Configuration, state: State) {
    self.configure(
      apiKey: config.apiKey,
      baseURL: state.baseURL,
      token: state.token
    )
  }
}

indirect enum ValueName {
  case array(ValueName)
  case `enum`
  case int
  case path
  case string

  var rawValue: String {
    switch self {
    case .array(let valueName):
      return "[\(valueName.rawValue)]"
    case .enum:
      return "enum"
    case .int:
      return "int"
    case .path:
      return "path"
    case .string:
      return "string"
    }
  }
}

extension ArgumentHelp {
  init(
    _ abstract: String = "",
    discussion: String = "",
    valueName: ValueName? = nil
  ) {
    self.init(
      abstract,
      discussion: discussion,
      valueName: valueName?.rawValue
    )
  }
}
