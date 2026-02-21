import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "com.backflow.app", category: "BaselineAssessmentViewModel")

// MARK: - ViewModel

@MainActor @Observable
final class BaselineAssessmentViewModel {
    // MARK: - Published State
    var painNow: Int = 5
    var worstPainLast7Days: Int = 7
    var walkingMinutes: Int = 10
    var functionTasks: [FunctionTask] = [
        FunctionTask(name: "Sit for 30 minutes", difficulty: 5),
        FunctionTask(name: "Bend to pick up object", difficulty: 5),
        FunctionTask(name: "Walk for 20 minutes", difficulty: 5)
    ]
    
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let programService: any ProgramServiceProtocol
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    init(
        programService: some ProgramServiceProtocol,
        modelContext: ModelContext
    ) {
        self.programService = programService
        self.modelContext = modelContext
    }
    
    // MARK: - Computed Properties
    var averageFunctionDifficulty: Int {
        guard !functionTasks.isEmpty else { return 0 }
        let total = functionTasks.reduce(0) { $0 + $1.difficulty }
        return total / functionTasks.count
    }
    
    var functionScorePercentage: Double {
        let avgScore = averageFunctionDifficulty
        // Convert to 0-100 scale (inverse, because lower difficulty is better)
        return Double(10 - avgScore) * 10
    }
    
    var canComplete: Bool {
        // Add any validation logic here
        return true
    }
    
    // MARK: - Actions
    func completeAssessment() async -> Bool {
        logger.info("Starting baseline assessment completion")
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Fetch user profile
            let descriptor = FetchDescriptor<UserProfile>()
            guard let profiles = try? modelContext.fetch(descriptor),
                  let profile = profiles.first else {
                logger.error("No UserProfile found")
                throw BaselineAssessmentError.noProfileFound
            }
            
            // Create baseline symptom log
            let symptomLog = SymptomLog(
                timestamp: Date(),
                painNow: painNow,
                notes: "Baseline: worst pain last 7 days = \(worstPainLast7Days)"
            )
            modelContext.insert(symptomLog)
            logger.debug("Created baseline symptom log")
            
            // Create baseline function log
            let tasksJSON = encodeFunctionTasks()
            let functionLog = FunctionLog(
                date: Date(),
                tasksJSON: tasksJSON,
                overallScore: functionScorePercentage
            )
            modelContext.insert(functionLog)
            logger.debug("Created baseline function log")
            
            // Create walking baseline log
            let walkingLog = WalkingLog(
                date: Date(),
                durationMinutes: walkingMinutes,
                source: "manual",
                notes: "Baseline"
            )
            modelContext.insert(walkingLog)
            logger.debug("Created baseline walking log")
            
            // Create program plan
            let plan = try await programService.createPlan(
                from: "lbp-primary-10wk",
                baselinePain: worstPainLast7Days,
                sessionDaysPerWeek: profile.sessionsPerWeek
            )
            logger.info("Created program plan with ID: \(plan.id)")
            
            // Save all changes
            try modelContext.save()
            logger.info("✅ Successfully saved baseline assessment")
            
            return true
        } catch let error as BaselineAssessmentError {
            logger.error("Baseline assessment error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            return false
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            errorMessage = "An unexpected error occurred. Please try again."
            return false
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Helpers
    private func encodeFunctionTasks() -> String {
        guard let data = try? JSONEncoder().encode(functionTasks),
              let json = String(data: data, encoding: .utf8) else {
            logger.warning("Failed to encode function tasks, using empty array")
            return "[]"
        }
        return json
    }
}

// MARK: - Supporting Types

struct FunctionTask: Codable, Identifiable {
    let id = UUID()
    let name: String
    var difficulty: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case difficulty
    }
}

// MARK: - Errors

enum BaselineAssessmentError: LocalizedError {
    case noProfileFound
    case saveFailed(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .noProfileFound:
            return "User profile not found. Please restart onboarding."
        case .saveFailed(let error):
            return "Failed to save assessment: \(error.localizedDescription)"
        }
    }
}
