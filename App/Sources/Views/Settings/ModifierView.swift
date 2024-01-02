import Bonzai
import SwiftUI

struct ModifierView: View {
  @Binding var isOn: Bool
  let color: ZenColor
  let modifier: ModifierKey

  var body: some View {
    VStack {
      ModifierKeyView(key: modifier, color: color, glow: $isOn)
        .onTapGesture {
          isOn.toggle()
        }
    }
    .frame(
      width: modifier == .command || modifier == .shift ? 44 : 32,
      height: 32
    )
  }
}

#Preview {
  ModifierView(isOn: .constant(true), color: .accentColor, modifier: .command)
    .padding()
}
