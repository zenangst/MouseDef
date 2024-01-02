import Bonzai
import SwiftUI

@MainActor
struct SettingsView: View {
  @ObservedObject var settings = AppSettings.shared

  var body: some View {
    VStack {
      Divider()
      VStack {
        HStack(spacing: 32) {
          SectionLabelView(title: "Move Window:")
          SettingsSectionModifierView(color: .systemPink, data: settings.$moveWindowModifiers)
        }

        HStack(spacing: 32) {
          SectionLabelView(title: "Resize Window:")
          SettingsSectionModifierView(color: .systemOrange, data: settings.$resizeWindowModifiers)
        }

//        HStack(spacing: 32) {
//          SectionLabelView(title: "Hotspot:")
//          SettingsSectionModifierView(color: .systemYellow, data: settings.$hotspotsModifiers)
//        }

        HStack(spacing: 32) {
          SectionLabelView(title: "Resize Mode:")
          Menu {
            Button(action: {}, label: {
              Text("Quadrant")
            })
            Button(action: {}, label: {
              Text("Regular")
            })
          } label: {
            HStack {
              Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
              Text("Quadrant")
                .font(.caption)
            }
          }
          .menuStyle(
            .zen(.init(color: .systemGreen,
                       grayscaleEffect: .constant(true),
                       padding: .init(horizontal: .medium, vertical: .small)))
          )
          .frame(minWidth: 200)
          .fixedSize()
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 42)
      .background(Color(nsColor: .windowBackgroundColor))
      .roundedContainer(padding: 0, margin: 0)
      .padding(16)
      .frame(minWidth: 420)
    }
  }
}

#Preview {
  SettingsView()
}
