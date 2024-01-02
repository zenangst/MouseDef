import Cocoa
import Combine
import MachPort

final class MachPortCoordinator {
  enum State: Equatable {
    case resize, move, ended, hotspots
  }

  private var flagsChangedSubscription: AnyCancellable?
  private var eventSubscription: AnyCancellable?

  deinit {
    end()
  }

  @MainActor
  func subscribe(to flagsChangedPublisher: Published<CGEventFlags?>.Publisher, 
                 to eventPublisher: Published<MachPortEvent?>.Publisher,
                 onFlagsChanged: @escaping (State, inout CGPoint) -> Void) {
    var initialMouseLocation: CGPoint = Mouse().location
    let moveModifiers: Set<ModifierKey> = AppSettings.shared.moveWindowModifiers
      .split(separator: "|")
      .map(String.init)
      .reduce(into: Set<ModifierKey>()) { result, rawValue in
        if let modifier = ModifierKey(rawValue: rawValue) {
          result.insert(modifier)
        }
      }

    let resizeModifiers: Set<ModifierKey> = AppSettings.shared.resizeWindowModifiers
      .split(separator: "|")
      .map(String.init)
      .reduce(into: Set<ModifierKey>()) { result, rawValue in
        if let modifier = ModifierKey(rawValue: rawValue) {
          result.insert(modifier)
        }
      }
    let hotspotsModifiers: Set<ModifierKey> = AppSettings.shared.hotspotsModifiers
      .split(separator: "|")
      .map(String.init)
      .reduce(into: Set<ModifierKey>()) { result, rawValue in
        if let modifier = ModifierKey(rawValue: rawValue) {
          result.insert(modifier)
        }
      }

    var moveModifiersIsActive: Bool = false
    var resizeModifiersIsActive: Bool = false
    var leftMouseIsDown: Bool = false
    var rightMouseIsDown: Bool = false

    let handler: (Set<ModifierKey>) -> Void = { flags in
      if !moveModifiers.isEmpty, flags == moveModifiers {
        moveModifiersIsActive = true
        resizeModifiersIsActive = false
      } else if !resizeModifiers.isEmpty, flags == resizeModifiers {
        moveModifiersIsActive = false
        resizeModifiersIsActive = true
      } else if !hotspotsModifiers.isEmpty, flags == hotspotsModifiers {
        moveModifiersIsActive = false
        resizeModifiersIsActive = false
      } else {
        initialMouseLocation = Mouse().location
        moveModifiersIsActive = false
        resizeModifiersIsActive = false
        leftMouseIsDown = false
        rightMouseIsDown = false
        onFlagsChanged(.ended, &initialMouseLocation)
      }
    }

    flagsChangedSubscription = flagsChangedPublisher
      .compactMap { $0 }
      .sink { flags in
        var modifiers: Set<ModifierKey> = []

        if flags.contains(.maskShift) { modifiers.insert(.shift) }
        if flags.contains(.maskControl) { modifiers.insert(.control) }
        if flags.contains(.maskAlternate) { modifiers.insert(.option) }
        if flags.contains(.maskCommand) { modifiers.insert(.command) }
        if flags.contains(.maskSecondaryFn) { modifiers.insert(.function) }

        handler(modifiers)
      }

    eventSubscription = eventPublisher
      .compactMap { $0 }
      .sink { machPortEvent in
        switch machPortEvent.type {
        case .leftMouseDown, .leftMouseUp:
          break
        case .leftMouseDragged:
          break
        case .rightMouseDown:
          break
        case .rightMouseUp:
          break
        case .mouseMoved:
          if moveModifiersIsActive {
            onFlagsChanged(.move, &initialMouseLocation)
          } else if resizeModifiersIsActive {
            onFlagsChanged(.resize, &initialMouseLocation)
          }
        default:
          break
        }
    }
  }

  func end() {
    flagsChangedSubscription?.cancel()
  }
}
