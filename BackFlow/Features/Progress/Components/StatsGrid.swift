import SwiftUI

struct StatsGrid: View {
    let totalSessions: Int
    let currentStreak: Int
    let totalWalkingMinutes: Int
    let sessionsThisWeek: Int
    let plannedThisWeek: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Summary")
                .font(Theme.Typography.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Theme.Spacing.medium) {
                StatCard(
                    title: "Sessions",
                    value: "\(totalSessions)",
                    icon: "figure.strengthtraining.traditional",
                    color: Theme.Colors.primary
                )
                
                StatCard(
                    title: "Streak",
                    value: "\(currentStreak) days",
                    icon: "flame.fill",
                    color: Theme.Colors.warning
                )
                
                StatCard(
                    title: "Walking",
                    value: "\(totalWalkingMinutes) min",
                    icon: "figure.walk",
                    color: Theme.Colors.secondary
                )
                
                StatCard(
                    title: "This Week",
                    value: "\(sessionsThisWeek)/\(plannedThisWeek)",
                    icon: "calendar",
                    color: Theme.Colors.accent
                )
            }
        }
    }
}