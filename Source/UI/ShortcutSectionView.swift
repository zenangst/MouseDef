import SwiftUI

struct ShortcutSection: Hashable {
  let title: String
  var shortcuts: [Shortcut]
}

struct ShortcutSectionView: View {
  @State var sections: [ShortcutSection]

  var body: some View {
    ForEach(sections, id: \.self) { section in
      VStack(alignment: .center) {
        Text(section.title).font(.subheadline).multilineTextAlignment(.leading).frame(minWidth: 400)
        ForEach(section.shortcuts, id: \.self) { shortcut in
          ShortcutView(shortcut: shortcut)
        }
      }.padding(8)
    }
  }
}

struct ShortcutSectionView_Previews: PreviewProvider {
  static var previews: some View {
    let sections = [
      ShortcutSection(title: "Shortcuts", shortcuts: [
        Shortcut(
          title: "Move shortcut:",
          preferences: [
            Preference(isEnabled: true, title: "fn"),
            Preference(isEnabled: false, title: "⇧"),
            Preference(isEnabled: false, title: "⌃"),
            Preference(isEnabled: false, title: "⌥"),
            Preference(isEnabled: true, title: "⌘")
        ]),
        Shortcut(
          title: "Resize shortcut:",
          preferences: [
            Preference(isEnabled: false, title: "fn"),
            Preference(isEnabled: true, title: "⇧"),
            Preference(isEnabled: false, title: "⌃"),
            Preference(isEnabled: false, title: "⌥"),
            Preference(isEnabled: true, title: "⌘")
        ])
      ]),
      ShortcutSection(title: "General", shortcuts: [
        Shortcut(
          title: "Start at login:",
          preferences: [
            Preference(isEnabled: true, title: ""),
        ]),
        Shortcut(
          title: "Quadrant resizing:",
          preferences: [
            Preference(isEnabled: true, title: ""),
        ])
      ])
    ]

    return ShortcutSectionView(sections: sections)
  }
}
