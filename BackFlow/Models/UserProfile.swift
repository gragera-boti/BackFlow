import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var goal: String
    var sessionsPerWeek: Int
    var equipment: [String]
    var reminderHour: Int?
    var reminderMinute: Int?
    var painThreshold: Int // default 3; editable Premium
    var cloudSyncEnabled: Bool
    var onboardingCompleted: Bool
    
    init(
        id: UUID = UUID(),
        createdAt: Date,
        goal: String = "",
        sessionsPerWeek: Int = 3,
        equipment: [String] = [],
        reminderHour: Int? = nil,
        reminderMinute: Int? = nil,
        painThreshold: Int = 3,
        cloudSyncEnabled: Bool = false,
        onboardingCompleted: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.goal = goal
        self.sessionsPerWeek = sessionsPerWeek
        self.equipment = equipment
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.painThreshold = painThreshold
        self.cloudSyncEnabled = cloudSyncEnabled
        self.onboardingCompleted = onboardingCompleted
    }
}