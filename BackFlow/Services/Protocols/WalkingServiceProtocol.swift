import Foundation

// MARK: - Service Error

enum WalkingServiceError: Error, LocalizedError {
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        }
    }
}

// MARK: - Protocol

protocol WalkingServiceProtocol {
    func fetchTodayTotal() async throws(WalkingServiceError) -> Int
    func fetchLogs(from startDate: Date, to endDate: Date) async throws(WalkingServiceError) -> [WalkingLog]
    func logWalking(durationMinutes: Int, source: String, notes: String?) async throws(WalkingServiceError) -> WalkingLog
}
