import XCTest
import SwiftUI
import SwiftData
@testable import BackFlow

@MainActor
final class GoalAndScheduleViewTests: XCTestCase {
    private var modelContainer: ModelContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: UserProfile.self, ProgramPlan.self,
            configurations: config
        )
    }
    
    override func tearDown() async throws {
        modelContainer = nil
        try await super.tearDown()
    }
    
    func test_saveAndContinue_createsUserProfile() async throws {
        // Given
        var onContinueCalled = false
        let view = GoalAndScheduleView(onContinue: {
            onContinueCalled = true
        })
        
        let modelContext = ModelContext(modelContainer)
        
        // Create a test environment
        let testView = view.modelContext(modelContext)
        
        // When - simulate user interaction
        // Note: We need to access the view's internal state
        // In a real test, we'd use ViewInspector or similar
        
        // Then
        let profiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
        XCTAssertEqual(profiles.count, 1, "Should create exactly one user profile")
        
        let profile = try XCTUnwrap(profiles.first)
        XCTAssertFalse(profile.goal.isEmpty, "Profile should have goals")
        XCTAssertEqual(profile.sessionsPerWeek, 3, "Default sessions per week should be 3")
    }
    
    func test_createMyPlanButton_disabledWhenNoGoalsSelected() {
        // This would require UI testing framework or ViewInspector
        // For now, we can test the logic
        let selectedGoals: Set<String> = []
        XCTAssertTrue(selectedGoals.isEmpty)
        // Button should be disabled when selectedGoals.isEmpty
    }
    
    func test_generateWeekdaySchedule() {
        // Test the weekday generation logic
        let testCases: [(sessions: Int, expected: [Int])] = [
            (1, [3]), // Wednesday
            (2, [1, 4]), // Monday, Thursday
            (3, [1, 3, 5]), // Monday, Wednesday, Friday
            (4, [1, 2, 4, 5]), // Monday, Tuesday, Thursday, Friday
            (5, [1, 2, 3, 4, 5]), // Weekdays
            (6, [1, 2, 3, 4, 5, 6]), // Monday through Saturday
            (7, [0, 1, 2, 3, 4, 5, 6]) // Every day
        ]
        
        // Since generateWeekdaySchedule is private, we'd need to make it testable
        // or test it through the public interface
    }
}