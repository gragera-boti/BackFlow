import Foundation
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "LibraryViewModel")

@MainActor @Observable
final class LibraryViewModel {
    // MARK: - Published State
    private(set) var exercises: [Exercise] = []
    private(set) var educationCards: [EducationCard] = []
    
    var selectedTab: LibraryTab = .exercises
    var searchText: String = ""
    
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let exerciseService: ExerciseServiceProtocol
    private let educationService: EducationServiceProtocol
    
    // MARK: - Initialization
    init(
        exerciseService: ExerciseServiceProtocol,
        educationService: EducationServiceProtocol
    ) {
        self.exerciseService = exerciseService
        self.educationService = educationService
    }
    
    // MARK: - Computed Properties
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(searchText) ||
            exercise.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var groupedExercises: [(String, [Exercise])] {
        Dictionary(grouping: filteredExercises, by: { $0.category })
            .sorted { $0.key < $1.key }
    }
    
    var filteredEducationCards: [EducationCard] {
        if searchText.isEmpty {
            return educationCards
        }
        return educationCards.filter { card in
            card.title.localizedCaseInsensitiveContains(searchText) ||
            card.summary.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Actions
    func loadData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Load both data sets concurrently
            async let exercisesTask = exerciseService.fetchAllExercises()
            async let cardsTask = educationService.fetchAllCards()
            
            exercises = try await exercisesTask
            educationCards = try await cardsTask
            
            logger.info("Loaded library data: \(self.exercises.count) exercises, \(self.educationCards.count) education cards")
        } catch let error as ExerciseServiceError {
            logger.error("Exercise service error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch let error as EducationServiceError {
            logger.error("Education service error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            errorMessage = "An unexpected error occurred"
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Supporting Types

enum LibraryTab: String, CaseIterable, Identifiable {
    case exercises = "Exercises"
    case education = "Education"
    
    var id: String { rawValue }
}