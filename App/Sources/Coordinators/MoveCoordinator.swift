import Foundation

enum MoveCoordinator {
  static func move(to windowOrigin: inout CGPoint, with mouseOrigin: CGPoint, 
                   delta: inout CGPoint) {
    let x: CGFloat = delta.x.round(nearest: 1.0) - mouseOrigin.x.round(nearest: 1.0)
    let y: CGFloat = delta.y.round(nearest: 1.0) - mouseOrigin.y.round(nearest: 1.0)
    let newDelta = CGPoint(x: x, y: y)
    windowOrigin.x -= newDelta.x
    windowOrigin.y -= newDelta.y

    delta = mouseOrigin
  }
}
