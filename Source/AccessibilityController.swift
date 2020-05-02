import Cocoa

final class AccessibilityController {
  private lazy var systemElement: AccessibilityElement = {
    return try! AccessibilityElement(AXUIElementCreateSystemWide())
  }()

  func element(at location: CGPoint) throws -> AccessibilityElement? {
    return systemElement.element(at: location)
  }
}
