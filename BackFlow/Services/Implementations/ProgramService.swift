import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "ProgramService")

@MainActor
final class ProgramService: ProgramServiceProtocol {
    static let shared = ProgramService()
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext? = nil) {
        // Use provided context or get from app's model container
        if let context = modelContext {
            self.modelContext = context
        } else {
            // Fallback: This will be injected properly via environment
            fatalError("ModelContext must be provided via dependency injection")
        }
    }
    
    // MARK: - Protocol Methods
    
    func fetchActivePlan() async throws(ProgramServiceError) -> ProgramPlan? {
        let descriptor = FetchDescriptor<ProgramPlan>(
            predicate: #Predicate { !$0.isPaused }
        )
        
        do {
            let plans = try modelContext.fetch(descriptor)
            return plans.first
        } catch {
            logger.error("Failed to fetch active plan: \(error.localizedDescription)")
            throw .fetchFailed(underlying: error)
        }
    }
    
    func createPlan(
        from templateId: String,
        baselinePain: Int,
        sessionDaysPerWeek: Int
    ) async throws(ProgramServiceError) -> ProgramPlan {
        // Determine starting phase based on baseline irritability
        let startingPhaseId: String
        if baselinePain >= 7 {
            startingPhaseId = "phase-0" // High irritability → gentle phase
        } else {
            startingPhaseId = "phase-1" // Moderate → standard start
        }
        
        // Generate weekday schedule (e.g., Mon/Wed/Fri for 3x/week)
        let weekdays = generateWeekdaySchedule(sessionsPerWeek: sessionDaysPerWeek)
        
        let plan = ProgramPlan(
            programId: templateId,
            startDate: Date(),
            currentPhaseId: startingPhaseId,
            currentWeek: 1,
            activityLadderLevel: 0,
            weekdays: weekdays,
            nextSessionDate: calculateNextSessionDate(weekdays: weekdays)
        )
        
        modelContext.insert(plan)
        
        do {
            try modelContext.save()
            logger.info("Created new program plan: \(plan.id)")
            return plan
        } catch {
            logger.error("Failed to save plan: \(error.localizedDescription)")
            throw .saveFailed(underlying: error)
        }
    }
    
    func updatePlan(_ plan: ProgramPlan) async throws(ProgramServiceError) {
        do {
            try modelContext.save()
            logger.info("Updated plan: \(plan.id)")
        } catch {
            logger.error("Failed to update plan: \(error.localizedDescription)")
            throw .saveFailed(underlying: error)
        }
    }
    
    func pausePlan(_ plan: ProgramPlan, reason: String) async throws(ProgramServiceError) {
        plan.isPaused = true
        plan.pausedReason = reason
        
        do {
            try modelContext.save()
            logger.info("Paused plan: \(plan.id)")
        } catch {
            logger.error("Failed to pause plan: \(error.localizedDescription)")
            throw .saveFailed(underlying: error)
        }
    }
    
    func resumePlan(_ plan: ProgramPlan) async throws(ProgramServiceError) {
        plan.isPaused = false
        plan.pausedReason = nil
        
        do {
            try modelContext.save()
            logger.info("Resumed plan: \(plan.id)")
        } catch {
            logger.error("Failed to resume plan: \(error.localizedDescription)")
            throw .saveFailed(underlying: error)
        }
    }
    
    // MARK: - Private Helpers
    
    private func generateWeekdaySchedule(sessionsPerWeek: Int) -> [Int] {
        // Simple strategy: evenly distribute across week
        // 3x/week → [1, 3, 5] (Mon, Wed, Fri)
        // 4x/week → [1, 2, 4, 5] (Mon, Tue, Thu, Fri)
        switch sessionsPerWeek {
        case 3: return [1, 3, 5]
        case 4: return [1, 2, 4, 5]
        case 5: return [1, 2, 3, 4, 5]
        default: return [1, 3, 5] // Default to 3x
        }
    }
    
    private func calculateNextSessionDate(weekdays: [Int]) -> Date {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date()) - 1 // 0-indexed
        
        // Find next scheduled weekday
        let sortedWeekdays = weekdays.sorted()
        var nextWeekday = sortedWeekdays.first(where: { $0 > today })
        
        // If none found this week, take first day of next week
        if nextWeekday == nil {
            nextWeekday = sortedWeekdays.first
        }
        
        guard let targetWeekday = nextWeekday else {
            return Date() // Fallback
        }
        
        var components = DateComponents()
        components.weekday = targetWeekday + 1 // Convert back to 1-indexed
        
        return calendar.nextDate(
            after: Date(),
            matching: components,
            matchingPolicy: .nextTime
        ) ?? Date()
    }
}
