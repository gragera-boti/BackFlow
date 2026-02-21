import Foundation
import SwiftData

@Model
final class FunctionLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var tasksJSON: String // stores up to 3 tasks and scores (0–10)
    var overallScore: Double // derived 0–100
    
    init(
        id: UUID = UUID(),
        date: Date,
        tasksJSON: String,
        overallScore: Double
    ) {
        self.id = id
        self.date = date
        self.tasksJSON = tasksJSON
        self.overallScore = overallScore
    }
}