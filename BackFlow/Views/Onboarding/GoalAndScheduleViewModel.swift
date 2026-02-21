import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "com.backflow.app", category: "GoalAndScheduleViewModel")

// MARK: - ViewModel

@MainActor @Observable
final class GoalAndScheduleViewModel {
    // MARK: - Published State
    var selectedGoals: Set<String> = []
    var sessionsPerWeek: Int = 3
    var selectedEquipment: Set<String> = []
    var reminderEnabled: Bool = true
    var reminderTime: Date = Date()
    
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Constants
    let availableGoals = [
        "Reduce flare-ups",
        "Move more comfortably",
        "Return to gym/sports",
        "Build daily strength"
    ]
    
    let availableEquipment = [
        "None",
        "Resistance band",
        "Weights"
    ]
    
    // MARK: - Dependencies
    private let modelContext: ModelContext
    private let notificationService: NotificationService
    
    // MARK: - Initialization
    init(
        modelContext: ModelContext,
        notificationService: NotificationService = .shared
    ) {
        self.modelContext = modelContext
        self.notificationService = notificationService
    }
    
    // MARK: - Computed Properties
    var canContinue: Bool {
        !selectedGoals.isEmpty
    }
    
    var goalsText: String {
        Array(selectedGoals).joined(separator: ", ")
    }
    
    var equipmentArray: [String] {
        Array(selectedEquipment)
    }
    
    // MARK: - Actions
    func toggleGoal(_ goal: String) {
        if selectedGoals.contains(goal) {
            selectedGoals.remove(goal)
        } else {
            selectedGoals.insert(goal)
        }
        logger.debug("Toggled goal: \(goal), current selection: \(self.selectedGoals.count) goals")
    }
    
    func toggleEquipment(_ item: String) {
        if selectedEquipment.contains(item) {
            selectedEquipment.remove(item)
        } else {
            selectedEquipment.insert(item)
        }
        logger.debug("Toggled equipment: \(item)")
    }
    
    func saveProfile() async -> Bool {
        logger.info("Starting profile save")
        
        guard canContinue else {
            logger.warning("Attempted to save with no goals selected")
            errorMessage = "Please select at least one goal"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Create user profile
            let reminderComponents = reminderEnabled
                ? Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                : nil
            
            let profile = UserProfile(
                createdAt: Date(),
                goal: goalsText,
                sessionsPerWeek: sessionsPerWeek,
                equipment: equipmentArray,
                reminderHour: reminderComponents?.hour,
                reminderMinute: reminderComponents?.minute
            )
            
            modelContext.insert(profile)
            logger.debug("UserProfile created and inserted")
            
            // Create initial program plan
            let weekdays = generateWeekdaySchedule(sessionsPerWeek: sessionsPerWeek)
            let programPlan = ProgramPlan(
                programId: "standard-rehab-program",
                startDate: Date(),
                currentPhaseId: "phase-1",
                currentWeek: 1,
                activityLadderLevel: 0,
                isPaused: false,
                weekdays: weekdays
            )
            
            modelContext.insert(programPlan)
            logger.debug("ProgramPlan created and inserted")
            
            // Save to SwiftData
            try modelContext.save()
            logger.info("✅ Profile and program plan saved successfully")
            
            // Schedule reminder if enabled
            if reminderEnabled, let components = reminderComponents {
                notificationService.scheduleDailyReminder(at: components)
                logger.info("Daily reminder scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
            }
            
            // Small delay to ensure SwiftData has synced
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            return true
            
        } catch {
            logger.error("Failed to save profile: \(error.localizedDescription)")
            errorMessage = "Failed to save your profile. Please try again."
            return false
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Helpers
    private func generateWeekdaySchedule(sessionsPerWeek: Int) -> [Int] {
        // Evenly distribute sessions across the week
        // 0 = Sunday, 1 = Monday, etc.
        switch sessionsPerWeek {
        case 1:
            return [3] // Wednesday
        case 2:
            return [1, 4] // Monday, Thursday
        case 3:
            return [1, 3, 5] // Monday, Wednesday, Friday
        case 4:
            return [1, 2, 4, 5] // Monday, Tuesday, Thursday, Friday
        case 5:
            return [1, 2, 3, 4, 5] // Weekdays
        case 6:
            return [1, 2, 3, 4, 5, 6] // Monday through Saturday
        case 7:
            return [0, 1, 2, 3, 4, 5, 6] // Every day
        default:
            logger.warning("Invalid sessionsPerWeek: \(sessionsPerWeek), defaulting to 3")
            return [1, 3, 5] // Default to Mon/Wed/Fri
        }
    }
}
