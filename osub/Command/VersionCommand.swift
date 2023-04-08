import ArgumentParser
import Foundation

struct VersionCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "version",
    abstract: "Print the current osub version."
  )

  var bundle: Bundle = .main

  var version: String {
    (bundle.infoDictionary?["CFBundleVersion"] as? String) ?? "unknown"
  }

  var release: String {
    "https://github.com/vanyauhalin/osub/releases/tag/v\(version)"
  }

  func run() {
    print(version)
    print(release)
  }
}

extension VersionCommand {
  init(from decoder: Decoder) throws {}
}
