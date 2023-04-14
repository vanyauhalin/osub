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

// MARK: Output

open class StandardTextOutputStream: TextOutputStream {
  public static let shared = StandardTextOutputStream()

  public init() {}

  open func write(_ string: String) {
    print(string, terminator: "")
  }
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

  func printer<Output>(output: Output) -> TablePrinter<Output>
  where Output: TextOutputStream {
    let window = frame ? Window.shared : Window(columns: .max)
    var printer = TablePrinter(window: window, output: output)
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

extension ClientProtocol {
  func configure(config: Configuration, state: State) {
    self.configure(
      apiKey: config.apiKey,
      baseURL: state.baseURL,
      token: state.token
    )
  }
}

extension TablePrinter {
  mutating func append(_ field: String? = nil) {
    guard let field else {
      append("?")
      return
    }
    append(field)
  }

  mutating func append<T>(_ field: T? = nil) where T: LosslessStringConvertible {
    guard let field else {
      append()
      return
    }
    append(String(field))
  }

  mutating func append<T>(_ field: T? = nil) where T: RawRepresentable<String> {
    append(field?.rawValue)
  }
}
