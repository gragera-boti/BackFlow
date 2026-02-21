import Foundation
import SwiftData

@Model
final class Session {
    @Attribute(.unique) var id: UUID
    var date: Date
    var templateId: String
    var phaseId: String
    var durationSec: Int
    var completed: Bool
    var painAfterSession: Int?
    var notes: String?
    @Relationship(deleteRule: .cascade) var setLogs: [SetLog]
    @Relationship(deleteRule: .cascade) var symptomLog: SymptomLog?
    
    init(
        id: UUID = UUID(),
        date: Date,
        templateId: String,
        phaseId: String,
        durationSec: Int = 0,
        completed: Bool = false,
        painAfterSession: Int? = nil,
        notes: String? = nil,
        setLogs: [SetLog] = [],
        symptomLog: SymptomLog? = nil
    ) {
        self.id = id
        self.date = date
        self.templateId = templateId
        self.phaseId = phaseId
        self.durationSec = durationSec
        self.completed = completed
        self.painAfterSession = painAfterSession
        self.notes = notes
        self.setLogs = setLogs
        self.symptomLog = symptomLog
    }
}