import Bonzai
import SwiftUI

struct SettingsSectionModifierItemView: View {
  @Binding private var data: String
  private let color: ZenColor
  private let modifier: ModifierKey
  private let separator = "|"

  init(_ data: Binding<String>, color: ZenColor, modifier: ModifierKey) {
    self._data = data
    self.color = color
    self.modifier = modifier
  }

  var body: some View {
    ModifierView(
      isOn: Binding<Bool>(get: {
        data.contains(modifier.rawValue)
      }, set: { newValue in
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
  SettingsSectionModifierItemView(
    .constant("@"),
    color: .systemGreen,
    modifier: .command
  )
    .padding()
}
