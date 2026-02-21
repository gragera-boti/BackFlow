import SwiftUI

struct WalkingTargetCard: View {
    let todayMinutes: Int
    let targetMinutes: Int
    let progress: Double
    let onLogWalk: () -> Void
    
    var body: some View {
        CardView(backgroundColor: Theme.Colors.secondary.opacity(0.1)) {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                header
                
                ProgressView(value: progress)
                    .tint(Theme.Colors.secondary)
                
                logButton
            }
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                Text("Walking Target")
                    .font(Theme.Typography.headline)
                Text("\(todayMinutes) / \(targetMinutes) min")
                    .font(Theme.Typography.title3)
                    .fontWeight(.medium)
            }
            Spacer()
            Image(systemName: "figure.walk")
                .font(.largeTitle)
                .foregroundStyle(Theme.Colors.secondary)
        }
    }
    
    private var logButton: some View {
        Button(action: onLogWalk) {
            Text("Log Walk")
                .font(Theme.Typography.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.xSmall)
                .background(Theme.Colors.secondary.opacity(0.2))
                .foregroundStyle(Theme.Colors.secondary)
                .cornerRadius(Theme.CornerRadius.small)
        }
    }
}
