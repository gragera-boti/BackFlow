import Foundation
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "ProgressViewModel")

@MainActor @Observable
final class ProgressViewModel {
    // MARK: - Published State
    private(set) var sessions: [Session] = []
    private(set) var symptomLogs: [SymptomLog] = []
    private(set) var walkingLogs: [WalkingLog] = []
    
    var selectedMetric: ProgressMetric = .pain
    
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let sessionService: SessionServiceProtocol
    private let symptomService: SymptomServiceProtocol
    private let walkingService: WalkingServiceProtocol
    
    // MARK: - Initialization
    init(
        sessionService: SessionServiceProtocol,
        symptomService: SymptomServiceProtocol,
        walkingService: WalkingServiceProtocol
    ) {
        self.sessionService = sessionService
        self.symptomService = symptomService
        self.walkingService = walkingService
    }
    
    // MARK: - Computed Properties - Pain Data
    var painChartData: [(Date, Int)] {
        symptomLogs
            .filter { $0.painNow != nil }
            .map { ($0.timestamp, $0.painNow!) }
            .sorted { $0.0 < $1.0 }
    }
    
    // MARK: - Computed Properties - Walking Data
    var weeklyWalkingData: [(String, Int)] {
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
    
    // MARK: - Computed Properties - Adherence Data
    var weeklyAdherenceData: [(String, Double)] {
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
    
    // MARK: - Computed Properties - Stats
    var totalCompletedSessions: Int {
        sessions.filter { $0.completed }.count
    }
    
    var totalWalkingMinutes: Int {
        walkingLogs.reduce(0) { $0 + $1.durationMinutes }
    }
    
    var currentStreak: Int {
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
    
    var sessionsThisWeek: Int {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return sessions.filter { $0.completed && $0.date >= weekStart }.count
    }
    
    var plannedSessionsThisWeek: Int {
        3 // TODO: Get from user profile/program plan
    }
    
    // MARK: - Actions
    func loadData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // TODO: These services need to be created
            // For now, using placeholder implementations
            logger.info("Loading progress data...")
            
            // Placeholder: fetch recent sessions
            sessions = [] // try await sessionService.fetchRecentSessions(limit: 50)
            
            // Placeholder: fetch symptom logs
            symptomLogs = []
            
            // Placeholder: fetch walking logs
            walkingLogs = []
            
            logger.info("Loaded progress data successfully")
        } catch {
            logger.error("Error loading progress data: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Supporting Types
enum ProgressMetric: String, CaseIterable, Identifiable {
    case pain = "Pain"
    case walking = "Walking"
    case adherence = "Adherence"
    
    var id: String { rawValue }
}

// MARK: - Placeholder Service Protocol
// TODO: This should be moved to proper service protocol files

protocol SymptomServiceProtocol {
    func fetchSymptomLogs(from startDate: Date?, to endDate: Date?) async throws -> [SymptomLog]
}