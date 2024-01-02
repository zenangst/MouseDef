import SwiftUI

struct SettingsWindow: Scene {
  @Environment(\.controlActiveState) var controlActiveState

  var body: some Scene {
    WindowGroup(id: .settings) {
      SettingsView()
        .onAppear {
          guard !MouseDef.isRunningPreview else { return }
          NSApp.setActivationPolicy(.regular)
        }
        .onDisappear {
          guard !MouseDef.isRunningPreview else { return }
          NSApp.setActivationPolicy(.accessory)
        }
        .toolbar(content: {
          ToolbarItem(id: UUID().uuidString) {
            Text("MouseDef")
              .grayscale(grayscale())
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
    .windowStyle(.hiddenTitleBar)
    .windowResizability(.contentSize)
    .windowToolbarStyle(.unified)
  }

  private func grayscale() -> CGFloat {
    controlActiveState == .key ? 0 : 0.4
  }
}
