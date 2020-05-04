import SwiftUI

struct Shortcut: Hashable {
  let title: String
  let preferences: [Preference]
}

struct ShortcutView: View {
  let shortcut: Shortcut
  var body: some View {
    HStack {
      Text(shortcut.title).frame(minWidth: 120)
      HStack {
        ForEach(shortcut.preferences, id: \.self) {
          PreferenceView(preference: $0).fixedSize().padding(8)
        }
      }
    }
  }
}

struct Shortcut_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ShortcutView(shortcut: Shortcut(
        title: "Move shortcut:",
        preferences: [
          Preference(isEnabled: true, title: "fn"),
          Preference(isEnabled: false, title: "⇧"),
          Preference(isEnabled: false, title: "⌃"),
          Preference(isEnabled: false, title: "⌥"),
          Preference(isEnabled: true, title: "⌘")
      ]))

      ShortcutView(shortcut: Shortcut(
        title: "Resize shortcut:",
        preferences: [
          Preference(isEnabled: false, title: "fn"),
          Preference(isEnabled: true, title: "⇧"),
          Preference(isEnabled: false, title: "⌃"),
          Preference(isEnabled: false, title: "⌥"),
          Preference(isEnabled: true, title: "⌘")
      ]))

      ShortcutView(shortcut: Shortcut(title: "Quadrant resizing:",
                                      preferences: [Preference(isEnabled: true, title: "")]))
    }
  }
}
