import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, MenubarControllerDelegate {
  var appContext: AppContext?

  func applicationDidFinishLaunching(_ notification: Notification) {
//    askForAccessibilityIfNeeded()

    let appContext = AppContext()
    appContext.monitorController.start(appContext.mouseController.handleState(_:))
    appContext.menuController.delegate = self
    self.appContext = appContext
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

  func menubarController(_ controller: MenuBarController, didTapQuitApplication quitApplicationMenuItem: NSMenuItem) {
    NSApp.terminate(nil)
  }
}
