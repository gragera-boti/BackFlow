import Foundation
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "PlanViewModel")

@MainActor @Observable
final class PlanViewModel {
    // MARK: - Published State
    private(set) var activePlan: ProgramPlan?
    private(set) var sessions: [Session] = []
    
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let programService: ProgramServiceProtocol
    private let sessionService: SessionServiceProtocol
    
    // MARK: - Initialization
    init(
        programService: ProgramServiceProtocol,
        sessionService: SessionServiceProtocol
    ) {
        self.programService = programService
        self.sessionService = sessionService
    }
    
    // MARK: - Computed Properties
    var hasActivePlan: Bool {
        return activePlan != nil
    }
    
    var currentWeekDisplay: String {
        guard let plan = activePlan else { return "No Plan" }
        return "Week \(plan.currentWeek)"
    }
    
    var currentPhaseDisplay: String {
        guard let plan = activePlan else { return "" }
        // Remove "phase-" prefix if present
        let phaseId = plan.currentPhaseId.replacingOccurrences(of: "phase-", with: "")
        return "Phase \(phaseId.capitalized)"
    }
    
    var isPlanPaused: Bool {
        return activePlan?.isPaused ?? false
    }
    
    var pausedReason: String? {
        return activePlan?.pausedReason
    }
    
    var activityLadderProgress: Double {
        guard let plan = activePlan else { return 0 }
        return Double(plan.activityLadderLevel + 1) / 5.0
    }
    
    var activityLadderLevel: String {
        guard let plan = activePlan else { return "Level 1 of 5" }
        return "Level \(plan.activityLadderLevel + 1) of 5"
    }
    
    // TODO: This should come from program template data
    var currentPhaseExercises: [(name: String, sets: Int, reps: String)] {
        return [
            ("Cat-Cow", 2, "8"),
            ("Bird Dog", 2, "6/side"),
            ("Dead Bug", 2, "8"),
            ("Glute Bridge", 2, "10")
        ]
    }
    
    // MARK: - Actions
    func loadData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Load plan and recent sessions concurrently
            async let planTask = programService.fetchActivePlan()
            async let sessionsTask = sessionService.fetchRecentSessions(limit: 10)
            
            activePlan = try await planTask
            sessions = try await sessionsTask
            
            logger.info("Loaded plan data successfully")
        } catch let error as ProgramServiceError {
            logger.error("Program service error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch let error as SessionServiceError {
            logger.error("Session service error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            errorMessage = "An unexpected error occurred"
        }
    }
    
    func getUpcomingSessionDates() -> [Date] {
        guard let plan = activePlan else { return [] }
        
        let calendar = Calendar.current
        var dates: [Date] = []
        
        for weekday in plan.weekdays.sorted() {
            var components = DateComponents()
            components.weekday = weekday + 1 // Convert to 1-indexed
            
            if let date = calendar.nextDate(
                after: Date(),
                matching: components,
                matchingPolicy: .nextTime,
                direction: .forward
            ) {
                dates.append(date)
            }
        }
        
        return Array(dates.prefix(5))
    }
    
    func formatWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    func clearError() {
        errorMessage = nil
    }
}