import Foundation
import SwiftData

// MARK: - UserProfile
@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var goal: String
    var sessionsPerWeek: Int
    var equipment: [String]
    var reminderTime: DateComponents?
    var painThreshold: Int // default 3; editable Premium
    var cloudSyncEnabled: Bool
    var onboardingCompleted: Bool
    
    init(id: UUID = UUID(), createdAt: Date = Date(), goal: String = "", sessionsPerWeek: Int = 3, equipment: [String] = [], reminderTime: DateComponents? = nil, painThreshold: Int = 3, cloudSyncEnabled: Bool = false, onboardingCompleted: Bool = false) {
        self.id = id
        self.createdAt = createdAt
        self.goal = goal
        self.sessionsPerWeek = sessionsPerWeek
        self.equipment = equipment
        self.reminderTime = reminderTime
        self.painThreshold = painThreshold
        self.cloudSyncEnabled = cloudSyncEnabled
        self.onboardingCompleted = onboardingCompleted
    }
}

// MARK: - Reference (seeded)
@Model
final class Reference {
    @Attribute(.unique) var key: String
    var type: String
    var title: String
    var authors: String
    var year: Int
    var journal: String
    var doi: String
    var url: String
    var notes: String
    
    init(key: String, type: String, title: String, authors: String, year: Int, journal: String, doi: String, url: String, notes: String) {
        self.key = key
        self.type = type
        self.title = title
        self.authors = authors
        self.year = year
        self.journal = journal
        self.doi = doi
        self.url = url
        self.notes = notes
    }
}

// MARK: - Exercise (seeded)
@Model
final class Exercise {
    @Attribute(.unique) var slug: String
    var name: String
    var category: String
    var regions: [String]
    var equipment: [String]
    var difficulty: String
    var timePerSetSec: Int?
    var setsDefault: Int
    var repsDefault: Int?
    var holdSecDefault: Int?
    var restSecDefault: Int?
    var primaryCues: [String]
    var commonMistakes: [String]
    var progressions: [String]
    var regressions: [String]
    var dosageNotes: String
    var rangeOfMotionNotes: String
    var evidenceRefs: [String]
    var illustrationAssetName: String
    
    init(slug: String, name: String, category: String, regions: [String], equipment: [String], difficulty: String, timePerSetSec: Int? = nil, setsDefault: Int, repsDefault: Int? = nil, holdSecDefault: Int? = nil, restSecDefault: Int? = nil, primaryCues: [String], commonMistakes: [String], progressions: [String], regressions: [String], dosageNotes: String, rangeOfMotionNotes: String, evidenceRefs: [String], illustrationAssetName: String) {
        self.slug = slug
        self.name = name
        self.category = category
        self.regions = regions
        self.equipment = equipment
        self.difficulty = difficulty
        self.timePerSetSec = timePerSetSec
        self.setsDefault = setsDefault
        self.repsDefault = repsDefault
        self.holdSecDefault = holdSecDefault
        self.restSecDefault = restSecDefault
        self.primaryCues = primaryCues
        self.commonMistakes = commonMistakes
        self.progressions = progressions
        self.regressions = regressions
        self.dosageNotes = dosageNotes
        self.rangeOfMotionNotes = rangeOfMotionNotes
        self.evidenceRefs = evidenceRefs
        self.illustrationAssetName = illustrationAssetName
    }
}

// MARK: - EducationCard (seeded)
@Model
final class EducationCard {
    @Attribute(.unique) var cardId: String
    var title: String
    var summary: String
    var detailMarkdown: String
    var refs: [String]
    
    init(cardId: String, title: String, summary: String, detailMarkdown: String, refs: [String]) {
        self.cardId = cardId
        self.title = title
        self.summary = summary
        self.detailMarkdown = detailMarkdown
        self.refs = refs
    }
}

// MARK: - ProgramTemplate (seeded)
@Model
final class ProgramTemplate {
    @Attribute(.unique) var programId: String
    var name: String
    var targetCondition: String
    var jsonPayload: String // store full template JSON
    
    init(programId: String, name: String, targetCondition: String, jsonPayload: String) {
        self.programId = programId
        self.name = name
        self.targetCondition = targetCondition
        self.jsonPayload = jsonPayload
    }
}

// MARK: - ProgramPlan (user state)
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
    
    init(id: UUID = UUID(), programId: String, startDate: Date = Date(), currentPhaseId: String, currentWeek: Int = 1, activityLadderLevel: Int = 0, isPaused: Bool = false, pausedReason: String? = nil, weekdays: [Int], nextSessionDate: Date? = nil) {
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

// MARK: - Session
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
    
    init(id: UUID = UUID(), date: Date = Date(), templateId: String, phaseId: String, durationSec: Int = 0, completed: Bool = false, painAfterSession: Int? = nil, notes: String? = nil, setLogs: [SetLog] = [], symptomLog: SymptomLog? = nil) {
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

// MARK: - SetLog
@Model
final class SetLog {
    @Attribute(.unique) var id: UUID
    var session: Session?
    var exerciseSlug: String
    var setIndex: Int
    var targetReps: Int?
    var targetHoldSec: Int?
    var actualReps: Int?
    var actualHoldSec: Int?
    var restSec: Int?
    var painDuring: Int?
    
    init(id: UUID = UUID(), session: Session? = nil, exerciseSlug: String, setIndex: Int, targetReps: Int? = nil, targetHoldSec: Int? = nil, actualReps: Int? = nil, actualHoldSec: Int? = nil, restSec: Int? = nil, painDuring: Int? = nil) {
        self.id = id
        self.session = session
        self.exerciseSlug = exerciseSlug
        self.setIndex = setIndex
        self.targetReps = targetReps
        self.targetHoldSec = targetHoldSec
        self.actualReps = actualReps
        self.actualHoldSec = actualHoldSec
        self.restSec = restSec
        self.painDuring = painDuring
    }
}

// MARK: - SymptomLog
@Model
final class SymptomLog {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var painNow: Int?
    var painAfterActivity: Int?
    var painNextDay: Int?
    var bowelBladderChange: Bool
    var saddleNumbness: Bool
    var progressiveWeakness: Bool
    var fever: Bool
    var majorTrauma: Bool
    var unexplainedWeightLoss: Bool
    var severeNightPain: Bool
    var notes: String?
    
    init(id: UUID = UUID(), timestamp: Date = Date(), painNow: Int? = nil, painAfterActivity: Int? = nil, painNextDay: Int? = nil, bowelBladderChange: Bool = false, saddleNumbness: Bool = false, progressiveWeakness: Bool = false, fever: Bool = false, majorTrauma: Bool = false, unexplainedWeightLoss: Bool = false, severeNightPain: Bool = false, notes: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.painNow = painNow
        self.painAfterActivity = painAfterActivity
        self.painNextDay = painNextDay
        self.bowelBladderChange = bowelBladderChange
        self.saddleNumbness = saddleNumbness
        self.progressiveWeakness = progressiveWeakness
        self.fever = fever
        self.majorTrauma = majorTrauma
        self.unexplainedWeightLoss = unexplainedWeightLoss
        self.severeNightPain = severeNightPain
        self.notes = notes
    }
    
    var hasRedFlags: Bool {
        return bowelBladderChange || saddleNumbness || progressiveWeakness || fever || majorTrauma || unexplainedWeightLoss || severeNightPain
    }
}

// MARK: - FunctionLog
@Model
final class FunctionLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var tasksJSON: String // stores up to 3 tasks and scores (0–10)
    var overallScore: Double // derived 0–100
    
    init(id: UUID = UUID(), date: Date = Date(), tasksJSON: String, overallScore: Double) {
        self.id = id
        self.date = date
        self.tasksJSON = tasksJSON
        self.overallScore = overallScore
    }
}

// MARK: - WalkingLog
@Model
final class WalkingLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var durationMinutes: Int
    var source: String // "manual" or "healthkit"
    var notes: String?
    
    init(id: UUID = UUID(), date: Date = Date(), durationMinutes: Int, source: String = "manual", notes: String? = nil) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.source = source
        self.notes = notes
    }
}
