public struct TablePrinter {
  var rows: [[String]] = []

  public init() {}

  public mutating func append(_ field: Int) {
    append(String(field))
  }

  public mutating func append(_ field: String) {
    if rows.isEmpty {
      rows.append([])
    }
    rows[rows.count - 1].append(field)
  }

  public mutating func end() {
    rows.append([])
  }

  public func print() {
    let delimiter = "  "
    let widths = calculateColumnWidths()
    rows.enumerated().forEach { index, row in
      row.enumerated().forEach { column, field in
        let spaceRepeatCount = widths[column] - field.count
        let space = spaceRepeatCount >= 0
          ? String(repeating: " ", count: spaceRepeatCount)
          : ""
        if column == row.count - 1 {
          Swift.print("\(field)\(space)", terminator: "")
          return
        }
        Swift.print("\(field)\(space)\(delimiter)", terminator: "")
      }
      if index != rows.count - 1 {
        Swift.print()
      }
    }
  }

  func calculateColumnWidths() -> [Int] {
    var widths: [Int] = []
    rows.forEach { row in
      row.enumerated().forEach { column, field in
        guard widths.indices.contains(column) else {
          widths.insert(field.count, at: column)
          return
        }
        if field.count > widths[column] {
          widths[column] = field.count
        }
      }
    }
    return widths
  }
}
