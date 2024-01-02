import Foundation

enum ResizeCoordinator {
  static func resize(to rect: inout CGRect,
                     with mousePosition: CGPoint,
                     behavior: MouseResizeBehavior,
                     lastQuadrant: inout Quadrant?,
                     delta: inout CGPoint) {
    let x: CGFloat = delta.x.round(nearest: 1.0) - mousePosition.x.round(nearest: 1.0)
    let y: CGFloat = delta.y.round(nearest: 1.0) - mousePosition.y.round(nearest: 1.0)
    let newDelta = CGPoint(x: x, y: y)

    switch behavior {
    case .standard:
      rect.size.width -= newDelta.x
      rect.size.height -= newDelta.y
    case .quadrant:
      let quadrant = lastQuadrant ?? rect.quadrant(for: mousePosition)
      lastQuadrant = quadrant

      switch quadrant {
      case .first:
        rect.origin.x -= newDelta.x
        rect.size.width += newDelta.x
        rect.origin.y -= newDelta.y
        rect.size.height += newDelta.y
      case .second:
        rect.size.width -= newDelta.x
        rect.size.height += newDelta.y
        rect.origin.y -= newDelta.y
      case .third:
        rect.origin.x -= newDelta.x
        rect.size.width += newDelta.x
        rect.size.height -= newDelta.y
      case .fourth:
        rect.size.width -= newDelta.x
        rect.size.height -= newDelta.y
      }
    }
  }
}

extension CGFloat {
  func round(nearest: CGFloat) -> CGFloat {
    let n: CGFloat = 1.0 / nearest
    let numberToRound: CGFloat = self * n
    return numberToRound.rounded() / n
  }
}

fileprivate extension CGRect {
  func quadrant(for point: CGPoint) -> Quadrant {
    var quadrant: Int = 0
    if point.x - self.origin.x > self.width / 2 {
      quadrant += 1
    }

    if point.y - self.origin.y > self.height / 2 {
      quadrant += 2
    }

    if quadrant == 0 { return .first }
    if quadrant == 1 { return .second }
    if quadrant == 2 { return .third }

    return .fourth
  }
}
