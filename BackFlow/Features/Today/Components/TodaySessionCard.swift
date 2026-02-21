import SwiftUI

struct TodaySessionCard: View {
    let phaseDisplay: String
    let isPaused: Bool
    let pausedReason: String?
    let hasSession: Bool
    let nextSessionDate: Date?
    let onStartSession: () -> Void
    
    var body: some View {
        CardView(backgroundColor: Theme.Colors.primary.opacity(0.1)) {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                header
                
                if isPaused {
                    pausedContent
                } else if hasSession {
                    sessionButton
                } else {
                    completedContent
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                Text("Today's Session")
                    .font(Theme.Typography.headline)
                Text(phaseDisplay)
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            Spacer()
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.largeTitle)
                .foregroundStyle(Theme.Colors.primary)
        }
    }
    
    private var pausedContent: some View {
        Text("Plan paused: \(pausedReason ?? "Unknown")")
            .font(Theme.Typography.subheadline)
            .foregroundStyle(Theme.Colors.warning)
    }
    
    private var sessionButton: some View {
        PrimaryButton(
            title: "Start Session",
            action: onStartSession,
            style: .primary
        )
    }
    
    private var completedContent: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text("✓ Session completed")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(Theme.Colors.success)
            
            if let nextDate = nextSessionDate {
                Text("Next session: \(nextDate, style: .date)")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
    }
}
