import SwiftUI
import SwiftData
import Charts

struct ProgressTrackingView: View {
    @Query(sort: \Session.date) private var sessions: [Session]
    @Query(sort: \SymptomLog.timestamp) private var symptomLogs: [SymptomLog]
    @Query(sort: \WalkingLog.date) private var walkingLogs: [WalkingLog]
    
    @State private var selectedMetric: ProgressMetric = .pain
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Metric Selector
                    Picker("Metric", selection: $selectedMetric) {
                        ForEach(ProgressMetric.allCases) { metric in
                            Text(metric.rawValue).tag(metric)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Chart
                    switch selectedMetric {
                    case .pain:
                        PainChartView(symptomLogs: symptomLogs)
                    case .walking:
                        WalkingChartView(walkingLogs: walkingLogs)
                    case .adherence:
                        AdherenceChartView(sessions: sessions)
                    }
                    
                    // Stats Summary
                    StatsGrid(sessions: sessions, walkingLogs: walkingLogs)
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }
}

enum ProgressMetric: String, CaseIterable, Identifiable {
    case pain = "Pain"
    case walking = "Walking"
    case adherence = "Adherence"
    
    var id: String { rawValue }
}

struct PainChartView: View {
    let symptomLogs: [SymptomLog]
    
    var chartData: [(Date, Int)] {
        symptomLogs
            .filter { $0.painNow != nil }
            .map { ($0.timestamp, $0.painNow!) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pain Trend")
                .font(.headline)
            
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
                        .foregroundStyle(.orange)
                        
                        PointMark(
                            x: .value("Date", date),
                            y: .value("Pain", pain)
                        )
                        .foregroundStyle(.orange)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...10)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 5, 10])
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

struct WalkingChartView: View {
    let walkingLogs: [WalkingLog]
    
    var weeklyData: [(String, Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: walkingLogs) { log in
            calendar.component(.weekOfYear, from: log.date)
        }
        
        return grouped.map { week, logs in
            let total = logs.reduce(0) { $0 + $1.durationMinutes }
            return ("Week \(week)", total)
        }
        .sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Walking")
                .font(.headline)
            
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
                        .foregroundStyle(.green)
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

struct AdherenceChartView: View {
    let sessions: [Session]
    
    var weeklyAdherence: [(String, Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.component(.weekOfYear, from: session.date)
        }
        
        return grouped.map { week, sessions in
            let completed = sessions.filter { $0.completed }.count
            let total = sessions.count
            let percentage = total > 0 ? Double(completed) / Double(total) * 100 : 0
            return ("Week \(week)", percentage)
        }
        .sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Adherence")
                .font(.headline)
            
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
                        .foregroundStyle(.blue)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...100)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

struct StatsGrid: View {
    let sessions: [Session]
    let walkingLogs: [WalkingLog]
    
    var totalSessions: Int {
        sessions.filter { $0.completed }.count
    }
    
    var totalWalkingMinutes: Int {
        walkingLogs.reduce(0) { $0 + $1.durationMinutes }
    }
    
    var currentStreak: Int {
        // Simplified streak calculation
        let completedDates = sessions
            .filter { $0.completed }
            .map { Calendar.current.startOfDay(for: $0.date) }
            .sorted(by: >)
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        for date in completedDates {
            if date == currentDate {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Sessions",
                    value: "\(totalSessions)",
                    icon: "figure.strengthtraining.traditional",
                    color: .blue
                )
                
                StatCard(
                    title: "Streak",
                    value: "\(currentStreak) days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Walking",
                    value: "\(totalWalkingMinutes) min",
                    icon: "figure.walk",
                    color: .green
                )
                
                StatCard(
                    title: "This Week",
                    value: "\(sessionsThisWeek)/\(plannedThisWeek)",
                    icon: "calendar",
                    color: .purple
                )
            }
        }
    }
    
    var sessionsThisWeek: Int {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return sessions.filter { $0.completed && $0.date >= weekStart }.count
    }
    
    var plannedThisWeek: Int {
        3 // TODO: Get from user profile
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Session.self, SymptomLog.self, WalkingLog.self,
        configurations: config
    )
    return ProgressTrackingView()
        .modelContainer(container)
}
