import Cocoa

enum MouseResizeBehavior {
  case standard
  case quadrant
}

final class MouseController {
  private var monitor: Any?
  private var debugWindow: NSWindow?
  private var delta: CGPoint?
  private var windowFrameCache: CGRect?
  private let accessibilityController: AccessibilityController
  private let resizeBehavior: MouseResizeBehavior

  init(accessibilityController: AccessibilityController,
       resizeBehavior: MouseResizeBehavior) {
    self.accessibilityController = accessibilityController
    self.resizeBehavior = resizeBehavior
  }

  func handleState(_ state: MonitorController.State) {
    var monitor: Any?

    guard let mouse = Mouse() else {
      endSession()
      return
    }

    var location = mouse.location
    var keepSearching: Bool = true
    /// If no accessibility element can be resolved, keep searching upwards in the
    /// coordinate system until we eventually hit the toolbar of the window.
    /// This should work as a reliable fallback for custom elements that normally cannot
    /// be properly hooked into. An example is the `Maps.app` which normally cannot be
    /// managed using accessibility elements.
    while keepSearching {
      do {
        if let element = try? accessibilityController.element(at: location),
          let elementWindow = element.window {
          keepSearching = false
          switch state {
          case .ended:
            endSession()
            return
          case .drag:
            monitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { _ in
              guard let mouse = Mouse() else { self.endSession(); return }
              self.move(elementWindow, with: mouse)
              self.delta = mouse.location
            }
          case .resize:
            monitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { _ in
              guard let mouse = Mouse() else { self.endSession(); return }
              self.resize(elementWindow, with: mouse)
              self.delta = mouse.location
            }
          }
          self.monitor = monitor
        } else {
          location.y -= 1
        }
      }
    }
  }

  // MARK: Private methods

  private func endSession() {
    if let monitor = self.monitor {
      NSEvent.removeMonitor(monitor)
      self.monitor = nil
      self.delta = nil
      self.windowFrameCache = nil
    }
  }

  private func move(_ elementWindow: AccessibilityElement, with mouse: Mouse) {
    let point = mouse.location

    guard var windowPosition = elementWindow.position else { return }

    if let delta = self.delta {
      let newDelta = CGPoint(x: delta.x - point.x, y: delta.y - point.y)
      windowPosition.x -= newDelta.x
      windowPosition.y -= newDelta.y
      elementWindow.position = windowPosition
    }
  }

  private func resize(_ elementWindow: AccessibilityElement, with mouse: Mouse) {
    guard var windowSize = elementWindow.size,
      let delta = self.delta else { return }

    let point = mouse.location
    let newDelta = CGPoint(x: round(delta.x - point.x), y: round(delta.y - point.y))

    switch resizeBehavior {
    case .standard:
      windowSize.width -= newDelta.x
      windowSize.height -= newDelta.y
      elementWindow.size = windowSize
    case .quadrant:
      guard var windowFrame = windowFrameCache ?? elementWindow.frame else { return }
      switch windowFrame.quadrant(for: point) {
      case .first:
        windowFrame.origin.x -= newDelta.x
        windowFrame.size.width += newDelta.x
        windowFrame.origin.y -= newDelta.y
        windowFrame.size.height += newDelta.y
      case .second:
        windowFrame.size.width -= newDelta.x
        windowFrame.size.height += newDelta.y
        windowFrame.origin.y -= newDelta.y
      case .third:
        windowFrame.origin.x -= newDelta.x
        windowFrame.size.width += newDelta.x
        windowFrame.size.height -= newDelta.y
      case .fourth:
        windowFrame.size.width -= newDelta.x
        windowFrame.size.height -= newDelta.y
      }

      elementWindow.frame = windowFrame
      windowFrameCache = windowFrame
    }
  }
}

fileprivate enum Quadrant {
  case first
  case second
  case third
  case fourth
}

fileprivate extension CGRect {
  func quadrant(for point: CGPoint) -> Quadrant {
    var quadrant = 0
    if point.x > self.width / 2 {
      quadrant += 1
    }

    if point.y > self.height / 2 {
      quadrant += 2
    }

    if quadrant == 0 { return .first }
    if quadrant == 1 { return .second }
    if quadrant == 2 { return .third }

    return .fourth
  }
}
