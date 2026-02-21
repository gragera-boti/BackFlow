import Testing
import SwiftData
@testable import BackFlow

@Suite("Baseline Assessment ViewModel Tests")
struct BaselineAssessmentViewModelTests {
    
    @Test("Initial state is correct")
    @MainActor
    func testInitialState() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: UserProfile.self, configurations: config)
        let context = container.mainContext
        
        let mockService = MockProgramService()
        let viewModel = BaselineAssessmentViewModel(
            programService: mockService,
            modelContext: context
        )
        
        // Then
        #expect(viewModel.painNow == 5)
        #expect(viewModel.worstPainLast7Days == 7)
        #expect(viewModel.walkingMinutes == 10)
        #expect(viewModel.functionTasks.count == 3)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Average function difficulty is calculated correctly")
    @MainActor
    func testAverageFunctionDifficulty() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: UserProfile.self, configurations: config)
        let context = container.mainContext
        
        let mockService = MockProgramService()
        let viewModel = BaselineAssessmentViewModel(
            programService: mockService,
            modelContext: context
        )
        
        // When - all tasks set to difficulty 6
        for i in 0..<viewModel.functionTasks.count {
            viewModel.functionTasks[i].difficulty = 6
        }
        
        // Then
        #expect(viewModel.averageFunctionDifficulty == 6)
        #expect(viewModel.functionScorePercentage == 40.0) // (10 - 6) * 10
    }
}

// MARK: - Mocks

@MainActor
final class MockProgramService: ProgramServiceProtocol {
    var shouldFail = false
    var createdPlan: ProgramPlan?
    
    func fetchActivePlan() async throws(ProgramServiceError) -> ProgramPlan? {
        nil
    }
    
    func createPlan(from templateId: String, baselinePain: Int, sessionDaysPerWeek: Int) async throws(ProgramServiceError) -> ProgramPlan {
        if shouldFail {
            throw .invalidData
        }
        
        let plan = ProgramPlan(
            programId: templateId,
            startDate: Date(),
            currentPhaseId: "phase-1",
            currentWeek: 1,
            activityLadderLevel: 0,
            isPaused: false,
            weekdays: [1, 3, 5]
        )
        createdPlan = plan
        return plan
    }
    
    func updatePlan(_ plan: ProgramPlan) async throws(ProgramServiceError) {}
    func pausePlan(_ plan: ProgramPlan, reason: String) async throws(ProgramServiceError) {}
    func resumePlan(_ plan: ProgramPlan) async throws(ProgramServiceError) {}
}
