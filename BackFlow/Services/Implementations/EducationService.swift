import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "EducationService")

@MainActor
final class EducationService: EducationServiceProtocol {
    static let shared = EducationService()
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext? = nil) {
        if let context = modelContext {
            self.modelContext = context
        } else {
            fatalError("ModelContext must be provided via dependency injection")
        }
    }
    
    // MARK: - Protocol Methods
    
    func fetchAllCards() async throws(EducationServiceError) -> [EducationCard] {
        let descriptor = FetchDescriptor<EducationCard>()
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch education cards: \(error.localizedDescription)")
            throw .fetchFailed(underlying: error)
        }
    }
    
    func fetchCard(id: String) async throws(EducationServiceError) -> EducationCard? {
        let descriptor = FetchDescriptor<EducationCard>(
            predicate: #Predicate { $0.cardId == id }
        )
        
        do {
            let cards = try modelContext.fetch(descriptor)
            return cards.first
        } catch {
            logger.error("Failed to fetch education card \(id): \(error.localizedDescription)")
            throw .fetchFailed(underlying: error)
        }
    }
    
    func fetchRandomCard() async throws(EducationServiceError) -> EducationCard? {
        do {
            let cards = try await fetchAllCards()
            return cards.randomElement()
        } catch {
            throw error
        }
    }
}
