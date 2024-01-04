import SwiftUI

struct KeyBackgroundView: View {
  @Environment(\.colorScheme) var colorScheme
  @Binding var isPressed: Bool
  let height: CGFloat

  var body: some View {
    Rectangle()
      .fill(Color(.windowBackgroundColor))
      .clipShape(RoundedRectangle(cornerRadius: height * 0.1))
      .padding(0.1)
      .offset(y: isPressed ? 1 : 0)
      .scaleEffect(isPressed ? 0.95 : 1)
      .animation(.linear(duration: 0.1), value: isPressed)
      .background(
        Rectangle()
          .fill(Color.black.opacity( colorScheme == .light ? 0.33 : 0.9 ))
          .clipShape(RoundedRectangle(cornerRadius: height * 0.1))
          .offset(x: 0, y: height * 0.015)
          .blur(radius: 1.0)
          .scaleEffect(CGSize(width: 0.95, height: 1.0))
      )
      .background(
        Rectangle()
          .fill(Color.black.opacity( colorScheme == .light ? 0.3 : 0.4 ))
          .clipShape(RoundedRectangle(cornerRadius: height * 0.1))
          .offset(x: 0, y: 1)
          .blur(radius: 1)
          .scaleEffect(CGSize(width: 0.99, height: 1.0))
          .opacity(isPressed ? 0 : 1)
          .animation(.linear(duration: 0.1), value: isPressed)
      )
  }
}
