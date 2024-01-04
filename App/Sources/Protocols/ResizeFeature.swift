import AXEssibility
import Cocoa

protocol ResizeFeature {
  @MainActor
  var isEnabled: Bool { get }
  var shouldRun: Bool { get }
  var shouldRestore: Bool { get set }

  @MainActor
  func restore(_ element: WindowAccessibilityElement, frame: inout CGRect)
  @MainActor
  func run(_ element: WindowAccessibilityElement)
  @MainActor
  func evaluate(_ screen: NSScreen, newFrame: CGRect, element: WindowAccessibilityElement)
}
