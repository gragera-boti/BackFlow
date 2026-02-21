import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "com.backflow.app", category: "WalkingLogViewModel")

@MainActor @Observable
final class WalkingLogViewModel {
    // MARK: - Published State
    var durationMinutes: Int = 10
    var source: WalkingSource = .manual
    var notes: String = ""
    
    private(set) var isSaving: Bool = false
    
    // MARK: - Dependencies
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Actions
    func saveLog() async -> Bool {
        logger.info("Saving walking log: \(self.durationMinutes) minutes")
        isSaving = true
        defer { isSaving = false }
        
        let walkingLog = WalkingLog(
            date: Date(),
            durationMinutes: durationMinutes,
            source: source.rawValue,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(walkingLog)
        
        do {
            try modelContext.save()
            logger.info("✅ Successfully saved walking log")
            return true
        } catch {
            logger.error("Failed to save walking log: \(error.localizedDescription)")
            return false
        }
    }
}

// MARK: - Supporting Types

enum WalkingSource: String, CaseIterable, Identifiable {
    case manual = "manual"
    case health = "healthkit"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .manual: return "Manual Entry"
        case .health: return "Health App"
        }
    }
}
