public struct Field {
  public let text: String
  public let truncatable: Bool

  public init(text: String, truncatable: Bool = true) {
    self.text = text
    self.truncatable = truncatable
  }

  public init(header: String, truncatable: Bool = true) {
    self.text = header.uppercased()
    self.truncatable = truncatable
  }
}

public struct TablePrinter {
  private let window: WindowProtocol
  private let delimiter = "  "
  private let ellipsis = "..."

  var rows: [[Field]] = [[]]

  public init(window: WindowProtocol = Window.shared) {
    self.window = window
  }

  public mutating func append(_ field: Field) {
    rows[rows.count - 1].append(field)
  }

  public mutating func append(_ text: String) {
    let field = Field(text: text)
    append(field)
  }

  public mutating func append(_ number: Int) {
    let text = String(number)
    append(text)
  }

  public mutating func next() {
    rows.append([])
  }

  public func print() {
    let columnsWidths = columnsWidths()
    rows.enumerated().forEach { index, row in
      row.enumerated().forEach { column, field in
        let columnWidth = columnsWidths[column]
        let text = field.text.count > columnWidth && field.truncatable
          ? field.text.prefix(columnWidth - ellipsis.count) + ellipsis
          : field.text
        let spaceCount = columnWidth - text.count
        let space = spaceCount >= 0
          ? String(repeating: " ", count: spaceCount)
          : ""
        if column == row.count - 1 {
          Swift.print("\(text)\(space)", terminator: "")
          return
        }
        Swift.print("\(text)\(space)\(delimiter)", terminator: "")
      }
      if index != rows.count - 1 {
        Swift.print()
      }
    }
  }

  // swiftlint:disable:next cyclomatic_complexity
  func columnsWidths() -> [Int] {
    let countColumns = rows.first?.count ?? .zero
    var maximumColumnsWidths = Array(repeating: Int.zero, count: countColumns)
    var columnsWidths = Array(repeating: Int.zero, count: countColumns)

    rows.forEach { row in
      row.enumerated().forEach { column, field in
        let width = field.text.count
        if width > maximumColumnsWidths[column] {
          maximumColumnsWidths[column] = width
        }
        if !field.truncatable, width > columnsWidths[column] {
          columnsWidths[column] = width
        }
      }
    }

    func availableWidth() -> Int {
      window.columns
        - delimiter.count * (countColumns - 1)
        - columnsWidths.reduce(Int.zero) { result, width  in
          result + width
        }
    }

    func countFixedColumns() -> Int {
      columnsWidths.reduce(Int.zero) { result, width in
        width > .zero ? result + 1 : result
      }
    }

    _ = {
      let availableWidth = availableWidth()
      if availableWidth > 0 {
        let countFlexedColumns = countColumns - countFixedColumns()
        if countFlexedColumns > 0 {
          let perWidth = availableWidth / countFlexedColumns
          for column in .zero..<countColumns {
            let maximumWidth = maximumColumnsWidths[column]
            if maximumWidth < perWidth {
              columnsWidths[column] = maximumWidth
            }
          }
        }
      }
    }()

    _ = {
      let countFlexedColumns = countColumns - countFixedColumns()
      if countFlexedColumns > 0 {
        let availableWidth = availableWidth()
        let perWidth = availableWidth / countFlexedColumns
        for column in .zero..<countColumns {
          let width = columnsWidths[column]
          if width > .zero {
            continue
          }
          let maximumWidth = maximumColumnsWidths[column]
          if maximumWidth < perWidth {
            columnsWidths[column] = maximumWidth
            continue
          }
          if perWidth > .zero {
            columnsWidths[column] = perWidth
          }
        }
      }
    }()

    _ = {
      var availableWidth = availableWidth()
      if availableWidth > .zero {
        for column in .zero..<countColumns {
          let diffWidth = maximumColumnsWidths[column] - columnsWidths[column]
          let additionalWidth = diffWidth >= availableWidth ? availableWidth : diffWidth
          columnsWidths[column] += additionalWidth
          availableWidth -= additionalWidth
          if availableWidth <= .zero {
            break
          }
        }
      }
    }()

    return columnsWidths
  }
}
