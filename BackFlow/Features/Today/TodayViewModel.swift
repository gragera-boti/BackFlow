import Foundation
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "TodayViewModel")

@MainActor @Observable
final class TodayViewModel {
    // MARK: - Published State
    private(set) var activePlan: ProgramPlan?
    private(set) var todaySession: Session?
    private(set) var todayWalkingMinutes: Int = 0
    private(set) var randomEducationCard: EducationCard?
    
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let programService: ProgramServiceProtocol
    private let sessionService: SessionServiceProtocol
    private let walkingService: WalkingServiceProtocol
    private let educationService: EducationServiceProtocol
    
    // MARK: - Constants
    let walkingTargetMinutes: Int = 30
    
    // MARK: - Initialization
    init(
        programService: ProgramServiceProtocol,
        sessionService: SessionServiceProtocol,
        walkingService: WalkingServiceProtocol,
        educationService: EducationServiceProtocol
    ) {
        self.programService = programService
        self.sessionService = sessionService
        self.walkingService = walkingService
        self.educationService = educationService
    }
    
    // MARK: - Computed Properties
    var walkingProgress: Double {
        guard walkingTargetMinutes > 0 else { return 0 }
        return min(Double(todayWalkingMinutes) / Double(walkingTargetMinutes), 1.0)
    }
    
    var hasCompletedTodaySession: Bool {
        return todaySession == nil // If no session exists, it means it's completed
    }
    
    var isPlanPaused: Bool {
        return activePlan?.isPaused ?? false
    }
    
    var pausedReason: String? {
        return activePlan?.pausedReason
    }
    
    var nextSessionDate: Date? {
        return activePlan?.nextSessionDate
    }
    
    var currentPhaseDisplay: String {
        guard let plan = activePlan else { return "No Plan" }
        return "Phase \(plan.currentPhaseId.suffix(1)) • Week \(plan.currentWeek)"
    }
    
    // MARK: - Actions
    func loadData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Load all data concurrently
            async let planTask = programService.fetchActivePlan()
            async let sessionTask = sessionService.fetchTodaySession()
            async let walkingTask = walkingService.fetchTodayTotal()
            async let educationTask = educationService.fetchRandomCard()
            
            activePlan = try await planTask
            todaySession = try await sessionTask
            todayWalkingMinutes = try await walkingTask
            randomEducationCard = try await educationTask
            
            logger.info("Loaded today view data successfully")
        } catch let error as ProgramServiceError {
            logger.error("Program service error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch let error as SessionServiceError {
            logger.error("Session service error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch let error as WalkingServiceError {
            logger.error("Walking service error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch let error as EducationServiceError {
            logger.error("Education service error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            errorMessage = "An unexpected error occurred"
        }
    }
    
    func refreshData() async {
        await loadData()
    }
}
