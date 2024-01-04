import AXEssibility
import SwiftUI

final class MoveToSplitFeature: MoveFeature {
  private var sizeCache = [CGWindowID: CGRect]()
  var id: String { "moveToSplit" }
  var isEnabled: Bool { AppSettings.shared.moveToSplitFeature }
  var shouldRun: Bool = false
  var shouldRestore: Bool = false

  var newFrame: CGRect?
  let publisher: WindowBorderViewPublisher
  let autohideDockFeature: AutoHideDockFeature

  init(_ publisher: WindowBorderViewPublisher, autohideDockFeature: AutoHideDockFeature) {
    self.publisher = publisher
    self.autohideDockFeature = autohideDockFeature
  }

  func restore(_ element: AXEssibility.WindowAccessibilityElement, frame: inout CGRect) {
    guard shouldRestore, let previousFrame = sizeCache[element.id] else { return }
    shouldRestore = false
    let deltaWidth = frame.size.width - previousFrame.width
    frame.origin.x += deltaWidth / 2
    element.size = previousFrame.size
    sizeCache[element.id] = nil
    publisher.publish([])
  }
  
  func run(_ element: AXEssibility.WindowAccessibilityElement) {
    guard let newFrame = newFrame, shouldRun else { return }
    sizeCache[element.id] = element.frame

    Dock.hide()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      element.frame = newFrame

      if let adjustedFrame = element.frame, let screen = NSScreen.main {
        if adjustedFrame.maxX > screen.frame.maxX {
          element.frame?.origin.x = screen.frame.maxX - element.frame!.width
        }
      }
    }

    shouldRun = false
    publisher.publish([])
    self.newFrame = nil
  }
  
  func evaluate(_ screen: NSScreen, newFrame: CGRect, element: AXEssibility.WindowAccessibilityElement) {
    let screenRect = screen.frame
    let leftField = screen.frame.maxX - screen.visibleFrame.maxX
    let isLeftSide = newFrame.origin.x + 50 <= leftField
    let isRightSide = newFrame.maxX >= screen.frame.maxX + 50

    let (leftXOffset, rightXOffset): (CGFloat, CGFloat) = switch (Dock.state, Dock.position) {
    case (.shown, .left):  (abs(screen.visibleFrame.width - screen.frame.width), 0)
    case (.shown, .right): (0, abs(screen.visibleFrame.width - screen.frame.width))
    default: (0,0)
    }

    if !shouldRun, isLeftSide {
      // Mouse is in the left field
      let frame = CGRect(
        x: leftXOffset, y: 0,
        width: screenRect.width / 2 - leftXOffset, height: screenRect.height
      )
      withAnimation {
        publisher.publish([
          .init(id: element.id.description,
                frame: frame)
        ])
      }
      shouldRun = true
      shouldRestore = true
      self.newFrame = frame
    } else if !shouldRun, isRightSide {
      // Mouse is in the right field
      let frame = CGRect(
        x: screenRect.width / 2, y: 0,
        width: screenRect.width / 2 - rightXOffset, height: screenRect.height
      )
      withAnimation {
        publisher.publish([
          .init(id: element.id.description,
                frame: frame)
        ])
      }
      shouldRun = true
      shouldRestore = true
      self.newFrame = frame
    } else if shouldRun, !isLeftSide && !isRightSide {
      shouldRestore = false
      shouldRun = false
      publisher.publish([])
    }
  }
}
