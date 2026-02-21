import SwiftData
import Foundation
@testable import BackFlow

/// Helper to create an in-memory model container for tests
struct TestModelContainer {
    static func create() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        
        return try ModelContainer(
            for: UserProfile.self,
            Exercise.self,
            EducationCard.self,
            ProgramTemplate.self,
            ProgramPlan.self,
            Session.self,
            SetLog.self,
            SymptomLog.self,
            FunctionLog.self,
            WalkingLog.self,
            Reference.self,
            configurations: configuration
        )
    }
}