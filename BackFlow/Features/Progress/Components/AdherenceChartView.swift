import SwiftUI
import Charts

struct AdherenceChartView: View {
    let weeklyAdherence: [(String, Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Session Adherence")
                .font(Theme.Typography.headline)
            
            if weeklyAdherence.isEmpty {
                ContentUnavailableView(
                    "No Session Data",
                    systemImage: "chart.bar",
                    description: Text("Complete sessions to track adherence")
                )
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(weeklyAdherence, id: \.0) { week, percentage in
                        BarMark(
                            x: .value("Week", week),
                            y: .value("Completion %", percentage)
                        )
                        .foregroundStyle(Theme.Colors.primary)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...100)
            }
        }
        .padding(Theme.Spacing.medium)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(Theme.CornerRadius.large)
    }
}