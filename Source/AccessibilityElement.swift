import Cocoa

final class AccessibilityElement {
  private let kAXEnhancedUserInterface: String = "AXEnhancedUserInterface"

  enum AccessibilityElementError: Error {
    case elementMissing
  }

  var window: AccessibilityElement? { return find() }

  var frame: CGRect? {
    get  {
      if let position = position, let size = size {
        return CGRect(origin: position, size: size)
      }
      return nil
    }
    set {
      if let newValue = newValue {
        let app = application()
        var enhancedUserInterfaceEnabled: Bool? = nil

        // Apply `enhancedUserInterfaceEnabled` fix based on https://github.com/rxhanson/Rectangle/pull/285
        if let app = app {
          enhancedUserInterfaceEnabled = app.isEnhancedUserInterfaceEnabled()
          AXUIElementSetAttributeValue(app.elementReference, kAXEnhancedUserInterface as CFString, kCFBooleanFalse)
        }

        position = newValue.origin
        size = newValue.size

        if let app = app, enhancedUserInterfaceEnabled == true {
          AXUIElementSetAttributeValue(app.elementReference, kAXEnhancedUserInterface as CFString, kCFBooleanTrue)
        }
      }
    }
  }

  var position: CGPoint? {
    get { return value(for: .position) }
    set {
      if let value = AXValue.from(value: newValue, type: .cgPoint) {
        AXUIElementSetAttributeValue(self.elementReference, kAXPositionAttribute as CFString, value)
      }
    }
  }

  var size: CGSize? {
    get { return value(for: .size) }
    set {
      if let value = AXValue.from(value: newValue, type: .cgSize) {
        AXUIElementSetAttributeValue(self.elementReference, kAXSizeAttribute as CFString, value)
      }
    }
  }

  private let elementReference: AXUIElement
  private var role: String? { return stringValue(for: .role) }
  private var parent: AccessibilityElement? { return try? accessibilityElement(for: .parent) }

  init(_ elementReference: AXUIElement?) throws {
    guard let elementReference = elementReference else {
      throw AccessibilityElementError.elementMissing
    }
    self.elementReference = elementReference
  }

  func element(at location: CGPoint) -> AccessibilityElement? {
    var reference: AXUIElement?
    AXUIElementCopyElementAtPosition(elementReference, Float(location.x), Float(location.y), &reference)
    let accessibilityElement = try? AccessibilityElement(reference)
    return accessibilityElement
  }

  // MARK: Private methods

  private func accessibilityElement(for attribute: NSAccessibility.Attribute) throws -> AccessibilityElement? {
    guard let rawValue = rawValue(for: attribute), CFGetTypeID(rawValue) == AXUIElementGetTypeID() else {
      return nil
    }

    let elementReference = rawValue as! AXUIElement
    return try AccessibilityElement(elementReference)
  }

  private func application() -> AccessibilityElement? {
    var element: AccessibilityElement? = self
    while element != nil, element?.role != kAXApplicationRole {
      if let nextElement: AccessibilityElement = element?.parent {
        element = nextElement
      } else {
        element = nil
      }
    }
    return element
  }

  private func isEnhancedUserInterfaceEnabled() -> Bool? {
    var rawValue: AnyObject?
    let error = AXUIElementCopyAttributeValue(self.elementReference, kAXEnhancedUserInterface as CFString, &rawValue)

    if error == .success && CFGetTypeID(rawValue) == CFBooleanGetTypeID() {
      return CFBooleanGetValue((rawValue as! CFBoolean))
    }

    return nil
  }

  private func find() -> AccessibilityElement? {
    var element: AccessibilityElement? = self
    while element != nil, element?.role != kAXWindowRole {
      if let nextElement: AccessibilityElement = element?.parent {
        element = nextElement
      } else {
        element = nil
      }
    }
    return element
  }

  private func stringValue(for attribute: NSAccessibility.Attribute) -> String? {
    return self.rawValue(for: attribute) as? String
  }

  private func value<T>(for attribute: NSAccessibility.Attribute) -> T? {
    if let rawValue = self.rawValue(for: attribute), CFGetTypeID(rawValue) == AXValueGetTypeID() {
      return (rawValue as! AXValue).toValue()
    }

    return nil
  }

  private func rawValue(for attribute: NSAccessibility.Attribute) -> AnyObject? {
    var rawValue: AnyObject?
    let cfString = attribute.rawValue as CFString
    let error = AXUIElementCopyAttributeValue(self.elementReference, cfString, &rawValue)

    if error != .success {
      return nil
    }

    return rawValue
  }
}

extension AXValue {
  func toValue<T>() -> T? {
    let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    let success = AXValueGetValue(self, AXValueGetType(self), pointer)
    return success ? pointer.pointee : nil
  }

  static func from<T>(value: T, type: AXValueType) -> AXValue? {
    let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    pointer.pointee = value
    return AXValueCreate(type, pointer)
  }
}

