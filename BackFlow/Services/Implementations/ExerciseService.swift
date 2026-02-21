import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "ExerciseService")

@MainActor
final class ExerciseService: ExerciseServiceProtocol {
    static let shared = ExerciseService()
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext? = nil) {
        if let context = modelContext {
            self.modelContext = context
        } else {
            fatalError("ModelContext must be provided via dependency injection")
        }
    }
    
    // MARK: - Protocol Methods
    
    func fetchAllExercises() async throws(ExerciseServiceError) -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch exercises: \(error.localizedDescription)")
            throw .fetchFailed(underlying: error)
        }
    }
    
    func fetchExercise(slug: String) async throws(ExerciseServiceError) -> Exercise? {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.slug == slug }
        )
        
        do {
            let exercises = try modelContext.fetch(descriptor)
            return exercises.first
        } catch {
            logger.error("Failed to fetch exercise \(slug): \(error.localizedDescription)")
            throw .fetchFailed(underlying: error)
        }
    }
    
    func fetchExercises(bySlugs slugs: [String]) async throws(ExerciseServiceError) -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { exercise in
                slugs.contains(exercise.slug)
            }
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch exercises by slugs: \(error.localizedDescription)")
            throw .fetchFailed(underlying: error)
        }
    }
}
