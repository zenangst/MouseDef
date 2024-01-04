import AXEssibility
import SwiftUI

@main
@MainActor struct MouseDef: App {
  @Environment(\.openWindow) private var openWindow
  @ObservedObject var settings = AppSettings.shared

  var body: some Scene {
    AppMenuExtras {
      guard !MouseDef.isRunningPreview else { return }

      switch AccessibilityPermission.shared.checkPermission() {
      case .authorized:
        AppContext.shared.start()
      case .notDetermined:
        AccessibilityPermission.shared.requestPermission()
        openWindow.withIdentifier(.permissions)
        fallthrough
      default:
        AccessibilityPermission.shared.subscribe(to: NSWorkspace.shared.publisher(for: \.frontmostApplication)) {
          AppContext.shared.start()
        }
      }
    }
    // Restart the application context when the settings change.
    .onChange(of: settings.mouseResizeBehavior) { _ in AppContext.shared.start() }
    .onChange(of: settings.hotspotsModifiers) { _ in AppContext.shared.start() }
    .onChange(of: settings.moveWindowModifiers) { _ in AppContext.shared.start() }
    .onChange(of: settings.resizeWindowModifiers) { _ in AppContext.shared.start() }
    SettingsWindow()
    PermissionsWindow()
  }
}
