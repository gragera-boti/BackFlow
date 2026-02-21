import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "SessionService")

@MainActor
final class SessionService: SessionServiceProtocol {
    static let shared = SessionService()
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext? = nil) {
        if let context = modelContext {
            self.modelContext = context
        } else {
            fatalError("ModelContext must be provided via dependency injection")
        }
    }
    
    // MARK: - Protocol Methods
    
    func fetchTodaySession() async throws(SessionServiceError) -> Session? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<Session>(
            predicate: #Predicate { session in
                session.date >= startOfDay && session.date < endOfDay && !session.completed
            }
        )
        
        do {
            let sessions = try modelContext.fetch(descriptor)
            return sessions.first
        } catch {
            logger.error("Failed to fetch today's session: \(error.localizedDescription)")
            throw .fetchFailed(underlying: error)
        }
    }
    
    func fetchRecentSessions(limit: Int) async throws(SessionServiceError) -> [Session] {
        var descriptor = FetchDescriptor<Session>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch recent sessions: \(error.localizedDescription)")
            throw .fetchFailed(underlying: error)
        }
    }
    
    func createSession(
        templateId: String,
        phaseId: String
    ) async throws(SessionServiceError) -> Session {
        let session = Session(
            date: Date(),
            templateId: templateId,
            phaseId: phaseId
        )
        
        modelContext.insert(session)
        
        do {
            try modelContext.save()
            logger.info("Created new session: \(session.id)")
            return session
        } catch {
            logger.error("Failed to create session: \(error.localizedDescription)")
            throw .saveFailed(underlying: error)
        }
    }
    
    func updateSession(_ session: Session) async throws(SessionServiceError) {
        do {
            try modelContext.save()
            logger.info("Updated session: \(session.id)")
        } catch {
            logger.error("Failed to update session: \(error.localizedDescription)")
            throw .saveFailed(underlying: error)
        }
    }
    
    func completeSession(_ session: Session, painAfter: Int?) async throws(SessionServiceError) {
        session.completed = true
        session.painAfterSession = painAfter
        
        do {
            try modelContext.save()
            logger.info("Completed session: \(session.id)")
        } catch {
            logger.error("Failed to complete session: \(error.localizedDescription)")
            throw .saveFailed(underlying: error)
        }
    }
    
    func logSetData(_ session: Session, setLog: SetLog) async throws(SessionServiceError) {
        session.setLogs.append(setLog)
        
        do {
            try modelContext.save()
            logger.info("Logged set data for session: \(session.id)")
        } catch {
            logger.error("Failed to log set data: \(error.localizedDescription)")
            throw .saveFailed(underlying: error)
        }
    }
}
