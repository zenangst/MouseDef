import Cocoa

final class GlobalAndLocalMonitor {
  let local: Any?
  let global: Any?

  init(_ eventMask: NSEvent.EventTypeMask,
       local: @escaping (NSEvent) -> NSEvent?,
       global: @escaping (NSEvent) -> Void) {
    self.global = NSEvent.addGlobalMonitorForEvents(matching: eventMask, handler: global)
    self.local = NSEvent.addLocalMonitorForEvents(matching: eventMask, handler: local)
  }

  func end() {
    if let global = global {
      NSEvent.removeMonitor(global)
    }
    if let local = local {
      NSEvent.removeMonitor(local)
    }
  }

  deinit {
    end()
  }
}
