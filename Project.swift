import ProjectDescription
import ProjectDescriptionHelpers
import Foundation
import Env

// MARK: - Project

let bundleId = "com.zenangst.MouseDef"

func xcconfig(_ targetName: String) -> String { "Configurations/\(targetName).xcconfig" }
func sources(_ folder: String) -> SourceFilesList { "\(folder)/Sources/**" }
func resources(_ folder: String) -> ResourceFileElements { "\(folder)/Resources/**" }

let envPath = URL(fileURLWithPath: String(#filePath))
  .deletingLastPathComponent()
  .absoluteString
  .replacingOccurrences(of: "file://", with: "")
  .appending(".env")
let env = EnvHelper(envPath)

let project = Project(
  name: "MouseDef",
  options: Project.Options.options(
    textSettings: .textSettings(indentWidth: 2,
                                tabWidth: 2)),
  packages: PackageResolver.packages(env),
  settings: Settings.settings(configurations: [
    .debug(name: "Debug", xcconfig: "\(xcconfig("Debug"))"),
    .release(name: "Release", xcconfig: "\(xcconfig("Release"))")
  ], defaultSettings: .recommended),
  targets: [
    Target(
      name: "MouseDef",
      platform: .macOS,
      product: .app,
      bundleId: bundleId,
      deploymentTarget: DeploymentTarget.macOS(targetVersion: "13.0"),
      infoPlist: .file(path: .relativeToRoot("App/Info.plist")),
      sources: sources("App"),
      resources: resources("App"),
      entitlements: "App/Entitlements/com.zenangst.MouseDef.entitlements",
      dependencies: [
        .package(product: "AXEssibility"),
        .package(product: "Bonzai"),
        .package(product: "MachPort"),
        .package(product: "Sparkle"),
        .package(product: "Windows"),
      ],
      settings:
        Settings.settings(
          base: [
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
            "CODE_SIGN_IDENTITY": "Apple Development",
            "CODE_SIGN_STYLE": "Automatic",
            "CURRENT_PROJECT_VERSION": "191",
            "DEVELOPMENT_TEAM": env["TEAM_ID"],
            "ENABLE_HARDENED_RUNTIME": true,
            "MARKETING_VERSION": "1.0.0rc12",
            "PRODUCT_NAME": "MouseDef"
          ],
          configurations: [
            .debug(name: "Debug", xcconfig: "\(xcconfig("Debug"))"),
            .release(name: "Release", xcconfig: "\(xcconfig("Release"))")
          ],
          defaultSettings: .recommended)
    )
  ],
  schemes: [
    Scheme(
      name: "MouseDef",
      shared: true,
      hidden: false,
      buildAction: .buildAction(targets: ["MouseDef"]),
      testAction: .targets(
        ["UnitTests"],
        arguments: .init(environmentVariables: [
          "SOURCE_ROOT": .init(value: "$(SRCROOT)", isEnabled: true),
        ], launchArguments: [
          LaunchArgument(name: "-running-unit-tests", isEnabled: true)
        ]),
        options: TestActionOptions.options(
          coverage: true,
          codeCoverageTargets: [
            TargetReference(stringLiteral: "MouseDef")
          ]
        )
      ),
      runAction: .runAction(
        executable: "MouseDef",
        arguments:
            .init(environmentVariables: [
              "SOURCE_ROOT": .init(value: "$(SRCROOT)", isEnabled: true),
              "APP_ENVIRONMENT_OVERRIDE": .init(value: "development", isEnabled: true),
            ], launchArguments: [
              LaunchArgument(name: "-benchmark", isEnabled: false),
              LaunchArgument(name: "-debugEditing", isEnabled: false),
              LaunchArgument(name: "-injection", isEnabled: false),
              LaunchArgument(name: "-disableMachPorts", isEnabled: false),
            ])
      )
    )
  ],
  additionalFiles: [
    FileElement(stringLiteral: ".env"),
    FileElement(stringLiteral: ".gitignore"),
    FileElement(stringLiteral: "Project.swift"),
    FileElement(stringLiteral: "README.md"),
    FileElement(stringLiteral: "Tuist/Dependencies.swift"),
  ]
)

public enum PackageResolver {
  public static func packages(_ env: EnvHelper) -> [Package] {
    let packages: [Package]
    if env["PACKAGE_DEVELOPMENT"] == "true" {
      packages = [
        .package(path: "../AXEssibility"),
        .package(path: "../Bonzai"),
        .package(path: "../MachPort"),
        .package(path: "../Windows"),
        .package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.4.1"),
      ]
    } else {
      packages = [
        .package(url: "https://github.com/zenangst/AXEssibility.git", from: "0.0.14"),
        .package(url: "https://github.com/zenangst/Bonzai.git", .revision("f47ac9c060e880db9393880f198c334d33320702")),
        .package(url: "https://github.com/zenangst/MachPort.git", from: "3.0.3"),
        .package(url: "https://github.com/zenangst/Windows.git", from: "1.0.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.4.1"),
      ]
    }
    return packages
  }
}
