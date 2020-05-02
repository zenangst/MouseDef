import Foundation

final class Mouse {
  let location: CGPoint

  init?() {
    guard let location = CGEvent(source: nil)?.location else {
      return nil
    }
    self.location = location
  }
}
