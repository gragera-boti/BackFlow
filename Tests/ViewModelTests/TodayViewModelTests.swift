import XCTest
@testable import BackFlow

@MainActor
final class TodayViewModelTests: XCTestCase {
    
    // MARK: - Mock Services
    
    private final class MockProgramService: ProgramServiceProtocol {
        var stubbedPlan: ProgramPlan?
        var shouldThrowError = false
        
        func fetchActivePlan() async throws(ProgramServiceError) -> ProgramPlan? {
            guard !shouldThrowError else { throw .fetchFailed(underlying: TestError.mock) }
            return stubbedPlan
        }
        
        func createPlan(from templateId: String, baselinePain: Int, sessionDaysPerWeek: Int) async throws(ProgramServiceError) -> ProgramPlan {
            fatalError("Not implemented")
        }
        
        func updatePlan(_ plan: ProgramPlan) async throws(ProgramServiceError) {
            fatalError("Not implemented")
        }
        
        func pausePlan(_ plan: ProgramPlan, reason: String) async throws(ProgramServiceError) {
            fatalError("Not implemented")
        }
        
        func resumePlan(_ plan: ProgramPlan) async throws(ProgramServiceError) {
            fatalError("Not implemented")
        }
    }
    
    private final class MockSessionService: SessionServiceProtocol {
        var stubbedSession: Session?
        var shouldThrowError = false
        
        func fetchTodaySession() async throws(SessionServiceError) -> Session? {
            guard !shouldThrowError else { throw .fetchFailed(underlying: TestError.mock) }
            return stubbedSession
        }
        
        func fetchRecentSessions(limit: Int) async throws(SessionServiceError) -> [Session] {
            return stubbedSession.map { [$0] } ?? []
        }
        
        func createSession(templateId: String, phaseId: String) async throws(SessionServiceError) -> Session {
            fatalError("Not implemented")
        }
        
        func updateSession(_ session: Session) async throws(SessionServiceError) {
            fatalError("Not implemented")
        }
        
        func completeSession(_ session: Session, painAfter: Int?) async throws(SessionServiceError) {
            fatalError("Not implemented")
        }
        
        func logSetData(_ session: Session, setLog: SetLog) async throws(SessionServiceError) {
            fatalError("Not implemented")
        }
    }
    
    private final class MockWalkingService: WalkingServiceProtocol {
        var stubbedTotalMinutes: Int = 0
        var shouldThrowError = false
        
        func fetchTodayTotal() async throws(WalkingServiceError) -> Int {
            guard !shouldThrowError else { throw .fetchFailed(underlying: TestError.mock) }
            return stubbedTotalMinutes
        }
        
        func fetchLogs(from startDate: Date, to endDate: Date) async throws(WalkingServiceError) -> [WalkingLog] {
            return []
        }
        
        func logWalking(durationMinutes: Int, source: String, notes: String?) async throws(WalkingServiceError) -> WalkingLog {
            fatalError("Not implemented")
        }
    }
    
    private final class MockEducationService: EducationServiceProtocol {
        var stubbedCard: EducationCard?
        var shouldThrowError = false
        
        func fetchAllCards() async throws(EducationServiceError) -> [EducationCard] {
            return stubbedCard.map { [$0] } ?? []
        }
        
        func fetchCard(id: String) async throws(EducationServiceError) -> EducationCard? {
            return stubbedCard
        }
        
        func fetchRandomCard() async throws(EducationServiceError) -> EducationCard? {
            guard !shouldThrowError else { throw .fetchFailed(underlying: TestError.mock) }
            return stubbedCard
        }
    }
    
    // MARK: - Tests
    
    func test_loadData_populatesStateCorrectly() async {
        // Arrange
        let mockProgram = MockProgramService()
        mockProgram.stubbedPlan = ProgramPlan(
            programId: "test",
            currentPhaseId: "phase-1",
            currentWeek: 2,
            activityLadderLevel: 1,
            weekdays: [1, 3, 5]
        )
        
        let mockSession = MockSessionService()
        mockSession.stubbedSession = Session(
            templateId: "test-template",
            phaseId: "phase-1"
        )
        
        let mockWalking = MockWalkingService()
        mockWalking.stubbedTotalMinutes = 15
        
        let mockEducation = MockEducationService()
        mockEducation.stubbedCard = EducationCard(
            cardId: "test-card",
            title: "Test Card",
            summary: "Test summary",
            detailMarkdown: "Test content",
            refs: []
        )
        
        let viewModel = TodayViewModel(
            programService: mockProgram,
            sessionService: mockSession,
            walkingService: mockWalking,
            educationService: mockEducation
        )
        
        // Act
        await viewModel.loadData()
        
        // Assert
        XCTAssertNotNil(viewModel.activePlan)
        XCTAssertNotNil(viewModel.todaySession)
        XCTAssertEqual(viewModel.todayWalkingMinutes, 15)
        XCTAssertNotNil(viewModel.randomEducationCard)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func test_loadData_handlesErrorsGracefully() async {
        // Arrange
        let mockProgram = MockProgramService()
        mockProgram.shouldThrowError = true
        
        let viewModel = TodayViewModel(
            programService: mockProgram,
            sessionService: MockSessionService(),
            walkingService: MockWalkingService(),
            educationService: MockEducationService()
        )
        
        // Act
        await viewModel.loadData()
        
        // Assert
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_walkingProgress_calculatesCorrectly() {
        // Arrange
        let viewModel = TodayViewModel(
            programService: MockProgramService(),
            sessionService: MockSessionService(),
            walkingService: MockWalkingService(),
            educationService: MockEducationService()
        )
        
        // Test zero progress
        XCTAssertEqual(viewModel.walkingProgress, 0.0)
        
        // Test partial progress
        viewModel.todayWalkingMinutes = 15
        XCTAssertEqual(viewModel.walkingProgress, 0.5)
        
        // Test full progress
        viewModel.todayWalkingMinutes = 30
        XCTAssertEqual(viewModel.walkingProgress, 1.0)
        
        // Test over 100%
        viewModel.todayWalkingMinutes = 45
        XCTAssertEqual(viewModel.walkingProgress, 1.0)
    }
    
    func test_clearError_removesErrorMessage() {
        // Arrange
        let viewModel = TodayViewModel(
            programService: MockProgramService(),
            sessionService: MockSessionService(),
            walkingService: MockWalkingService(),
            educationService: MockEducationService()
        )
        viewModel.errorMessage = "Test error"
        
        // Act
        viewModel.clearError()
        
        // Assert
        XCTAssertNil(viewModel.errorMessage)
    }
}

// MARK: - Test Error

private enum TestError: Error {
    case mock
}