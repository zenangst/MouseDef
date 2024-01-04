import Bonzai
import SwiftUI

struct SettingsMoveWindowView: View {
  @ObservedObject var settings = AppSettings.shared
  let color: ZenColor = .systemPink
  private let rowPadding: CGFloat = 12

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 16) {
        SectionLabelView(
          title: "Mouse Button:",
          symbolName: "computermouse",
          color: color
        )
        SettingsMouseModifierView(color: color, data: settings.$moveWindowModifiers)
          .fixedSize()
      }
      .padding(rowPadding)
      Divider()
      HStack(spacing: 16) {
        SectionLabelView(
          title: "Move Modifiers:",
          symbolName: "keyboard",
          color: color
        )
        SettingsSectionModifierView(color: color, data: settings.$moveWindowModifiers)
      }
      .padding(rowPadding)
      Divider()
      HStack(alignment: .top, spacing: 16) {
        SectionLabelView(
          title: "Features",
          symbolName: "bubbles.and.sparkles.fill",
          color: color
        )
        VStack(alignment: .leading) {
          ZenCheckbox(
            "Auto Hide Dock",
            config: .init(color: color),
            isOn: AppSettings.shared.$autoHideDockFeature
          )
          ZenCheckbox(
            "Vertical Splits",
            config: .init(color: color),
            isOn: AppSettings.shared.$moveToSplitFeature
          )
          ZenCheckbox(
            "Snap to Fullscreen",
            config: .init(color: color),
            isOn: AppSettings.shared.$snapToFullscreenFeature
          )
        }
        .font(.callout)
      }
      .padding(rowPadding)
    }
    .roundedContainer(padding: 0)
  }
}

#Preview {
  SettingsMoveWindowView()
    .background()
}
