import Bonzai
import SwiftUI

struct SettingsSectionModifierView: View {
  let color: ZenColor
  @Binding var data: String

  var body: some View {
    HStack(spacing: 16) {
      SettingsSectionModifierItemView(data: $data, color: color, modifier: .shift)
      SettingsSectionModifierItemView(data: $data, color: color, modifier: .function)
      SettingsSectionModifierItemView(data: $data, color: color, modifier: .option)
      SettingsSectionModifierItemView(data: $data, color: color, modifier: .command)
    }
  }
}

#Preview {
  SettingsSectionModifierView(color: .systemBrown, data: .constant("@$"))
    .padding()
}
