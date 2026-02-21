import Foundation

// MARK: - Service Error

enum ExerciseServiceError: Error, LocalizedError {
    case notFound
    case fetchFailed(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Exercise not found"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        }
    }
}

// MARK: - Protocol

protocol ExerciseServiceProtocol {
    func fetchAllExercises() async throws(ExerciseServiceError) -> [Exercise]
    func fetchExercise(slug: String) async throws(ExerciseServiceError) -> Exercise?
    func fetchExercises(bySlugs slugs: [String]) async throws(ExerciseServiceError) -> [Exercise]
}
