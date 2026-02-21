import Foundation
import SwiftData

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
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        painNow: Int? = nil,
        painAfterActivity: Int? = nil,
        painNextDay: Int? = nil,
        bowelBladderChange: Bool = false,
        saddleNumbness: Bool = false,
        progressiveWeakness: Bool = false,
        fever: Bool = false,
        majorTrauma: Bool = false,
        unexplainedWeightLoss: Bool = false,
        severeNightPain: Bool = false,
        notes: String? = nil
    ) {
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
        return bowelBladderChange || 
               saddleNumbness || 
               progressiveWeakness || 
               fever || 
               majorTrauma || 
               unexplainedWeightLoss || 
               severeNightPain
    }
}