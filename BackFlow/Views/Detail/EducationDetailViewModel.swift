import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "EducationDetailViewModel")

@MainActor @Observable
final class EducationDetailViewModel {
    // MARK: - Published State
    private(set) var educationCard: EducationCard?
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let educationService: EducationServiceProtocol
    
    // MARK: - Initialization
    init(educationService: EducationServiceProtocol) {
        self.educationService = educationService
    }
    
    // MARK: - Actions
    func loadCard(id: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            educationCard = try await educationService.fetchCard(id: id)
            if educationCard == nil {
                errorMessage = "Education card not found"
            }
        } catch let error as EducationServiceError {
            logger.error("Failed to load education card: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            errorMessage = "Failed to load education card"
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}