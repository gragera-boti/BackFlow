import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "SessionPlayerViewModel")

@MainActor @Observable
final class SessionPlayerViewModel {
    // MARK: - Published State
    private(set) var session: Session?
    private(set) var exercises: [Exercise] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let sessionService: SessionServiceProtocol
    private let exerciseService: ExerciseServiceProtocol
    
    // MARK: - Initialization
    init(
        sessionService: SessionServiceProtocol,
        exerciseService: ExerciseServiceProtocol
    ) {
        self.sessionService = sessionService
        self.exerciseService = exerciseService
    }
    
    // MARK: - Actions
    func loadSession(id: UUID) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // For now, create a new session since we don't have a fetch by ID method
            // In a real app, we'd have a method to fetch existing sessions
            session = try await sessionService.createSession(
                templateId: "standard-session",
                phaseId: "phase-1"
            )
            
            // Load exercises for this session
            // This is placeholder - in a real app we'd load based on the session template
            exercises = try await exerciseService.fetchAllExercises()
            
        } catch let error as SessionServiceError {
            logger.error("Failed to load session: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch let error as ExerciseServiceError {
            logger.error("Failed to load exercises: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            errorMessage = "Failed to load session"
        }
    }
    
    func completeSession(painAfter: Int?) async {
        guard let session = session else { return }
        
        do {
            try await sessionService.completeSession(session, painAfter: painAfter)
        } catch {
            logger.error("Failed to complete session: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}