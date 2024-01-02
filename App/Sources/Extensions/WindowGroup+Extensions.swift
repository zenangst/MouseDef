import SwiftUI

extension WindowGroup {
  init(id: MouseDef.WindowIdentifier, @ViewBuilder content: () -> Content) where Content : View {
    self.init(id: id.rawValue, content: content)
  }
}
