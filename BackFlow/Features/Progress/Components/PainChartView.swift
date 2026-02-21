import SwiftUI
import Charts

struct PainChartView: View {
    let chartData: [(Date, Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Pain Trend")
                .font(Theme.Typography.headline)
            
            if chartData.isEmpty {
                ContentUnavailableView(
                    "No Pain Data",
                    systemImage: "chart.line.downtrend.xyaxis",
                    description: Text("Log your symptoms to see trends")
                )
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(chartData, id: \.0) { date, pain in
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Pain", pain)
                        )
                        .foregroundStyle(Theme.Colors.warning)
                        
                        PointMark(
                            x: .value("Date", date),
                            y: .value("Pain", pain)
                        )
                        .foregroundStyle(Theme.Colors.warning)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...10)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 5, 10])
                }
            }
        }
        .padding(Theme.Spacing.medium)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(Theme.CornerRadius.large)
    }
}