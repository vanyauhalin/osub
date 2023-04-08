import ArgumentParser
import Command

@main
struct OpenSubtitlesCLI: AsyncParsableCommand {
  static let configuration = Command.configuration
}
