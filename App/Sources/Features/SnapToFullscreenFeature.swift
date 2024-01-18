import AXEssibility
import Combine
import Cocoa
import Intercom
import SwiftUI

final class SnapToFullscreenFeature: MoveFeature, @unchecked Sendable {
  private var sizeCache = [CGWindowID: CGRect]()
  private lazy var systemElement = SystemAccessibilityElement()
  var id: String { "moveToFullscreen" }
  var isEnabled: Bool { AppSettings.shared.snapToFullscreenFeature }
  var shouldRun: Bool = false
  var shouldRestore: Bool = false
  var externalSubscription: AnyCancellable?

  let intercom = Intercom(MouseDefIntercomApp.self)
  let publisher: WindowBorderViewPublisher
  let autohideDockFeature: AutoHideDockFeature

  init(_ publisher: WindowBorderViewPublisher, autohideDockFeature: AutoHideDockFeature) {
    self.publisher = publisher
    self.autohideDockFeature = autohideDockFeature

    externalSubscription = intercom.receive(.snapToFullscreen, onRecieve: { [weak self] _ in
      guard let self else { return }
      DispatchQueue.main.async {
        try? self.externalRun()
      }
    })
  }

  @MainActor
  func restore(_ element: WindowAccessibilityElement, frame: inout CGRect) {
    guard shouldRestore, let previousFrame = sizeCache[element.id] else { return }

    shouldRestore = false

    let deltaWidth = frame.size.width - previousFrame.width
    frame.origin.x += deltaWidth / 2
    element.size = previousFrame.size
    sizeCache[element.id] = nil
    publisher.publish([])
  }

  @MainActor
  func run(_ element: WindowAccessibilityElement) {
    guard shouldRun else { return }
    sizeCache[element.id] = element.frame

    Dock.hide()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      element.frame = NSScreen.main!.frame
    }

    shouldRun = false
    publisher.publish([])
  }

  @MainActor
  func evaluate(_ screen: NSScreen, newFrame: CGRect, element: WindowAccessibilityElement) {
    let screenRect = screen.frame
    let mouseLocation = Mouse().location
    let topField = screen.frame.maxY - screen.visibleFrame.maxY

    if newFrame.origin.y < topField || mouseLocation.y <= topField {
      var fullscreen = screenRect
      fullscreen.origin.y = topField
      fullscreen.size.height -= topField
      shouldRestore = true
      shouldRun = true

      withAnimation {
        publisher.publish([
          .init(id: element.id.description, frame: fullscreen)
        ])
      }
    } else if shouldRun {
      publisher.publish([])
      shouldRestore = false
      shouldRun = false
    }
  }

  @MainActor
  private func externalRun() throws {
    guard let screen = NSScreen.main,
          let frontmostApplication = NSWorkspace.shared.frontmostApplication else { return }
    let app = AppAccessibilityElement(frontmostApplication.processIdentifier)
    var previousValue: Bool = false
    if app.enhancedUserInterface == true {
      app.enhancedUserInterface = false
      previousValue = true
    }

    var focusedElement: AnyFocusedAccessibilityElement
    let focusedWindow: WindowAccessibilityElement?
    do {
      focusedElement = try systemElement.focusedUIElement()
      if let focusedApp = focusedElement.app {
        focusedWindow = try focusedApp.focusedWindow()
      } else {
        focusedWindow = try app.focusedWindow()
      }
    } catch {
      let element = try app.focusedWindow()
      focusedElement = AnyFocusedAccessibilityElement(element.reference)
      focusedWindow = element
    }

    guard let focusedWindow else {
      app.enhancedUserInterface = previousValue
      return
    }

    let newFrame: CGRect
    if let oldFrame = sizeCache[focusedWindow.id] {
      // Reset an go back to fullscreen if the windows frame was changed
      // between going fullscreen and restoring.
      if let currentFrame = focusedWindow.frame {
        let deltaWidth = screen.frame.size.width - currentFrame.width
        if deltaWidth > 100 {
          sizeCache[focusedWindow.id] = currentFrame
          setNewFrame(screen.frame, to: focusedWindow, on: screen)
          return
        }
      }

      sizeCache[focusedWindow.id] = nil
      newFrame = oldFrame
    } else {
      sizeCache[focusedWindow.id] = focusedWindow.frame
      newFrame = screen.frame
    }

    setNewFrame(newFrame, to: focusedWindow, on: screen)
  }

  @MainActor
  private func setNewFrame(_ newFrame: CGRect,
                           to window: WindowAccessibilityElement,
                           on screen: NSScreen) {
    autohideDockFeature.evaluate(screen, newFrame: newFrame, element: window)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      window.frame = newFrame
    }
  }
}
