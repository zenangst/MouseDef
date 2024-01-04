import Foundation
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
  @AppStorage("autoHideDockFeature", store: MouseDef.userDefaults) var autoHideDockFeature = false
  @AppStorage("moveToSplitFeature", store: MouseDef.userDefaults) var moveToSplitFeature = false
  @AppStorage("snapToFullscreenFeature", store: MouseDef.userDefaults) var snapToFullscreenFeature = false
  @AppStorage("mouseResizeBehavior", store: MouseDef.userDefaults) var mouseResizeBehavior: MouseResizeBehavior = MouseResizeBehavior.quadrant

  @AppStorage("moveWindowModifiers", store: MouseDef.userDefaults) var moveWindowModifiers = [
    ModifierKey.function, ModifierKey.command
  ].map(\.rawValue).joined(separator: "|")

  @AppStorage("resizeWindowModifiers", store: MouseDef.userDefaults) var resizeWindowModifiers = [
    ModifierKey.shift, ModifierKey.command
  ].map(\.rawValue).joined(separator: "|")

  @AppStorage("hotspotsModifiers", store: MouseDef.userDefaults) var hotspotsModifiers = [
    ModifierKey.function, ModifierKey.option
  ].map(\.rawValue).joined(separator: "|")

  static let shared: AppSettings = .init()

  private init() {}
}
