import AXEssibility
import Cocoa
import SwiftUI

final class SnapToFullscreenFeature: MoveFeature {
  private var sizeCache = [CGWindowID: CGRect]()
  var id: String { "moveToFullscreen" }
  var isEnabled: Bool { AppSettings.shared.snapToFullscreenFeature }
  var shouldRun: Bool = false
  var shouldRestore: Bool = false

  let publisher: WindowBorderViewPublisher
  let autohideDockFeature: AutoHideDockFeature

  init(_ publisher: WindowBorderViewPublisher, autohideDockFeature: AutoHideDockFeature) {
    self.publisher = publisher
    self.autohideDockFeature = autohideDockFeature
  }

  @MainActor
  func restore(_ element: WindowAccessibilityElement, frame: inout CGRect) {
    guard shouldRestore, let previousFrame = sizeCache[element.id] else { return }

    shouldRestore = false

    let deltaWidth = frame.size.width - previousFrame.width
    frame.origin.x += deltaWidth / 2
    element.size = previousFrame.size
    sizeCache[element.id] = nil
    publisher.publish([])
  }

  @MainActor
  func run(_ element: WindowAccessibilityElement) {
    guard shouldRun else { return }
    sizeCache[element.id] = element.frame

    Dock.hide()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      element.frame = NSScreen.main!.frame
    }

    shouldRun = false
    publisher.publish([])
  }

  @MainActor
  func evaluate(_ screen: NSScreen, newFrame: CGRect, element: WindowAccessibilityElement) {
    let screenRect = screen.frame
    let mouseLocation = Mouse().location
    let topField = screen.frame.maxY - screen.visibleFrame.maxY

    if newFrame.origin.y < topField || mouseLocation.y <= topField {
      var fullscreen = screenRect
      fullscreen.origin.y = topField
      fullscreen.size.height -= topField
      shouldRestore = true
      shouldRun = true

      withAnimation {
        publisher.publish([
          .init(id: element.id.description, frame: fullscreen)
        ])
      }
    } else if shouldRun {
      publisher.publish([])
      shouldRestore = false
      shouldRun = false
    }
  }
}
