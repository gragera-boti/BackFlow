import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var style: Style = .primary
    var isEnabled: Bool = true
    
    enum Style {
        case primary
        case secondary
        case destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary: return Theme.Colors.primary
            case .secondary: return Theme.Colors.secondary
            case .destructive: return Theme.Colors.error
            }
        }
        
        var foregroundColor: Color {
            return .white
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.headline)
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.medium)
                .background(isEnabled ? style.backgroundColor : Color.gray)
                .foregroundStyle(style.foregroundColor)
                .cornerRadius(Theme.CornerRadius.medium)
        }
        .disabled(!isEnabled)
    }
}
