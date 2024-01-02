import AXEssibility
import Cocoa
import Combine
import MachPort

@MainActor
final class AppContext {
  static let shared = AppContext()

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
    let resizeBehavior: MouseResizeBehavior = .quadrant
    let moveFeatures: [any MoveFeature] = [
      MoveToFullscreenFeature(publishers.windowBorderViewPublisher),
      MoveToSplitFeature(publishers.windowBorderViewPublisher),
    ]

    var windowCoordinator: WindowCoordinator<WindowOverlayContainerView>?
    var enhancedUserInterface: Bool?
    var elementWindow: WindowAccessibilityElement?
    var lastQuadrant: Quadrant?

    let coordinator = MachPortCoordinator(machPort) { state, initialMouseLocation in
      guard let screen = NSScreen.main else { return }

      if elementWindow == nil {
        let resolvedWindow = systemElement.element(at: initialMouseLocation,
                                                   as: AnyAccessibilityElement.self)?.window
        elementWindow = resolvedWindow
        windowCoordinator = WindowCoordinator(.none, content: WindowOverlayContainerView(publishers: publishers))
        windowCoordinator?.show()
      }

      switch state {
      case .ended:
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
      case .resize:
        guard let elementWindow, var elementRect = elementWindow.frame else { return }

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

        if elementWindow.frame != elementRect {
          elementWindow.frame = elementRect
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
}
