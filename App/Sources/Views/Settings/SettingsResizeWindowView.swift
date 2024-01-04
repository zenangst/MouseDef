import Bonzai
import SwiftUI

struct SettingsResizeWindowView: View {
  @ObservedObject var settings = AppSettings.shared
  let color: ZenColor = .systemYellow
  private let rowPadding: CGFloat = 12

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 16) {
        SectionLabelView(
          title: "Mouse Button:",
          symbolName: "computermouse",
          color: color
        )
        SettingsMouseModifierView(color: color, data: settings.$resizeWindowModifiers)
          .fixedSize()
      }
      .padding(rowPadding)
      Divider()
      HStack(spacing: 16) {
        SectionLabelView(
          title: "Resize Modifiers:",
          symbolName: "keyboard",
          color: color
        )
        SettingsSectionModifierView(color: color, data: settings.$resizeWindowModifiers)
      }
      .padding(rowPadding)
      Divider()
      HStack(spacing: 32) {
        SectionLabelView(
          title: "Resize Mode:",
          symbolName: "square.resize",
          color: color
        )
        Menu {
          Button(action: { AppSettings.shared.mouseResizeBehavior = .quadrant },
                 label: { Text("Quadrant") })
          Button(action: { AppSettings.shared.mouseResizeBehavior = .standard },
                 label: { Text("Standard") })
        } label: {
          HStack {
            Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
            Text(AppSettings.shared.mouseResizeBehavior.rawValue)
              .font(.caption)
          }
        }
        .menuStyle(
          .zen(.init(color: color,
                     grayscaleEffect: .constant(true),
                     padding: .init(horizontal: .medium, vertical: .small)))
        )
        .fixedSize()
      }
      .padding(rowPadding)
    }
    .roundedContainer(padding: 0)
  }
}

#Preview {
  SettingsResizeWindowView()
    .background()
}
