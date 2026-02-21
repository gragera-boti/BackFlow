import Foundation
import SwiftData

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
    
    init(
        slug: String,
        name: String,
        category: String,
        regions: [String],
        equipment: [String],
        difficulty: String,
        timePerSetSec: Int? = nil,
        setsDefault: Int,
        repsDefault: Int? = nil,
        holdSecDefault: Int? = nil,
        restSecDefault: Int? = nil,
        primaryCues: [String],
        commonMistakes: [String],
        progressions: [String],
        regressions: [String],
        dosageNotes: String,
        rangeOfMotionNotes: String,
        evidenceRefs: [String],
        illustrationAssetName: String
    ) {
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