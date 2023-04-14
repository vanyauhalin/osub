import ArgumentParser
import Foundation

struct VersionCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "version",
    abstract: "Print the current osub version."
  )

  var bundle: Bundle = .main
  var output = StandardTextOutputStream.shared

  mutating func run() {
    let version = (bundle.infoDictionary?["CFBundleVersion"] as? String) ?? ""
    let release = "https://github.com/vanyauhalin/osub/releases/tag/v\(version)"
    print(version, to: &output)
    print(release, to: &output)
  }
}

extension VersionCommand {
  init(from decoder: Decoder) throws {}
}
