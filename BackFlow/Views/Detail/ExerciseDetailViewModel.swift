import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "ExerciseDetailViewModel")

@MainActor @Observable
final class ExerciseDetailViewModel {
    // MARK: - Published State
    private(set) var exercise: Exercise?
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let exerciseService: ExerciseServiceProtocol
    
    // MARK: - Initialization
    init(exerciseService: ExerciseServiceProtocol) {
        self.exerciseService = exerciseService
    }
    
    // MARK: - Actions
    func loadExercise(slug: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            exercise = try await exerciseService.fetchExercise(slug: slug)
            if exercise == nil {
                errorMessage = "Exercise not found"
            }
        } catch let error as ExerciseServiceError {
            logger.error("Failed to load exercise: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            errorMessage = "Failed to load exercise"
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}