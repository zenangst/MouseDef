import Cocoa

extension NSEvent {
  var emptyFlags: Bool {
    cgEvent?.flags == .maskNonCoalesced
  }
}
