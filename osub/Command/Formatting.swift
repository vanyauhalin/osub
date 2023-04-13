import ArgumentParser
import TablePrinter

protocol FormattingField: RawRepresentable<String>, CaseIterable, ExpressibleByArgument {
  static var defaultValues: [Self] { get }
  var text: String { get }
}

struct FormattingOptions<Field>: ParsableArguments where Field: FormattingField {
  @Option(
    parsing: .upToNextOption,
    help: ArgumentHelp(
      "Space-separated list of fields to print.",
      valueName: .array(.enum)
    )
  )
  var fields = Field.defaultValues

  func printer() -> TablePrinter {
    var printer = TablePrinter()
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
  }
}
