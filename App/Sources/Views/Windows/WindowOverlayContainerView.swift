import SwiftUI

struct WindowPublishers {
  let windowBorderViewPublisher: WindowBorderViewPublisher
}

struct WindowOverlayContainerView: View {
  let publishers: WindowPublishers

  var body: some View {
    ZStack {
      WindowBordersView()
        .environmentObject(publishers.windowBorderViewPublisher)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
