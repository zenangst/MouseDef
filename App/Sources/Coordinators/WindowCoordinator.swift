import Bonzai
import Cocoa
import SwiftUI

@MainActor
final class WindowCoordinator<Content> where Content: View {
  private let controller: NSWindowController

  init(_ animationBehavior: NSWindow.AnimationBehavior, content: @escaping @autoclosure () -> Content) {
    let window = ZenPanel(
      animationBehavior: animationBehavior,
      contentRect: NSScreen.main!.frame,
      content: content()
    )
    let controller = NSWindowController(window: window)
    self.controller = controller
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenChanged),
      name: NSApplication.didChangeScreenParametersNotification,
      object: nil
    )
  }

  @objc func screenChanged() {
    guard let screenFrame = NSScreen.main?.frame else { return }
    self.controller.window?.setFrame(screenFrame, display: true)
  }

  func show() {
    controller.showWindow(nil)
    controller.window?.makeFirstResponder(nil)
  }

  func close() {
    controller.close()
  }
}
