import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "com.backflow.app", category: "QuickLogViewModel")

@MainActor @Observable
final class QuickLogViewModel {
    // MARK: - Published State
    var painNow: Int? = nil
    var painAfterActivity: Int? = nil
    var notes: String = ""
    
    var bowelBladderChange: Bool = false
    var saddleNumbness: Bool = false
    var progressiveWeakness: Bool = false
    var fever: Bool = false
    var majorTrauma: Bool = false
    var unexplainedWeightLoss: Bool = false
    var severeNightPain: Bool = false
    var showRedFlagWarning: Bool = false
    
    private(set) var isSaving: Bool = false
    
    // MARK: - Dependencies
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Computed Properties
    var hasRedFlags: Bool {
        bowelBladderChange || saddleNumbness || progressiveWeakness ||
        fever || majorTrauma || unexplainedWeightLoss || severeNightPain
    }
    
    var canSave: Bool {
        painNow != nil || painAfterActivity != nil || !notes.isEmpty
    }
    
    // MARK: - Actions
    func saveLog() async -> SaveResult {
        logger.info("Saving symptom log")
        isSaving = true
        defer { isSaving = false }
        
        let symptomLog = SymptomLog(
            timestamp: Date(),
            painNow: painNow,
            painAfterActivity: painAfterActivity,
            bowelBladderChange: bowelBladderChange,
            saddleNumbness: saddleNumbness,
            progressiveWeakness: progressiveWeakness,
            fever: fever,
            majorTrauma: majorTrauma,
            unexplainedWeightLoss: unexplainedWeightLoss,
            severeNightPain: severeNightPain,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(symptomLog)
        
        do {
            try modelContext.save()
            logger.info("✅ Successfully saved symptom log")
            
            if hasRedFlags {
                showRedFlagWarning = true
                return .showWarning
            } else {
                return .success
            }
        } catch {
            logger.error("Failed to save symptom log: \(error.localizedDescription)")
            return .failure
        }
    }
    
    func dismissWarning() {
        showRedFlagWarning = false
    }
}

// MARK: - Supporting Types

enum SaveResult {
    case success
    case showWarning
    case failure
}
