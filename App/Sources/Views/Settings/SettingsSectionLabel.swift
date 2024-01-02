import SwiftUI

struct SectionLabelView: View {
  let title: String

  var body: some View {
    Text(title)
      .bold()
      .frame(minWidth: 110, alignment: .trailing)
  }
}

#Preview {
  SectionLabelView(title: "Resize Window:")
  .padding()
}
