import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
  lazy var accessibilityController = AccessibilityController()
  lazy var monitorController = MonitorController()
  lazy var mouseController = MouseController(accessibilityController: accessibilityController,
                                             resizeBehavior: .quadrant)

  func applicationDidFinishLaunching(_ notification: Notification) {
    askForAccessibilityIfNeeded()
    monitorController.start(mouseController.handleState(_:))
  }

  private func askForAccessibilityIfNeeded() {
    let options: [String: Bool] = [
      kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
    ]
    guard !AXIsProcessTrustedWithOptions(options as CFDictionary) else { return }

    let alert = NSAlert()
    alert.messageText = "Enable Accessibility"
    alert.informativeText = """
    MouseDef requires access to accessibility.

    To enable this, click on \"Open System Preferences\" on the dialog that just appeared.

    When the setting is enabled, restart MouseDef and you should be ready to go.
    """
    alert.alertStyle = .warning
    alert.addButton(withTitle: "Quit")
    alert.runModal()
    NSApp.terminate(nil)
  }
}
