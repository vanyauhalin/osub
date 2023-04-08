public protocol Listable: CustomStringConvertible {}

extension Listable {
  public var description: String {
    let mirror = Mirror(reflecting: self)
    var lines: [String] = []

    for (label, value) in mirror.children {
      guard let label else {
        continue
      }

      if case Optional<Any>.none = value {
        continue
      }

      if let string = value as? String {
        lines.append("\(label)=\(string)")
        continue
      }
    }

    return lines.joined(separator: "\n")
  }
}
