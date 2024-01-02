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
      Menu {
        Button(action: {
          data = data.replacingOccurrences(of: "ml", with: "")
          data = data.replacingOccurrences(of: "mr", with: "")
        }, label: { Text("None") })

        Button(action: {
          data = data.replacingOccurrences(of: "mr", with: "")
          data.append("ml")
        }, label: { Text("Left Mouse Button") })

        Button(action: {
          data = data.replacingOccurrences(of: "ml", with: "")
          data.append("mr")
        }, label: { Text("Right Mouse Button") })

      } label: {
        if data.contains("ml") {
          Text("Left Mouse Button")
        } else if data.contains("mr") {
          Text("Right Mouse Button")
        } else {
          Text("None")
        }
      }
      .menuStyle(.regular)

    }
  }
}

#Preview {
  SettingsSectionModifierView(color: .systemBrown, data: .constant("@$"))
    .padding()
}
