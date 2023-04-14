public struct TablePrinter {
  private let delimiter = "  "
  private let ellipsis = "..."

  private let window: WindowProtocol

  var rows: [[String]] = [[]]

  public init(window: WindowProtocol = Window.shared) {
    self.window = window
  }

  public mutating func append(_ field: String) {
    rows[rows.count - 1].append(field)
  }

  public mutating func next() {
    rows.append([])
  }

  public func print() {
    let columnsWidths = columnsWidths()
    rows.enumerated().forEach { index, row in
      row.enumerated().forEach { column, field in
        let columnWidth = columnsWidths[column]
        let text = field.count > columnWidth
          ? field.prefix(columnWidth - ellipsis.count) + ellipsis
          : field
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
        let width = field.count
        if width > maximumColumnsWidths[column] {
          maximumColumnsWidths[column] = width
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
