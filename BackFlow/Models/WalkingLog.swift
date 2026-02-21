import Foundation
import SwiftData

@Model
final class WalkingLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var durationMinutes: Int
    var source: String // "manual" or "healthkit"
    var notes: String?
    
    init(
        id: UUID = UUID(),
        date: Date,
        durationMinutes: Int,
        source: String = "manual",
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.source = source
        self.notes = notes
    }
}