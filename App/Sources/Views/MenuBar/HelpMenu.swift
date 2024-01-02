import SwiftUI

struct HelpMenu: View {
  var body: some View {
    Button(action: {
      NSWorkspace.shared.open(URL(string: "https://github.com/zenangst/MouseDef/discussions")!)
    }, label: {
      Text("Discussions")
    })

    Button(action: {
      NSWorkspace.shared.open(URL(string: "https://github.com/zenangst/MouseDef/issues/new")!)
    }, label: {
      Text("File a Bug")
    })
  }
}

#Preview {
  VStack(alignment: .leading) {
    HelpMenu()
  }
  .buttonStyle(.regular)
  .padding()
}
