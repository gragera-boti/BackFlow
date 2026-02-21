import SwiftUI

struct UpcomingSessionsSection: View {
    let upcomingDates: [Date]
    let formatWeekday: (Date) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Upcoming Sessions")
                .font(Theme.Typography.headline)
            
            ForEach(upcomingDates, id: \.self) { date in
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                        Text(date, style: .date)
                            .font(Theme.Typography.body)
                        Text(formatWeekday(date))
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundStyle(Theme.Colors.primary)
                }
                .padding(Theme.Spacing.medium)
                .background(Theme.Colors.primary.opacity(0.05))
                .cornerRadius(Theme.CornerRadius.small)
            }
        }
    }
}