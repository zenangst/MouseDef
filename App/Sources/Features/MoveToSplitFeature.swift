import AXEssibility
import SwiftUI

final class MoveToSplitFeature: MoveFeature {
  private var sizeCache = [CGWindowID: CGRect]()
  var id: String { "moveToSplit" }
  var isEnabled: Bool { true }
  var shouldRun: Bool = false
  var shouldRestore: Bool = false

  var newFrame: CGRect?

  let publisher: WindowBorderViewPublisher

  init(_ publisher: WindowBorderViewPublisher) {
    self.publisher = publisher
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
    element.frame = newFrame

    if let adjustedFrame = element.frame, let screen = NSScreen.main {
      if adjustedFrame.maxX > screen.frame.maxX {
        element.frame?.origin.x = screen.frame.maxX - element.frame!.width
      }
    }

    shouldRun = false
    publisher.publish([])
    self.newFrame = nil
  }
  
  func evaluate(_ screen: NSScreen, element: AXEssibility.WindowAccessibilityElement) {
    let screenRect = screen.frame
    let mouseLocation = Mouse().location
    let leftField = screen.frame.maxX - screen.visibleFrame.maxX

    let isLeftSide = mouseLocation.x - 20 <= leftField
    let isRightSide = mouseLocation.x >= screen.frame.maxX - 10

    if !shouldRun, isLeftSide {
      // Mouse is in the left field
      let frame = CGRect(
        x: 0, y: 0,
        width: screenRect.width / 2, height: screenRect.height
      )
      withAnimation {
        publisher.publish([
          .init(id: element.id.description,
                frame: frame)
        ])
      }
      shouldRun = true
      shouldRestore = true
      newFrame = frame
    } else if !shouldRun, isRightSide {
      // Mouse is in the right field
      let frame = CGRect(
        x: screenRect.width / 2, y: 0,
        width: screenRect.width / 2, height: screenRect.height
      )
      withAnimation {
        publisher.publish([
          .init(id: element.id.description,
                frame: frame)
        ])
      }
      shouldRun = true
      shouldRestore = true
      newFrame = frame
    } else if shouldRun, !isLeftSide && !isRightSide {
      shouldRestore = false
      shouldRun = false
      publisher.publish([])
    }
  }
}
