import Bonzai
import SwiftUI

struct ModifierKeyView: View {
  @Environment(\.colorScheme) var colorScheme
  let key: ModifierKey
  let alignment: Alignment
  let color: ZenColor
  @Binding var glow: Bool
  private let animation = Animation
    .easeInOut(duration: 1.25)
    .repeatForever(autoreverses: true)


  init(key: ModifierKey,
       alignment: Alignment? = nil,
       color: ZenColor = .accentColor,
       glow: Binding<Bool> = .constant(false)) {
    self.key = key
    self.color = color
    _glow = glow

    if let alignment = alignment {
      self.alignment = alignment
    } else {
      self.alignment = key == .shift
      ? .bottomLeading : .topTrailing
    }
  }

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        KeyBackgroundView(isPressed: .constant(false), height: proxy.size.height)
          .background(
            RoundedRectangle(cornerRadius: proxy.size.height * 0.1)
              .stroke(glow
                      ? Color(nsColor: color.nsColor).opacity(0.5)
                      : Color.clear, lineWidth: 2)
              .padding(-1)
          )

        Group {
          Text(key.keyValue)
            .font(Font.system(size: proxy.size.height * 0.23,
                              weight: .medium, design: .rounded))
        }
        .padding(6)
        .frame(width: proxy.size.width,
               height: proxy.size.height,
               alignment: alignment)

        if key == .function {
          Group {
            Image(systemName: "globe")
              .resizable()
              .frame(width: proxy.size.height * 0.2,
                     height: proxy.size.height * 0.2,
                     alignment: .bottomLeading)
              .offset(x: proxy.size.width * 0.1,
                      y: -proxy.size.width * 0.1)
          }
          .frame(width: proxy.size.width,
                 height: proxy.size.height,
                 alignment: .bottomLeading)
        }

        Text(key.writtenValue)
          .font(Font.system(size: proxy.size.height * 0.23, weight: .regular, design: .rounded))
          .frame(height: proxy.size.height, alignment: .bottom)
          .offset(y: -proxy.size.width * 0.065)
      }
      .foregroundColor(
        Color(.textColor)
          .opacity(0.66)
      )
    }
  }
}

struct ModifierKeyIcon_Previews: PreviewProvider {
  static let size: CGFloat = 64

  static var previews: some View {
    return HStack {
      ForEach(ModifierKey.allCases) { modifier in
        ModifierKeyView(key: modifier)
          .frame(width: {
            switch modifier {
            case .command, .shift:
              return size * 1.5
            default:
              return size
            }
          }(),
                 height: size)
      }
    }.padding(5)
  }
}
