import Bonzai
import SwiftUI

struct SettingsSectionModifierItemView: View {
  @Binding var data: String
  let color: ZenColor
  let modifier: ModifierKey

  var body: some View {
    ModifierView(
      isOn: Binding<Bool>(get: {
        data.contains(modifier.rawValue)
      }, set: { newValue in
        let separator = "|"
        if newValue {
          data.append(modifier.rawValue + separator)
        } else {
          data = data.replacingOccurrences(of: modifier.rawValue, with: "")
        }
      }),
      color: color,
      modifier: modifier
    )
  }
}

#Preview {
  SettingsSectionModifierItemView(data: .constant("@"), color: .systemGreen, modifier: .command)
    .padding()
}
