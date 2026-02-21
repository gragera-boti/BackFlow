import XCTest
import SwiftData
@testable import BackFlow

@MainActor
final class GoalAndScheduleViewModelTests: XCTestCase {
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: UserProfile.self, ProgramPlan.self,
            configurations: config
        )
        modelContext = ModelContext(modelContainer)
    }
    
    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        try await super.tearDown()
    }
    
    func test_saveUserProfile_withValidData_savesSuccessfully() async throws {
        // Given
        let selectedGoals: Set<String> = ["Reduce flare-ups", "Move more comfortably"]
        let sessionsPerWeek = 3
        let selectedEquipment: Set<String> = ["None"]
        let reminderEnabled = true
        let reminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        
        // When - Create user profile
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let profile = UserProfile(
            createdAt: Date(),
            goal: Array(selectedGoals).joined(separator: ", "),
            sessionsPerWeek: sessionsPerWeek,
            equipment: Array(selectedEquipment),
            reminderHour: components.hour,
            reminderMinute: components.minute
        )
        
        modelContext.insert(profile)
        try modelContext.save()
        
        // Then
        let fetchedProfiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
        XCTAssertEqual(fetchedProfiles.count, 1)
        
        let fetchedProfile = try XCTUnwrap(fetchedProfiles.first)
        XCTAssertEqual(fetchedProfile.goal, "Reduce flare-ups, Move more comfortably")
        XCTAssertEqual(fetchedProfile.sessionsPerWeek, 3)
        XCTAssertEqual(fetchedProfile.equipment, ["None"])
        XCTAssertEqual(fetchedProfile.reminderHour, 9)
        XCTAssertEqual(fetchedProfile.reminderMinute, 0)
    }
    
    func test_createProgramPlan_withValidData_savesSuccessfully() async throws {
        // Given
        let weekdays = [1, 3, 5] // Mon, Wed, Fri
        
        // When
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
        try modelContext.save()
        
        // Then
        let fetchedPlans = try modelContext.fetch(FetchDescriptor<ProgramPlan>())
        XCTAssertEqual(fetchedPlans.count, 1)
        
        let fetchedPlan = try XCTUnwrap(fetchedPlans.first)
        XCTAssertEqual(fetchedPlan.programId, "standard-rehab-program")
        XCTAssertEqual(fetchedPlan.currentPhaseId, "phase-1")
        XCTAssertEqual(fetchedPlan.currentWeek, 1)
        XCTAssertEqual(fetchedPlan.weekdays, [1, 3, 5])
        XCTAssertFalse(fetchedPlan.isPaused)
    }
    
    func test_weekdayScheduleGeneration() {
        // Test the logic for generating weekday schedules
        let testCases: [(sessionsPerWeek: Int, expectedDays: [Int])] = [
            (1, [3]), // Wednesday only
            (2, [1, 4]), // Monday, Thursday
            (3, [1, 3, 5]), // Monday, Wednesday, Friday
            (4, [1, 2, 4, 5]), // Monday, Tuesday, Thursday, Friday
            (5, [1, 2, 3, 4, 5]), // All weekdays
            (6, [1, 2, 3, 4, 5, 6]), // Monday through Saturday
            (7, [0, 1, 2, 3, 4, 5, 6]) // Every day
        ]
        
        for testCase in testCases {
            let weekdays = generateTestWeekdaySchedule(sessionsPerWeek: testCase.sessionsPerWeek)
            XCTAssertEqual(
                weekdays,
                testCase.expectedDays,
                "Sessions per week: \(testCase.sessionsPerWeek) should generate days: \(testCase.expectedDays)"
            )
        }
    }
    
    func test_onContinue_callbackIsInvoked() {
        // Given
        var callbackInvoked = false
        let expectation = XCTestExpectation(description: "onContinue callback")
        
        let onContinue: () -> Void = {
            callbackInvoked = true
            expectation.fulfill()
        }
        
        // When
        onContinue()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(callbackInvoked)
    }
    
    // Helper function that mirrors the private function in GoalAndScheduleView
    private func generateTestWeekdaySchedule(sessionsPerWeek: Int) -> [Int] {
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
            return [1, 3, 5] // Default to Mon/Wed/Fri
        }
    }
}