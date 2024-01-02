import SwiftUI

@MainActor
struct AppMenuExtras: Scene {
  private let pub = NotificationCenter.default
    .publisher(for: .didLaunch)
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.openWindow) private var openWindow

  private let onAppear: () -> Void

  init(onAppear: @escaping () -> Void) {
    self.onAppear = onAppear
  }

  var body: some Scene {
    MenuBarExtra(content: content, label: label)
  }

  func label() -> some View {
    Image(systemName: "cursorarrow.and.square.on.square.dashed")
      .onAppear(perform: onAppear)
  }

  @ViewBuilder
  func content() -> some View {
    Group {
      AppMenu()
      Divider()
      HelpMenu()
      Divider()
      Text("Version: \(MouseDef.marektingVersion) (\(MouseDef.buildNumber))")
#if DEBUG
      Button(action: { 
        NSWorkspace.shared.selectFile(Bundle.main.bundlePath, inFileViewerRootedAtPath: "")
      }, label: {
        Text("Reveal")
      })
#endif
      Button(action: {
        NSApplication.shared.terminate(nil)
      }, label: {
        Text("Quit")
      })
      .keyboardShortcut("q", modifiers: [.command])
    }
  }
}

#Preview {
  VStack(alignment: .leading) {
    AppMenuExtras(onAppear: {}).content()
      .fixedSize()
  }
  .buttonStyle(.regular)
  .padding()
}
