import Foundation
import SwiftData

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
    
    init(
        id: UUID = UUID(),
        session: Session? = nil,
        exerciseSlug: String,
        setIndex: Int,
        targetReps: Int? = nil,
        targetHoldSec: Int? = nil,
        actualReps: Int? = nil,
        actualHoldSec: Int? = nil,
        restSec: Int? = nil,
        painDuring: Int? = nil
    ) {
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