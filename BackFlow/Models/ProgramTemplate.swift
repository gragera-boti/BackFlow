import Foundation
import SwiftData

@Model
final class ProgramTemplate {
    @Attribute(.unique) var programId: String
    var name: String
    var targetCondition: String
    var jsonPayload: String // store full template JSON
    
    init(
        programId: String,
        name: String,
        targetCondition: String,
        jsonPayload: String
    ) {
        self.programId = programId
        self.name = name
        self.targetCondition = targetCondition
        self.jsonPayload = jsonPayload
    }
}