import SwiftUI

struct PlanOverviewSection: View {
    let weekDisplay: String
    let phaseDisplay: String
    let isPaused: Bool
    let pausedReason: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Your Plan")
                .font(Theme.Typography.title2)
                .fontWeight(.bold)
            
            CardView(backgroundColor: Theme.Colors.primary.opacity(0.1)) {
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                        Text(weekDisplay)
                            .font(Theme.Typography.headline)
                        Text(phaseDisplay)
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    if isPaused {
                        Label("Paused", systemImage: "pause.circle.fill")
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Theme.Colors.warning)
                    }
                }
            }
        }
    }
}