import Cocoa

protocol MenubarControllerDelegate: class {
  func menubarController(_ controller: MenuBarController, didTapQuitApplication quitApplicationMenuItem: NSMenuItem)
}

class MenuBarController {
  weak var delegate: MenubarControllerDelegate?
  var menu: NSMenu
  var statusItem: NSStatusItem

  init() {
    let statusBar = NSStatusBar.system
    let statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
    statusItem.button?.image = NSImage(named: "MouseDef-MenuBar")
    statusItem.button?.toolTip = "MouseDef"
    statusItem.button?.isEnabled = true

    self.statusItem = statusItem
    self.menu = NSMenu()

    statusItem.menu = menu

    menu.addItem(createMenuItem("Quit", action: #selector(quitApplication(_:)), keyEquivalent: "q"))
  }

  @objc func quitApplication(_ menuItem: NSMenuItem) {
    delegate?.menubarController(self, didTapQuitApplication: menuItem)
  }

  // MARK: - Private methods

  fileprivate func createMenuItem(_ title: String, action: Selector, keyEquivalent: String = "") -> NSMenuItem {
    let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
    menuItem.target = self
    return menuItem
  }
}
