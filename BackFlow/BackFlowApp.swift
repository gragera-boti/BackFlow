import SwiftUI
import SwiftData

@main
struct BackFlowApp: App {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @AppStorage("cloudSyncEnabled") private var cloudSyncEnabled = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
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
                ], isStoredInMemoryOnly: false)
                .onAppear {
                    // Schedule daily reminder if enabled
                    NotificationService.shared.requestAuthorization()
                }
        }
    }
}
