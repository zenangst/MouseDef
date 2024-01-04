import Bonzai
import SwiftUI

struct SettingsMouseModifierView: View {
  let color: ZenColor
  @Binding var data: String

  var body: some View {
    Menu {
      Button(action: {
        data = data.replacingOccurrences(of: "ml", with: "")
        data = data.replacingOccurrences(of: "mr", with: "")
      }, label: { Text("None").font(.callout) })

      Button(action: {
        data = data.replacingOccurrences(of: "mr", with: "")
        data.append("ml")
      }, label: { Text("Left Mouse Button").font(.callout) })

      Button(action: {
        data = data.replacingOccurrences(of: "ml", with: "")
        data.append("mr")
      }, label: { Text("Right Mouse Button").font(.callout) })
    } label: {
      Group {
        if data.contains("ml") {
          Text("Left Mouse Button")
            .font(.callout)
        } else if data.contains("mr") {
          Text("Right Mouse Button")
            .font(.callout)
        } else {
          Text("None")
            .font(.callout)
        }
      }
    }
    .menuStyle(.zen(.init(color: color, font: .caption)))
  }
}

#Preview {
  Group {
    SettingsMouseModifierView(color: .accentColor, data: .constant(""))
    SettingsMouseModifierView(color: .accentColor, data: .constant("ml"))
    SettingsMouseModifierView(color: .accentColor, data: .constant("mr"))
  }
  .padding()
}
