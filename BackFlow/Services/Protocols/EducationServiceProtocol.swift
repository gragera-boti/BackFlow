import Foundation

// MARK: - Service Error

enum EducationServiceError: Error, LocalizedError {
    case notFound
    case fetchFailed(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Education card not found"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        }
    }
}

// MARK: - Protocol

protocol EducationServiceProtocol {
    func fetchAllCards() async throws(EducationServiceError) -> [EducationCard]
    func fetchCard(id: String) async throws(EducationServiceError) -> EducationCard?
    func fetchRandomCard() async throws(EducationServiceError) -> EducationCard?
}
