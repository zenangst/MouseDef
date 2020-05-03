import Cocoa

class AppContext {
  lazy var accessibilityController = AccessibilityController()
  lazy var monitorController = MonitorController()
  lazy var mouseController = MouseController(accessibilityController: accessibilityController,
                                             resizeBehavior: .quadrant)

  let menuController: MenuBarController

  init() {
    self.menuController = MenuBarController()
  }
}
