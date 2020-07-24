import Cocoa

final class MonitorController {
  enum State {
    case resize, drag, ended
  }

  private var flagMonitor: Any?

  func start(_ handler: @escaping (State) -> Void) {
    flagMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyUp, .keyDown]) {
      event in

      if event.type != .flagsChanged {
        handler(.ended)
        return
      }

      let dragModifiers: NSEvent.ModifierFlags = [.function, .command]
      let resizeModifiers: NSEvent.ModifierFlags = [.shift, .command]

      if event.modifierFlags.contains(.capsLock) || event.modifierFlags.contains(.option) ||
        event.modifierFlags.contains(.control) {
        handler(.ended)
        return
      }

      // Avoid doing both resizing and moving at the same time.
      // Reference: https://github.com/zenangst/MouseDef/issues/3
      if event.modifierFlags.contains(dragModifiers) && event.modifierFlags.contains(resizeModifiers) {
        handler(.ended)
        return
      }

      if event.modifierFlags.contains(dragModifiers) {
        handler(.drag)
        return
      }

      if event.modifierFlags.contains(resizeModifiers) {
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
