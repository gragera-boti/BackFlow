import SwiftUI
import Charts

struct WalkingChartView: View {
    let weeklyData: [(String, Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Weekly Walking")
                .font(Theme.Typography.headline)
            
            if weeklyData.isEmpty {
                ContentUnavailableView(
                    "No Walking Data",
                    systemImage: "figure.walk",
                    description: Text("Log walks to track progress")
                )
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(weeklyData, id: \.0) { week, minutes in
                        BarMark(
                            x: .value("Week", week),
                            y: .value("Minutes", minutes)
                        )
                        .foregroundStyle(Theme.Colors.secondary)
                    }
                }
                .frame(height: 200)
            }
        }
        .padding(Theme.Spacing.medium)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(Theme.CornerRadius.large)
    }
}