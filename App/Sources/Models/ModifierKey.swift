import CoreGraphics
import AppKit
import Foundation

enum ModifierKey: String, Codable, Hashable, Identifiable, Sendable {
  var id: String { return rawValue }

  case shift = "$"
  case function = "fn"
  case control = "^"
  case option = "~"
  case command = "@"

  static var allCases: [ModifierKey] {
    return [.function, .shift, .control, .option, .command]
  }

  var symbol: String {
    switch self {
    case .function: "globe"
    case .shift: ""
    case .control: ""
    case .option: ""
    case .command: ""
    }
  }

  var textValue: String {
    switch self {
    case .function: "Function"
    case .shift:    "Shift"
    case .control:  "Control"
    case .option:   "Option"
    case .command:  "Command"
    }
  }

  var writtenValue: String {
    switch self {
    case .function, .shift: ""
    case .control:          "control"
    case .option:           "option"
    case .command:          "command"
    }
  }

  var keyValue: String {
    switch self {
    case .function: "fn"
    case .shift:    "⇧"
    case .control:  "⌃"
    case .option:   "⌥"
    case .command:  "⌘"
    }
  }

  var pretty: String {
    switch self {
    case .function:"ƒ"
    case .shift:   "⇧"
    case .control: "⌃"
    case .option:  "⌥"
    case .command: "⌘"
    }
  }

  var nsModifierFlags: NSEvent.ModifierFlags {
    switch self {
    case .shift:    .shift
    case .control:  .control
    case .option:   .option
    case .command:  .command
    case .function: .function
    }
  }

  var cgModifierFlags: CGEventFlags {
    switch self {
    case .shift:    .maskShift
    case .control:  .maskControl
    case .option:   .maskAlternate
    case .command:  .maskCommand
    case .function: .maskSecondaryFn
    }
  }
}

extension Array<ModifierKey> {
  var cgModifierFlags: CGEventFlags {
    return reduce(into: []) { $0.insert($1.cgModifierFlags) }
  }
}
