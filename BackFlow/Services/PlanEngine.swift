import Foundation
import SwiftData

@MainActor
class PlanEngine {
    static let shared = PlanEngine()
    
    private init() {}
    
    /// Creates a new plan from template based on baseline assessment
    func createPlan(
        from templateId: String,
        baselinePain: Int,
        sessionDaysPerWeek: Int,
        modelContext: ModelContext
    ) -> ProgramPlan {
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
        
        return plan
    }
    
    /// Check 24-hour response and determine next action
    func evaluate24HourResponse(
        session: Session,
        nextDayPain: Int?,
        painThreshold: Int,
        plan: ProgramPlan,
        modelContext: ModelContext
    ) -> ProgressionDecision {
        // Check for red flags first
        if let symptomLog = session.symptomLog, symptomLog.hasRedFlags {
            return .pausePlan(reason: "Red flags detected. Please seek medical care.")
        }
        
        // Check next-day pain
        if let nextDayPain = nextDayPain, nextDayPain > painThreshold {
            return .regress(reason: "Next-day pain elevated (>\(painThreshold)). Reducing volume.")
        }
        
        // Check post-session pain
        if let painAfter = session.painAfterSession, painAfter > painThreshold {
            return .repeat(reason: "Post-session pain elevated. Repeating with reduced volume.")
        }
        
        // If stable response, progress
        return .progress(reason: "Good response. Progressing.")
    }
    
    /// Calculate next session date based on weekday schedule
    func calculateNextSessionDate(weekdays: [Int]) -> Date {
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
            // Fallback to tomorrow
            return calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        }
        
        // Calculate days until target
        var daysToAdd = targetWeekday - today
        if daysToAdd <= 0 {
            daysToAdd += 7
        }
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date()
    }
    
    private func generateWeekdaySchedule(sessionsPerWeek: Int) -> [Int] {
        // Simple distribution: spread sessions evenly across the week
        // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
        switch sessionsPerWeek {
        case 2: return [1, 4] // Mon, Thu
        case 3: return [1, 3, 5] // Mon, Wed, Fri
        case 4: return [1, 3, 4, 6] // Mon, Wed, Thu, Sat
        case 5: return [1, 2, 3, 5, 6] // Mon-Sat minus Thu
        case 6: return [1, 2, 3, 4, 5, 6] // Mon-Sat
        default: return [1, 3, 5] // Default to 3x/week
        }
    }
}

// ProgressionDecision moved to Models/Enums/ProgressionDecision.swift
