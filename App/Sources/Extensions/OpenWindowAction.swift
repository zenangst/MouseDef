import SwiftUI

extension OpenWindowAction {
  func withIdentifier(_ identifier: MouseDef.WindowIdentifier) {
    self(id: identifier.rawValue)
  }
}
