import AXEssibility
import Bonzai
import SwiftUI

struct AppMenu: View {
  @Environment(\.openWindow) private var openWindow
  @StateObject var appUpdater = AppUpdater()
  @StateObject var loginItem = LoginItem()

  var body: some View {
    Button(action: {
      NSApp.setActivationPolicy(.regular)
      NSApp.activate(ignoringOtherApps: true)
      openWindow.withIdentifier(.settings)
    }, label: {
      Text("Open MouseDef")
    })

    Button(action: {
      AccessibilityPermission.shared.requestPermission()
    }, label: {
      Text("The Sindre button (\(AccessibilityPermission.shared.viewModel.rawValue))")
    })

    Button { appUpdater.checkForUpdates() } label: { Text("Check for updates…") }
    Toggle(isOn: $loginItem.isEnabled, label: { Text("Open at Login") })
      .toggleStyle(.checkbox)
  }
}

#Preview {
  AppMenu()
    .padding()
    .buttonStyle(.regular)
}
