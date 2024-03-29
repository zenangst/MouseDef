import AXEssibility
import Combine
import Foundation
import Intercom
import SwiftUI
import Windows

final class AutoHideDockFeature: MoveFeature, ResizeFeature, @unchecked Sendable {
  private var subscriptions = [AnyCancellable]()
  @MainActor
  var cachedDockState: Dock = Dock.state
  var cachedRects = [Int: CGRect]()
  var isEnabled: Bool { AppSettings.shared.autoHideDockFeature }
  var shouldRun: Bool { false }
  var shouldRestore: Bool = false

  let intercom = Intercom(MouseDefIntercomApp.self)

  init() {
    NSWorkspace.shared.publisher(for: \.frontmostApplication)
      .debounce(for: 0.3, scheduler: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let self else { return }
        Task.detached {
          await MainActor.run {
            guard self.isEnabled else { return }
            self.run(nil, id: -1)
          }
        }
      }
      .store(in: &subscriptions)

    intercom.receive(.autoHideDockIfNeeded) { _ in
      Task { @MainActor in
        self.run(nil, id: -1)
      }
    }
    .store(in: &subscriptions)
  }

  func restore(_ element: AXEssibility.WindowAccessibilityElement, frame: inout CGRect) { }

  func run(_ element: AXEssibility.WindowAccessibilityElement) { 
    if let frame = element.frame {
      run(frame, id: Int(element.id))
    }
    cachedRects.removeAll()
  }

  func evaluate(_ screen: NSScreen, newFrame: CGRect, element: AXEssibility.WindowAccessibilityElement) {
    run(newFrame, id: Int(element.id))
  }

  @MainActor
  func run(_ newFrame: CGRect?, id: Int) {
    guard let activeScreen = NSScreen.screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) })
    else { return }

    if cachedRects.isEmpty {
      do {
        cachedRects = try WindowsInfo
          .getWindows([.optionOnScreenOnly, .excludeDesktopElements])
          .filter {
            $0.ownerName != "WindowManager" &&
            $0.rect.size.width > 160 &&
            $0.rect.size.height > 160
          }
          .reduce(into: [Int: CGRect]()) { (dict, windowModel) in
            dict[windowModel.id] = windowModel.rect
          }
      } catch { return }
    }

    if let newFrame {
      cachedRects[id] = newFrame
    }

    let rects = cachedRects.values
    let tileSize: Double = Dock.tileSize
    let predicate: (CGRect) -> Bool
    let margin: CGFloat = 12
    let maxX = activeScreen.frame.width - tileSize - 16
    let minX = tileSize + 12

    predicate = switch Dock.position {
      case .bottom: { $0.maxY <= activeScreen.visibleFrame.maxY - margin }
      case .left:   { $0.origin.x > minX }
      case .right:  { $0.maxX <= maxX }
    }

    let shouldShowDock = rects.allSatisfy(predicate)
    if shouldShowDock {
      guard cachedDockState != .shown || Dock.state == .hidden else { return }
      Dock.show()
      cachedDockState = .shown
    } else {
      guard cachedDockState == .shown else { return }
      Dock.hide()
      cachedDockState = .hidden
    }
  }
}
