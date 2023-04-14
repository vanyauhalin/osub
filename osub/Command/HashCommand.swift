import ArgumentParser
import Hash

struct HashCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "hash",
    abstract: "Calculate the hash of the file."
  )

  @Argument(help: "The path to the file whose hash is to be calculated.")
  var path: String

  var output = StandardTextOutputStream.shared

  mutating func run() throws {
    let hash = try Hash.hash(of: path)
    print(hash, to: &output)
  }
}

extension HashCommand {
  enum CodingKeys: CodingKey {
    case path
  }
}
