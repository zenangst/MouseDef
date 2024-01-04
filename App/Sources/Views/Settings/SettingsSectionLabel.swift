import Bonzai
import SwiftUI

struct SectionLabelView: View {
  let title: String
  let symbolName: String
  let color: ZenColor

  var body: some View {
    HStack {
      Image(systemName: symbolName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 16, height: 16)
        .foregroundStyle(Color(nsColor: color.nsColor))
      Text(title)
        .bold()
        .frame(minWidth: 110, maxWidth: .infinity, alignment: .leading)
    }
  }
}

#Preview {
  SectionLabelView(title: "Resize Window:", symbolName: "arrow.up.and.down.and.arrow.left.and.right", color: .systemRed)
  .padding()
}
