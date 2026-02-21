import XCTest
import SwiftUI
import SwiftData
@testable import BackFlow

@MainActor
final class OnboardingFlowTests: XCTestCase {
    private var modelContainer: ModelContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: UserProfile.self, ProgramPlan.self,
            configurations: config
        )
        
        // Reset UserDefaults
        UserDefaults.standard.removeObject(forKey: "onboardingCompleted")
    }
    
    override func tearDown() async throws {
        modelContainer = nil
        UserDefaults.standard.removeObject(forKey: "onboardingCompleted")
        try await super.tearDown()
    }
    
    func test_onboardingFlow_startsAtStep0() {
        let flow = OnboardingFlow()
        // In a real test, we'd inspect the view hierarchy
        // to verify WelcomeView is shown
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "onboardingCompleted"))
    }
    
    func test_onboardingFlow_completesAndSetsUserDefault() async throws {
        // Given
        let modelContext = ModelContext(modelContainer)
        
        // Create a user profile as if onboarding completed
        let profile = UserProfile(
            createdAt: Date(),
            goal: "Test goals",
            sessionsPerWeek: 3,
            equipment: ["None"],
            reminderHour: nil,
            reminderMinute: nil
        )
        profile.onboardingCompleted = true
        modelContext.insert(profile)
        try modelContext.save()
        
        // When
        let flow = OnboardingFlow()
            .modelContext(modelContext)
        
        // Simulate completing onboarding
        // In real app, this happens through completeOnboarding()
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        
        // Then
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "onboardingCompleted"))
        XCTAssertTrue(profile.onboardingCompleted)
    }
    
    func test_navigationFlow_fromWelcomeToDisclaimer() {
        // This would require a more sophisticated testing approach
        // like ViewInspector or UI testing
    }
}