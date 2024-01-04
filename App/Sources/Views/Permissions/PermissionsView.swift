import AXEssibility
import Bonzai
import SwiftUI

struct PermissionsView: View {
  @StateObject var accessibilityPermission = AccessibilityPermission.shared

  var body: some View {
    VStack {
      Grid(alignment: .topLeading, horizontalSpacing: 16, verticalSpacing: 32) {
        GridRow {
          PermissionOverviewItem(
            status: .init(get: { accessibilityPermission.viewModel }, set: { _ in }),
            icon: "cursorarrow.and.square.on.square.dashed",
            name: "Accessibility Permissions",
            explanation: "Used to move and resize windows using modifiers keys and mouse movement.",
            color: Color(.systemPurple)
          ) {
            AccessibilityPermission.shared.requestPermission()
          }
          .animation(.easeInOut, value: accessibilityPermission.viewModel)
        }
      }
    }
    .roundedContainer()
    .frame(minWidth: 350)
  }
}

fileprivate struct PermissionOverviewItem: View {
  @Namespace var namespace
  @Binding var status: AccessibilityPermissionsItemStatus

  let icon: String
  let name: String
  let explanation: String
  let color: Color
  let onAction: () -> Void

  var body: some View {
    Image(systemName: icon)
      .resizable()
      .symbolRenderingMode(.palette)
      .aspectRatio(contentMode: .fit)
      .frame(width: 24, height: 24)
      .foregroundStyle(Color(.textColor), Color(.controlAccentColor))

    VStack(alignment: .leading) {
      Text(name)
        .font(.headline)
        .bold()
      Text(explanation)
        .font(.caption)
    }
    .frame(maxWidth: .infinity, alignment: .leading)

    HStack {
      switch status {
      case .approved:
        Image(systemName: "checkmark.circle.fill")
          .symbolRenderingMode(.palette)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 20, height: 20)
          .foregroundStyle(Color(.white), Color(.systemGreen))
          .matchedGeometryEffect(id: "permission-overview-item", in: namespace)
      case .pending:
        ProgressView()
          .progressViewStyle(.circular)
          .matchedGeometryEffect(id: "permission-overview-item", in: namespace)
      case .request, .unknown:
        Button(action: onAction, label: { Text(status.rawValue) })
          .buttonStyle(.zen(.init(color: .systemGreen)))
          .matchedGeometryEffect(id: "permission-overview-item", in: namespace)
      }
    }
  }
}

struct PermissionsOverview_Previews: PreviewProvider {
  static var previews: some View {
    PermissionsView()
      .background()
  }
}
