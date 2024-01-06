import Bonzai
import SwiftUI

struct SettingsSectionModifierView: View {
  let color: ZenColor
  @Binding var data: String

  var body: some View {
    HStack(spacing: 16) {
      SettingsSectionModifierItemView($data, color: color, modifier: .shift)
      SettingsSectionModifierItemView($data, color: color, modifier: .function)
      SettingsSectionModifierItemView($data, color: color, modifier: .option)
      SettingsSectionModifierItemView($data, color: color, modifier: .command)
    }
    .padding(8)
    .background()
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .overlay {
      RoundedRectangle(cornerRadius: 8)
        .stroke(Color(nsColor: color.nsColor), lineWidth: 1.0)
        .opacity(0.1)
    }
  }
}

#Preview {
  SettingsSectionModifierView(color: .systemBrown, data: .constant("@$"))
    .padding()
}
