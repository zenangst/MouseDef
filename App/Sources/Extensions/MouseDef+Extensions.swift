import Foundation

extension MouseDef {
  enum WindowIdentifier: String {
    case settings
    case permissions
  }

  static var bundleIdentifier: String { Bundle.main.bundleIdentifier! }

  static var marektingVersion: String {
    Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
  }

  static var buildNumber: String {
    Bundle.main.infoDictionary!["CFBundleVersion"] as! String
  }

  static var isRunningPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil

  static var userDefaults: UserDefaults {
    isRunningPreview 
    ? UserDefaults(suiteName: bundleIdentifier + ".previews")!
    : UserDefaults.standard
  }
}
