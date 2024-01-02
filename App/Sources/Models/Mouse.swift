import Cocoa

final class Mouse {
  let location: CGPoint

  init() {
    self.location = CGEvent(source: nil)?.location ?? .zero
  }
}
