import SwiftUI

struct PermissionsWindow: Scene {
  var body: some Scene {
    WindowGroup(id: .permissions) {
      PermissionsView()
        .toolbar(content: {
          ToolbarItem {
            Text("MouseDef")
          }
        })
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(.contentSize)
    .windowToolbarStyle(.unified)
  }
}
