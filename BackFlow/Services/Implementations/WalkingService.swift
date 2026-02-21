import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "WalkingService")

@MainActor
final class WalkingService: WalkingServiceProtocol {
    static let shared = WalkingService()
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext? = nil) {
        if let context = modelContext {
            self.modelContext = context
        } else {
            fatalError("ModelContext must be provided via dependency injection")
        }
    }
    
    // MARK: - Protocol Methods
    
    func fetchTodayTotal() async throws(WalkingServiceError) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<WalkingLog>(
            predicate: #Predicate { log in
                log.date >= startOfDay && log.date < endOfDay
            }
        )
        
        do {
            let logs = try modelContext.fetch(descriptor)
            return logs.reduce(0) { $0 + $1.durationMinutes }
        } catch {
            logger.error("Failed to fetch today's walking total: \(error.localizedDescription)")
            throw .fetchFailed(underlying: error)
        }
    }
    
    func fetchLogs(from startDate: Date, to endDate: Date) async throws(WalkingServiceError) -> [WalkingLog] {
        let descriptor = FetchDescriptor<WalkingLog>(
            predicate: #Predicate { log in
                log.date >= startDate && log.date <= endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch walking logs: \(error.localizedDescription)")
            throw .fetchFailed(underlying: error)
        }
    }
    
    func logWalking(durationMinutes: Int, source: String, notes: String?) async throws(WalkingServiceError) -> WalkingLog {
        let log = WalkingLog(
            durationMinutes: durationMinutes,
            source: source,
            notes: notes
        )
        
        modelContext.insert(log)
        
        do {
            try modelContext.save()
            logger.info("Logged walking: \(durationMinutes) minutes")
            return log
        } catch {
            logger.error("Failed to log walking: \(error.localizedDescription)")
            throw .saveFailed(underlying: error)
        }
    }
}
