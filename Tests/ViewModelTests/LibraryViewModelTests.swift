import XCTest
@testable import BackFlow

@MainActor
final class LibraryViewModelTests: XCTestCase {
    
    // MARK: - Mock Services
    
    private final class MockExerciseService: ExerciseServiceProtocol {
        var stubbedExercises: [Exercise] = []
        var shouldThrowError = false
        
        func fetchAllExercises() async throws(ExerciseServiceError) -> [Exercise] {
            guard !shouldThrowError else { throw .fetchFailed(underlying: TestError.mock) }
            return stubbedExercises
        }
        
        func fetchExercise(slug: String) async throws(ExerciseServiceError) -> Exercise? {
            return stubbedExercises.first { $0.slug == slug }
        }
        
        func fetchExercises(bySlugs slugs: [String]) async throws(ExerciseServiceError) -> [Exercise] {
            return stubbedExercises.filter { slugs.contains($0.slug) }
        }
    }
    
    // MARK: - Tests
    
    func test_loadData_populatesExercisesAndCards() async {
        // Arrange
        let mockExercises = MockExerciseService()
        mockExercises.stubbedExercises = [
            createTestExercise(slug: "cat-cow", name: "Cat-Cow", category: "mobility"),
            createTestExercise(slug: "bird-dog", name: "Bird Dog", category: "stability")
        ]
        
        let mockEducation = MockEducationService()
        mockEducation.stubbedCard = createTestEducationCard()
        
        let viewModel = LibraryViewModel(
            exerciseService: mockExercises,
            educationService: mockEducation
        )
        
        // Act
        await viewModel.loadData()
        
        // Assert
        XCTAssertEqual(viewModel.exercises.count, 2)
        XCTAssertEqual(viewModel.educationCards.count, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func test_filteredExercises_filtersCorrectly() async {
        // Arrange
        let mockExercises = MockExerciseService()
        mockExercises.stubbedExercises = [
            createTestExercise(slug: "cat-cow", name: "Cat-Cow", category: "mobility"),
            createTestExercise(slug: "bird-dog", name: "Bird Dog", category: "stability"),
            createTestExercise(slug: "dead-bug", name: "Dead Bug", category: "stability")
        ]
        
        let viewModel = LibraryViewModel(
            exerciseService: mockExercises,
            educationService: MockEducationService()
        )
        
        await viewModel.loadData()
        
        // Act & Assert - No filter
        XCTAssertEqual(viewModel.filteredExercises.count, 3)
        
        // Act & Assert - Filter by name
        viewModel.searchText = "bug"
        XCTAssertEqual(viewModel.filteredExercises.count, 2) // Bird Dog and Dead Bug
        
        // Act & Assert - Filter by category
        viewModel.searchText = "mobility"
        XCTAssertEqual(viewModel.filteredExercises.count, 1) // Cat-Cow
    }
    
    func test_groupedExercises_groupsByCategory() async {
        // Arrange
        let mockExercises = MockExerciseService()
        mockExercises.stubbedExercises = [
            createTestExercise(slug: "cat-cow", name: "Cat-Cow", category: "mobility"),
            createTestExercise(slug: "bird-dog", name: "Bird Dog", category: "stability"),
            createTestExercise(slug: "dead-bug", name: "Dead Bug", category: "stability")
        ]
        
        let viewModel = LibraryViewModel(
            exerciseService: mockExercises,
            educationService: MockEducationService()
        )
        
        // Act
        await viewModel.loadData()
        let grouped = viewModel.groupedExercises
        
        // Assert
        XCTAssertEqual(grouped.count, 2) // mobility and stability
        XCTAssertEqual(grouped[0].0, "mobility")
        XCTAssertEqual(grouped[0].1.count, 1)
        XCTAssertEqual(grouped[1].0, "stability")
        XCTAssertEqual(grouped[1].1.count, 2)
    }
    
    func test_selectedTab_switchesBetweenExercisesAndEducation() {
        // Arrange
        let viewModel = LibraryViewModel(
            exerciseService: MockExerciseService(),
            educationService: MockEducationService()
        )
        
        // Assert default
        XCTAssertEqual(viewModel.selectedTab, .exercises)
        
        // Act & Assert
        viewModel.selectedTab = .education
        XCTAssertEqual(viewModel.selectedTab, .education)
    }
    
    // MARK: - Helpers
    
    private func createTestExercise(slug: String, name: String, category: String) -> Exercise {
        return Exercise(
            slug: slug,
            name: name,
            category: category,
            regions: ["lumbar"],
            equipment: ["none"],
            difficulty: "beginner",
            setsDefault: 2,
            primaryCues: [],
            commonMistakes: [],
            progressions: [],
            regressions: [],
            dosageNotes: "",
            rangeOfMotionNotes: "",
            evidenceRefs: [],
            illustrationAssetName: ""
        )
    }
    
    private func createTestEducationCard() -> EducationCard {
        return EducationCard(
            cardId: "test-card",
            title: "Test Education",
            summary: "Test summary",
            detailMarkdown: "Test content",
            refs: []
        )
    }
}

// Reuse MockEducationService from TodayViewModelTests
private final class MockEducationService: EducationServiceProtocol {
    var stubbedCard: EducationCard?
    var shouldThrowError = false
    
    func fetchAllCards() async throws(EducationServiceError) -> [EducationCard] {
        guard !shouldThrowError else { throw .fetchFailed(underlying: TestError.mock) }
        return stubbedCard.map { [$0] } ?? []
    }
    
    func fetchCard(id: String) async throws(EducationServiceError) -> EducationCard? {
        return stubbedCard
    }
    
    func fetchRandomCard() async throws(EducationServiceError) -> EducationCard? {
        return stubbedCard
    }
}

private enum TestError: Error {
    case mock
}