// I don't understand what this machine wants from me.
// swiftlint:disable collection_alignment
import Foundation
import ProjectDescription

let project = Project(
  name: "osub",
  organizationName: "me.vanyauhalin",
  packages: [
    .package(
      url: "https://github.com/apple/swift-argument-parser.git",
      from: "1.2.0"
    ),
    .package(
      url: "https://github.com/LebJe/TOMLKit.git",
      from: "0.5.0"
    )
  ],
  targets: [
    Target(
      name: "osub",
      platform: .macOS,
      product: .commandLineTool,
      bundleId: "me.vanyauhalin.osub",
      deploymentTarget: .macOS(targetVersion: "10.15"),
      infoPlist: .dictionary([
        "API_KEY": "$(API_KEY)",
        "CFBundleDevelopmentRegion": "$(DEVELOPMENT_LANGUAGE)",
        "CFBundleExecutable": "$(EXECUTABLE_NAME)",
        "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
        "CFBundleInfoDictionaryVersion": "6.0",
        "CFBundleName": "$(PRODUCT_NAME)",
        "CFBundleVersion": "\(Environment.buildVersion.getString(default: ""))",
        "NSHumanReadableCopyright": "Copyright © 2023 vanyauhalin. All rights reserved."
      ]),
      sources: "osub/OpenSubtitlesCLI.swift",
      dependencies: [
        .package(product: "ArgumentParser"),
        .package(product: "TOMLKit"),
        .target(name: "Client"),
        .target(name: "Command"),
        .target(name: "Configuration"),
        .target(name: "Downloads"),
        .target(name: "Extensions"),
        .target(name: "Hash"),
        .target(name: "Listable"),
        .target(name: "Network"),
        .target(name: "State"),
        .target(name: "TablePrinter")
      ],
      settings: .settings(configurations: [
        .release(
          name: "Release",
          settings: [
            "API_KEY": "\(Environment.apiKey.getString(default: ""))",
            "CREATE_INFOPLIST_SECTION_IN_BINARY": true
          ]
        )
      ])
    ),
    Target(
      name: "Client",
      dependencies: [
        .target(name: "Extensions"),
        .target(name: "Network")
      ]
    ),
    Target(
      name: "ClientTests",
      dependencies: [
        .target(name: "TestCase")
      ]
    ),
    Target(
      name: "Command",
      dependencies: [
        .package(product: "ArgumentParser"),
        .package(product: "TOMLKit"),
        .target(name: "Client"),
        .target(name: "Configuration"),
        .target(name: "Downloads"),
        .target(name: "Extensions"),
        .target(name: "Hash"),
        .target(name: "Listable"),
        .target(name: "Network"),
        .target(name: "State"),
        .target(name: "TablePrinter")
      ]
    ),
    Target(
      name: "CommandTests",
      dependencies: [
        .target(name: "TestCase")
      ]
    ),
    Target(
      name: "Configuration",
      dependencies: [
        .package(product: "TOMLKit"),
        .target(name: "Extensions")
      ]
    ),
    Target(
      name: "ConfigurationTests",
      dependencies: [
        .target(name: "TestCase")
      ]
    ),
    Target(
      name: "Downloads",
      dependencies: [
        .package(product: "TOMLKit"),
        .target(name: "Configuration"),
        .target(name: "Extensions")
      ]
    ),
    Target(
      name: "DownloadsTests",
      dependencies: [
        .target(name: "TestCase")
      ]
    ),
    Target(
      name: "Extensions"
    ),
    Target(
      name: "Hash"
    ),
    Target(
      name: "HashTests",
      dependencies: [
        .target(name: "Extensions")
      ]
    ),
    Target(
      name: "Listable"
    ),
    Target(
      name: "ListableTests"
    ),
    Target(
      name: "Network"
    ),
    Target(
      name: "State",
      dependencies: [
        .package(product: "TOMLKit"),
        .target(name: "Configuration"),
        .target(name: "Extensions")
      ]
    ),
    Target(
      name: "StateTests",
      dependencies: [
        .target(name: "TestCase")
      ]
    ),
    Target(
      name: "TablePrinter"
    ),
    Target(
      name: "TestCase",
      dependencies: [
        .package(product: "TOMLKit"),
        .target(name: "Client"),
        .target(name: "Configuration"),
        .target(name: "Extensions"),
        .target(name: "Network"),
        .target(name: "State"),
        .xctest
      ]
    )
  ]
)

let config = Config(
  compatibleXcodeVersions: ["14.0"],
  swiftVersion: "5.7.0"
)

// MARK: Extensions

extension Target {
  init(name: String, dependencies: [TargetDependency] = []) {
    if name.hasSuffix("Tests") {
      let library = String(name.dropLast("Tests".count))
      self.init(
        name: name,
        platform: .macOS,
        product: .unitTests,
        bundleId: "me.vanyauhalin.\(name)",
        deploymentTarget: .macOS(targetVersion: "10.15"),
        infoPlist: .dictionary([:]),
        sources: [
          "osub/\(library)/*Tests.swift"
        ],
        dependencies: dependencies + [
          .target(name: library),
          .xctest
        ]
      )
      return
    }
    self.init(
      name: name,
      platform: .macOS,
      product: .staticLibrary,
      bundleId: "me.vanyauhalin.\(name)",
      deploymentTarget: .macOS(targetVersion: "10.15"),
      sources: .relative([
        "!osub/\(name)/*Tests.swift",
        "osub/\(name)/*.swift"
      ]),
      scripts: [
        .lint("osub/\(name)")
      ],
      dependencies: dependencies
    )
  }
}

extension SourceFilesList {
  static func relative(_ paths: [String]) -> SourceFilesList {
    let including = paths.filter { path in
      !path.starts(with: "!")
    }
    let excluding = paths
      .filter { path in
        path.starts(with: "!")
      }
      .map { path in
        path.replacingOccurrences(of: "!", with: "")
      }
    return SourceFilesList(
      globs: including.map { path in
        .glob(
          .relativeToManifest(path),
          excluding: excluding.map { path in
            Path(path)
          }
        )
      }
    )
  }
}

extension TargetScript {
  static func make(
    _ subcommand: String,
    _ arguments: [String: String] = [:]
  ) -> TargetScript {
    let makefile = Environment.makefilePath.getString(default: "")
    let arguments = arguments
      .map { key, value in
        "\(key)=\(value)"
      }
      .joined(separator: " ")
    return .pre(
      script: "make -f \(makefile) \(subcommand) \(arguments)",
      name: "make \(subcommand)"
    )
  }

  static func lint(_ target: String) -> TargetScript {
    .make("lint", [
      "target": target
    ])
  }
}
