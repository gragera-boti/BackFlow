import SwiftUI
import SwiftData

@main
struct TestOnboardingButtonApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
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
            
            // Create initial profile WITHOUT onboarding completed
            let context = modelContainer.mainContext
            let profile = UserProfile(
                createdAt: Date(),
                goal: "Test Goal",
                sessionsPerWeek: 3,
                onboardingCompleted: false
            )
            context.insert(profile)
            try context.save()
            print("✅ Created test profile with onboardingCompleted = false")
            
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TestView()
                .modelContainer(modelContainer)
        }
    }
}

struct TestView: View {
    @Query private var profiles: [UserProfile]
    @State private var testResult = "Not tested yet"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Onboarding Button Test")
                .font(.title)
            
            Text("Profile onboarding status: \(profiles.first?.onboardingCompleted == true ? "✅ Completed" : "❌ Not Completed")")
            
            Text(testResult)
                .foregroundColor(testResult.contains("✅") ? .green : .red)
                .multilineTextAlignment(.center)
            
            Button("Test Onboarding Completion") {
                testOnboardingFlow()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Reset Test") {
                resetTest()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private func testOnboardingFlow() {
        guard let profile = profiles.first else {
            testResult = "❌ No profile found"
            return
        }
        
        // Simulate what completeOnboarding does
        profile.onboardingCompleted = true
        
        do {
            try profile.modelContext?.save()
            testResult = "✅ Successfully marked onboarding as complete!"
        } catch {
            testResult = "❌ Error saving: \(error.localizedDescription)"
        }
    }
    
    private func resetTest() {
        guard let profile = profiles.first else { return }
        profile.onboardingCompleted = false
        try? profile.modelContext?.save()
        testResult = "Reset to not completed"
    }
}
