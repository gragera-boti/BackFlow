import SwiftUI
import SwiftData

@main
struct BackFlowApp: App {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @AppStorage("cloudSyncEnabled") private var cloudSyncEnabled = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Reference.self,
            Exercise.self,
            EducationCard.self,
            ProgramTemplate.self,
            ProgramPlan.self,
            Session.self,
            SetLog.self,
            SymptomLog.self,
            FunctionLog.self,
            WalkingLog.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .onAppear {
                    // Schedule daily reminder if enabled
                    NotificationService.shared.requestAuthorization()
                }
        }
    }
}
