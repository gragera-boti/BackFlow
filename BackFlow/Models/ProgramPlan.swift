import Foundation
import SwiftData

@Model
final class ProgramPlan {
    @Attribute(.unique) var id: UUID
    var programId: String
    var startDate: Date
    var currentPhaseId: String
    var currentWeek: Int
    var activityLadderLevel: Int
    var isPaused: Bool
    var pausedReason: String?
    var weekdays: [Int] // 0–6
    var nextSessionDate: Date?
    
    init(
        id: UUID = UUID(),
        programId: String,
        startDate: Date,
        currentPhaseId: String,
        currentWeek: Int = 1,
        activityLadderLevel: Int = 0,
        isPaused: Bool = false,
        pausedReason: String? = nil,
        weekdays: [Int],
        nextSessionDate: Date? = nil
    ) {
        self.id = id
        self.programId = programId
        self.startDate = startDate
        self.currentPhaseId = currentPhaseId
        self.currentWeek = currentWeek
        self.activityLadderLevel = activityLadderLevel
        self.isPaused = isPaused
        self.pausedReason = pausedReason
        self.weekdays = weekdays
        self.nextSessionDate = nextSessionDate
    }
}