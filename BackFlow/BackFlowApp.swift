import SwiftUI
import SwiftData

@main
struct BackFlowApp: App {
    // MARK: - State
    @State private var router = AppRouter()
    
    // MARK: - Model Container
    let modelContainer: ModelContainer
    
    init() {
        // Check for test mode
        let isTestMode = ProcessInfo.processInfo.arguments.contains("-UITestMode")
        let shouldResetOnboarding = ProcessInfo.processInfo.arguments.contains("-ResetOnboarding")
        
        if shouldResetOnboarding {
            UserDefaults.standard.removeObject(forKey: "onboardingCompleted")
        }
        
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: isTestMode)
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
                Reference.self,
                configurations: configuration
            )
            
            // Import seed data on first launch (skip in test mode)
            if !isTestMode {
                let context = modelContainer.mainContext
                let seedImportService = SeedImportService(modelContext: context)
                
                Task {
                    if seedImportService.needsImport() {
                        try await seedImportService.importAllData()
                        print("✅ Seed data imported successfully")
                    }
                }
            }
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
