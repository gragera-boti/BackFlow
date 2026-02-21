import Foundation

// MARK: - Service Error

enum ProgramServiceError: Error, LocalizedError {
    case notFound
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Program not found"
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid data"
        }
    }
}

// MARK: - Protocol

protocol ProgramServiceProtocol {
    func fetchActivePlan() async throws(ProgramServiceError) -> ProgramPlan?
    func createPlan(
        from templateId: String,
        baselinePain: Int,
        sessionDaysPerWeek: Int
    ) async throws(ProgramServiceError) -> ProgramPlan
    func updatePlan(_ plan: ProgramPlan) async throws(ProgramServiceError)
    func pausePlan(_ plan: ProgramPlan, reason: String) async throws(ProgramServiceError)
    func resumePlan(_ plan: ProgramPlan) async throws(ProgramServiceError)
}
