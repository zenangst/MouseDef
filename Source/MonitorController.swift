import Cocoa

final class MonitorController {
  enum State {
    case resize, drag, ended
  }

  private var flagMonitor: Any?

  func start(_ handler: @escaping (State) -> Void) {
    flagMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
      if event.modifierFlags.contains(.capsLock) || event.modifierFlags.contains(.option) ||
        event.modifierFlags.contains(.control) {
        handler(.ended)
        return
      }

      if event.modifierFlags.contains([.function, .command]) {
        handler(.drag)
        return
      }

      if event.modifierFlags.contains([.shift, .command]) {
        handler(.resize)
        return
      }

      handler(.ended)
    }
  }

  func end() {
    if let flagMonitor = flagMonitor {
      NSEvent.removeMonitor(flagMonitor)
    }
  }
}
