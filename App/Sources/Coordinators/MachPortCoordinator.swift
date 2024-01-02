import Cocoa
import Combine
import MachPort

final class MachPortCoordinator {
  enum State: Equatable {
    case resize, move, ended, hotspots
  }

  private var flagsChangedSubscription: AnyCancellable?
  private var eventSubscription: AnyCancellable?

  @MainActor
  init(_ machPort: MachPortEventController, onEvent: @escaping (State, inout CGPoint) -> Void) {
    var initialMouseLocation: CGPoint = Mouse().location
    let moveModifiers: Set<ModifierKey> = AppSettings.shared.moveWindowModifiers
      .split(separator: "|")
      .map(String.init)
      .reduce(into: Set<ModifierKey>()) { result, rawValue in
        if let modifier = ModifierKey(rawValue: rawValue) {
          result.insert(modifier)
        }
      }
    let mouseModifiers: Set<ModifierKey> = [.leftMouseButton, .rightMouseButton]
    let moveModifiersWithoutMouse = moveModifiers.filter({ !mouseModifiers.contains($0) })
    let resizeModifiers: Set<ModifierKey> = AppSettings.shared.resizeWindowModifiers
      .split(separator: "|")
      .map(String.init)
      .reduce(into: Set<ModifierKey>()) { result, rawValue in
        if let modifier = ModifierKey(rawValue: rawValue) {
          result.insert(modifier)
        }
      }
    let resizeModifiersWithoutMouse = resizeModifiers.filter({ !mouseModifiers.contains($0) })

    var modifiers: Set<ModifierKey> = []
    flagsChangedSubscription = machPort.$flagsChanged
      .compactMap { $0 }
      .sink { flags in
        modifiers.removeAll()

        if flags.contains(.maskShift) { modifiers.insert(.shift) }
        if flags.contains(.maskControl) { modifiers.insert(.control) }
        if flags.contains(.maskAlternate) { modifiers.insert(.option) }
        if flags.contains(.maskCommand) { modifiers.insert(.command) }
        if flags.contains(.maskSecondaryFn) { modifiers.insert(.function) }

        if modifiers.isEmpty {
          onEvent(.ended, &initialMouseLocation)
        }
        initialMouseLocation = Mouse().location
      }

    eventSubscription = machPort.$event
      .compactMap { $0 }
      .sink { machPortEvent in
        switch machPortEvent.type {
        case .leftMouseUp:
          if moveModifiers.contains(.leftMouseButton) || resizeModifiers.contains(.leftMouseButton) {
            let moveIsActive = moveModifiersWithoutMouse == modifiers && moveModifiers.contains(.leftMouseButton)
            let resizeIsActive = resizeModifiersWithoutMouse == modifiers && resizeModifiers.contains(.leftMouseButton)

            if moveIsActive || resizeIsActive {
              machPortEvent.result = nil
              onEvent(.ended, &initialMouseLocation)
            }
          }
        case .rightMouseUp:
          if moveModifiers.contains(.rightMouseButton) || resizeModifiers.contains(.rightMouseButton) {
            let moveIsActive = moveModifiersWithoutMouse == modifiers && moveModifiers.contains(.rightMouseButton)
            let resizeIsActive = resizeModifiersWithoutMouse == modifiers && resizeModifiers.contains(.rightMouseButton)

            if moveIsActive || resizeIsActive {
              machPortEvent.result = nil
              onEvent(.ended, &initialMouseLocation)
            }
          }
        case .leftMouseDown, .leftMouseDragged:
          if moveModifiers.contains(.leftMouseButton) || resizeModifiers.contains(.leftMouseButton) {
            var mouseLocation = Mouse().location
            let deltaX = machPortEvent.event.getDoubleValueField(.mouseEventDeltaX)
            let deltaY = machPortEvent.event.getDoubleValueField(.mouseEventDeltaY)
            mouseLocation.x -= deltaX
            mouseLocation.y -= deltaY

            let moveIsActive = moveModifiersWithoutMouse == modifiers && moveModifiers.contains(.leftMouseButton)
            let resizeIsActive = resizeModifiersWithoutMouse == modifiers && resizeModifiers.contains(.leftMouseButton)

            if moveIsActive {
              machPortEvent.result = nil
              onEvent(.move, &mouseLocation)
            } else if resizeIsActive {
              machPortEvent.result = nil
              onEvent(.resize, &mouseLocation)
            }
          }
        case .rightMouseDown, .rightMouseDragged:
          if moveModifiers.contains(.rightMouseButton) || resizeModifiers.contains(.rightMouseButton) {
            var mouseLocation = Mouse().location
            let deltaX = machPortEvent.event.getDoubleValueField(.mouseEventDeltaX)
            let deltaY = machPortEvent.event.getDoubleValueField(.mouseEventDeltaY)
            mouseLocation.x -= deltaX
            mouseLocation.y -= deltaY

            let moveIsActive = moveModifiersWithoutMouse == modifiers && moveModifiers.contains(.rightMouseButton)
            let resizeIsActive = resizeModifiersWithoutMouse == modifiers && resizeModifiers.contains(.rightMouseButton)

            if moveIsActive {
              machPortEvent.result = nil
              onEvent(.move, &mouseLocation)
            } else if resizeIsActive {
              machPortEvent.result = nil
              onEvent(.resize, &mouseLocation)
            }
          }
        case .mouseMoved:
          if (moveModifiers == moveModifiersWithoutMouse && moveModifiersWithoutMouse == modifiers) {
            onEvent(.move, &initialMouseLocation)
          } else if (resizeModifiers == resizeModifiersWithoutMouse && resizeModifiersWithoutMouse == modifiers) {
            onEvent(.resize, &initialMouseLocation)
          }
        default:
          break
        }
      }

  }

  deinit {
    flagsChangedSubscription?.cancel()
    eventSubscription?.cancel()
  }
}
