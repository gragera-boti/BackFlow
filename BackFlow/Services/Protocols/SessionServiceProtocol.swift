import Foundation

// MARK: - Service Error

enum SessionServiceError: Error, LocalizedError {
    case notFound
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case invalidSession
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Session not found"
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        case .invalidSession:
            return "Invalid session data"
        }
    }
}

// MARK: - Protocol

protocol SessionServiceProtocol {
    func fetchTodaySession() async throws(SessionServiceError) -> Session?
    func fetchRecentSessions(limit: Int) async throws(SessionServiceError) -> [Session]
    func createSession(
        templateId: String,
        phaseId: String
    ) async throws(SessionServiceError) -> Session
    func updateSession(_ session: Session) async throws(SessionServiceError)
    func completeSession(_ session: Session, painAfter: Int?) async throws(SessionServiceError)
    func logSetData(_ session: Session, setLog: SetLog) async throws(SessionServiceError)
}
