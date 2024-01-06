import SwiftUI

struct SettingsWindow: Scene {
  @Environment(\.controlActiveState) var controlActiveState
  @State var tab: SettingsTab = .general

  var body: some Scene {
    WindowGroup(id: .settings) {
      SettingsView(tab: $tab)
        .onAppear {
          guard !MouseDef.isRunningPreview else { return }
          NSWindow.allowsAutomaticWindowTabbing = false
          NSApp.setActivationPolicy(.regular)
        }
        .onDisappear {
          guard !MouseDef.isRunningPreview else { return }
          NSApp.setActivationPolicy(.accessory)
        }
        .toolbar(content: {
          ToolbarItem(placement: .principal) {
            Picker(selection: $tab) {
              ForEach(SettingsTab.allCases) { tab in
                Button(action: { self.tab = tab }, label: { Text(tab.rawValue) })
                  .tag(tab)
              }
            } label: {
              Text(tab.rawValue)
            }
            .pickerStyle(.segmented)
          }

          ToolbarItem {
            Spacer()
          }

          ToolbarItem(id: UUID().uuidString) {
            VStack(alignment: .trailing, spacing: 0) {
              Group {
                Text("Version:") +
                Text(MouseDef.marektingVersion)
                  .bold()
              }
              .opacity(0.8)

              Group {
                Text("Build") +
                Text("(" + MouseDef.buildNumber + ")")
              }
              .opacity(0.4)

            }
            .font(.caption2)
            .grayscale(grayscale())
          }
        })
    }
    .windowResizability(.contentSize)
    .windowToolbarStyle(.unified)
  }

  private func grayscale() -> CGFloat {
    controlActiveState == .key ? 0 : 0.4
  }
}
