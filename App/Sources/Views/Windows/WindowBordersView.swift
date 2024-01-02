import Bonzai
import SwiftUI

final class WindowBorderViewPublisher: ObservableObject {
  @Published var data: [WindowBorderViewModel] = []

  @MainActor
  func publish(_ data: [WindowBorderViewModel]) {
    self.data = data
  }
}

struct WindowBorderViewModel: Identifiable, Equatable {
  let id: String
  let frame: CGRect
}

struct WindowBordersView: View {
  @EnvironmentObject var publisher: WindowBorderViewPublisher
  @State var animateGradient: Bool = false
  private let lineWidth: CGFloat = 4

  var body: some View {
    ForEach(publisher.data) { model in
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.accentColor, lineWidth: lineWidth)
        .frame(width: model.frame.width - lineWidth / 2,
               height: model.frame.height - lineWidth / 2)
        .position(x: model.frame.midX,
                  y: model.frame.midY)
    }
    .onReceive(publisher.$data, perform: { newValue in
      withAnimation(.linear(duration: 1).repeatForever()) {
        animateGradient = !newValue.isEmpty
      }
    })
  }
}
