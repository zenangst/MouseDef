import Cocoa

final class MonitorController {
  enum State {
    case resize, drag, ended
  }

  private var monitor: Any?

  func start(_ handler: @escaping (State) -> Void) {
    monitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
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
    guard let monitor = monitor else { return }
    NSEvent.removeMonitor(monitor)
  }
}
