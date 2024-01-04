import Bonzai
import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
  var id: String { rawValue }
  case general = "General"
  case move = "Move"
  case resize = "Resize"
}

@MainActor
struct SettingsView: View {
  @ObservedObject var settings = AppSettings.shared
  @Binding var tab: SettingsTab

  var body: some View {
    Group {
      switch tab {
      case .general: PermissionsView()
      case .move:    SettingsMoveWindowView()
      case .resize:  SettingsResizeWindowView()
      }
    }
    .padding()
    .background()
    .frame(minWidth: 600, alignment: .topLeading)
  }
}

#Preview("General") {
  SettingsView(tab: .constant(.general))
}
#Preview("Move") {
  SettingsView(tab: .constant(.move))
}
#Preview("Resize") {
  SettingsView(tab: .constant(.resize))
}
