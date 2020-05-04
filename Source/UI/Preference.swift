import SwiftUI

struct Preference: Hashable {
  var isEnabled: Bool
  let title: String
}

struct PreferenceView: View {
  @State var preference: Preference
  var body: some View {
    Toggle(isOn: $preference.isEnabled) {
      Text(preference.title)
    }
  }
}

struct Preference_Previews: PreviewProvider {
  static var previews: some View {
    PreferenceView(preference: Preference(isEnabled: true, title: "Quadrant resizing"))
  }
}
