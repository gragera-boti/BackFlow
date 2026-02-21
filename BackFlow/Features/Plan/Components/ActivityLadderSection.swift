import SwiftUI

struct ActivityLadderSection: View {
    let level: String
    let progress: Double
    
    var body: some View {
        CardView(backgroundColor: Theme.Colors.secondary.opacity(0.1)) {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text("Walking Progression")
                    .font(Theme.Typography.headline)
                
                Text(level)
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(Theme.Colors.textSecondary)
                
                ProgressView(value: progress)
                    .tint(Theme.Colors.secondary)
                
                Text("Current target: 90 minutes per week")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
    }
}