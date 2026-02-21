import SwiftUI
import SwiftData

@main
struct BackFlowApp: App {
    // MARK: - State
    @State private var router = AppRouter()
    
    // MARK: - Model Container
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(
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
                Reference.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environment(router)
                .serviceContainer(ServiceContainer(modelContext: modelContainer.mainContext))
        }
    }
}
