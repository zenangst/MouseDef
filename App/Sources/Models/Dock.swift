import Cocoa

private class AppleScript {
  static let shared: AppleScript = .init()

  let show: NSAppleScript
  let hide: NSAppleScript

  private init() { 
    self.hide = Self.compile("tell dock preferences to set autohide to true")
    self.show = Self.compile("tell dock preferences to set autohide to not autohide")
  }

  static private func compile(_ source: String) -> NSAppleScript {
    var errorInfo: NSDictionary?
    let source = Self.source(source)
    let appleScript = NSAppleScript(source: source)!
    appleScript.compileAndReturnError(&errorInfo)
    return appleScript
  }

  static private func source(_ contents: String) -> String {
    return """
    tell application "System Events"
        \(contents)
    end tell
    """
  }
}

enum Dock {
  enum Position: String {
    case left
    case right
    case bottom
    
    fileprivate static func get() -> Position {
      return Dock.Position(rawValue: dockDefaults.string(forKey: "orientation") ?? "bottom") ?? .bottom
    }
  }
  
  case unknown, shown, hidden
  
  static let dockDefaults = UserDefaults(suiteName: "com.apple.dock")!

  static var state: Dock {
    if dockDefaults.integer(forKey: "autohide") == 1 {
      return .hidden
    } else {
      return .shown
    }
  }

  static var autohide: Bool {
    get { dockDefaults.integer(forKey: "autohide") == 1 }
    set { dockDefaults.set(newValue ? 1 : 0, forKey: "autohide") }
  }

  static var position: Position {
    Dock.Position.get()
  }

  static var tileSize: Double {
    dockDefaults.double(forKey: "tilesize")
  }

  static func show() {
    DispatchQueue.global(qos: .userInteractive).async {
      var errorInfo: NSDictionary?
      AppleScript.shared.show.executeAndReturnError(&errorInfo)
    }
  }

  static func hide() {
    DispatchQueue.global(qos: .userInteractive).async {
      var errorInfo: NSDictionary?
      AppleScript.shared.hide.executeAndReturnError(&errorInfo)
    }
  }
}
