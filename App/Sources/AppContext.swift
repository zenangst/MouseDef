import AXEssibility
import Cocoa
import Combine
import MachPort

@MainActor
final class AppContext {
  static let shared = AppContext()

  private var searching: Bool = false
  private var coordinator: MachPortCoordinator?
  private var machPort: MachPortEventController?

  init() {
    do {
      try createMachPort()
    } catch {
      print(error)
    }
  }

  func start() {
    guard let machPort else { return }
    coordinator = nil

    let systemElement = SystemAccessibilityElement()
    let publishers = WindowPublishers(windowBorderViewPublisher: .init())
    let resizeBehavior: MouseResizeBehavior = AppSettings.shared.mouseResizeBehavior

    lazy var autoHideDockFeature = AutoHideDockFeature()

    let moveFeatures: [any MoveFeature] = [
      SnapToFullscreenFeature(publishers.windowBorderViewPublisher, autohideDockFeature: autoHideDockFeature),
      MoveToSplitFeature(publishers.windowBorderViewPublisher, autohideDockFeature: autoHideDockFeature),
      autoHideDockFeature
    ]

    let resizeFeatures: [any ResizeFeature] = [
      autoHideDockFeature
    ]

    var windowCoordinator: WindowCoordinator<WindowOverlayContainerView>?
    var enhancedUserInterface: Bool?
    var elementWindow: WindowAccessibilityElement?
    var lastQuadrant: Quadrant?
    var ephemeralFrame: CGRect?

    let coordinator = MachPortCoordinator(machPort) { [weak self] state, initialMouseLocation in
      guard let self, let screen = NSScreen.main else { return }

      if elementWindow == nil {
        searching = true
        let resolvedWindow = findElement(at: initialMouseLocation, systemElement: systemElement)
        searching = false
        elementWindow = resolvedWindow
        windowCoordinator?.close()
        windowCoordinator = WindowCoordinator(.none, content: WindowOverlayContainerView(publishers: publishers))
      } else {
        windowCoordinator?.show()
      }

      switch state {
      case .ended:
        searching = false
        if let elementWindow {
          if let enhancedUserInterface {
            elementWindow.app?.enhancedUserInterface = enhancedUserInterface
          }

          moveFeatures.filter(\.isEnabled)
            .forEach { feature in
              feature.run(elementWindow)
            }
        }

        enhancedUserInterface = nil
        elementWindow = nil
        lastQuadrant = nil
        windowCoordinator?.close()
        windowCoordinator = nil
        ephemeralFrame = nil
      case .resize:
        guard let elementWindow else { return }

        var elementRect: CGRect
        let previousRect: CGRect
        if let ephemeralFrame {
          elementRect = ephemeralFrame
          previousRect = ephemeralFrame
        } else {
          guard let resolvedRect = elementWindow.frame else {
            return
          }
          elementRect = resolvedRect
          ephemeralFrame = elementRect
          previousRect = elementRect
        }

        if enhancedUserInterface == nil, let app = elementWindow.app  {
          enhancedUserInterface = app.enhancedUserInterface
          app.enhancedUserInterface = false
        }

        let mouse = Mouse()
        ResizeCoordinator.resize(to: &elementRect,
                                 with: mouse.location,
                                 behavior: resizeBehavior,
                                 lastQuadrant: &lastQuadrant,
                                 delta: &initialMouseLocation
        )


        if previousRect != elementRect {
          resizeFeatures.filter(\.isEnabled)
            .forEach { $0.restore(elementWindow, frame: &elementRect) }

          elementWindow.size = elementRect.size
          if previousRect.origin != elementRect.origin {
            elementWindow.position = elementRect.origin
          }
          ephemeralFrame = elementRect

          resizeFeatures.filter(\.isEnabled)
            .forEach { $0.evaluate(screen, newFrame: elementRect, element: elementWindow) }
        }
        initialMouseLocation = mouse.location
      case .move:
        guard let elementWindow, let elementRect = elementWindow.frame else { return }

        if enhancedUserInterface == nil, let app = elementWindow.app  {
          enhancedUserInterface = app.enhancedUserInterface
          app.enhancedUserInterface = false
        }

        let mouse = Mouse()
        var newFrame = elementRect
        MoveCoordinator.move(to: &newFrame.origin, with: mouse.location, delta: &initialMouseLocation)

        moveFeatures.filter(\.isEnabled)
          .forEach { feature in
            feature.restore(elementWindow, frame: &newFrame)
            feature.evaluate(screen, newFrame: newFrame, element: elementWindow)
          }

        if elementRect.origin != newFrame.origin {
          elementWindow.position = newFrame.origin
        }
      case .hotspots:
        elementWindow = nil
      }
    }

    self.coordinator = coordinator
  }

  @discardableResult
  private func createMachPort() throws -> MachPortEventController {
    let leftMouseEvents: CGEventMask = (1 << CGEventType.leftMouseDown.rawValue)
    | (1 << CGEventType.leftMouseUp.rawValue)
    | (1 << CGEventType.leftMouseDragged.rawValue)

    let rightMouseEvents: CGEventMask = (1 << CGEventType.rightMouseDown.rawValue)
    | (1 << CGEventType.rightMouseUp.rawValue)
    | (1 << CGEventType.rightMouseDragged.rawValue)

    let otherMouseEvents: CGEventMask = (1 << CGEventType.flagsChanged.rawValue)
    | (1 << CGEventType.mouseMoved.rawValue)

    let eventsOfInterest: CGEventMask = leftMouseEvents | rightMouseEvents | otherMouseEvents
    let machPort = try MachPortEventController(
      .privateState,
      eventsOfInterest: eventsOfInterest,
      signature: MouseDef.bundleIdentifier,
      autoStartMode: .commonModes
    )
    self.machPort = machPort

    return machPort
  }

  private func findElement(at location: CGPoint, systemElement: SystemAccessibilityElement) -> WindowAccessibilityElement? {
    var location = location

    if let element = systemElement.element(at: location,
                                           as: AnyAccessibilityElement.self)?.window {
      if element.window != nil {
        return element
      }
    }

    if location.y > 0 && searching {
      location.y -= 32
      return findElement(at: location, systemElement: systemElement)
    } else {
      return nil
    }
  }
}
