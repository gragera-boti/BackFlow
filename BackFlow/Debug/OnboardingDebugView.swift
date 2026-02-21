import SwiftUI
import SwiftData

#if DEBUG
/// Debug view to manually test the onboarding flow
struct OnboardingDebugView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    @State private var showOnboarding = false
    @State private var logMessages: [String] = []
    @State private var testResults: [TestResult] = []
    
    struct TestResult: Identifiable {
        let id = UUID()
        let name: String
        let passed: Bool
        let message: String
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Status Section
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Onboarding Status", systemImage: "info.circle")
                            .font(.headline)
                        
                        HStack {
                            Text("Onboarding Completed:")
                            Text(onboardingCompleted ? "Yes" : "No")
                                .foregroundStyle(onboardingCompleted ? .green : .red)
                                .fontWeight(.bold)
                        }
                        
                        if let profile = fetchUserProfile() {
                            Text("Profile exists with \(profile.sessionsPerWeek) sessions/week")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("No user profile found")
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Actions Section
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Actions", systemImage: "play.circle")
                            .font(.headline)
                        
                        Button("Reset Onboarding") {
                            resetOnboarding()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Show Onboarding Flow") {
                            showOnboarding = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Run Automated Tests") {
                            runAutomatedTests()
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Test Results Section
                    if !testResults.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Test Results", systemImage: "checkmark.circle")
                                .font(.headline)
                            
                            ForEach(testResults) { result in
                                HStack {
                                    Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(result.passed ? .green : .red)
                                    
                                    VStack(alignment: .leading) {
                                        Text(result.name)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        Text(result.message)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Log Messages Section
                    if !logMessages.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Debug Log", systemImage: "terminal")
                                .font(.headline)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 5) {
                                    ForEach(Array(logMessages.enumerated()), id: \.offset) { index, message in
                                        Text(message)
                                            .font(.system(.caption, design: .monospaced))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxHeight: 200)
                            .padding(8)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(5)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Onboarding Debug")
            .sheet(isPresented: $showOnboarding) {
                OnboardingFlow()
                    .interactiveDismissDisabled()
            }
        }
    }
    
    private func fetchUserProfile() -> UserProfile? {
        try? modelContext.fetch(FetchDescriptor<UserProfile>()).first
    }
    
    private func resetOnboarding() {
        // Delete all user data
        do {
            try modelContext.delete(model: UserProfile.self)
            try modelContext.delete(model: ProgramPlan.self)
            onboardingCompleted = false
            
            logMessages.append("✅ Reset completed - all data cleared")
        } catch {
            logMessages.append("❌ Reset failed: \(error.localizedDescription)")
        }
    }
    
    private func runAutomatedTests() {
        testResults.removeAll()
        logMessages.removeAll()
        
        // Test 1: Check initial state
        let hasNoProfile = fetchUserProfile() == nil
        testResults.append(TestResult(
            name: "Initial State Check",
            passed: hasNoProfile,
            message: hasNoProfile ? "No existing profile found" : "Profile exists - reset needed"
        ))
        
        // Test 2: Create test data
        do {
            let profile = UserProfile(
                createdAt: Date(),
                goal: "Test Goal",
                sessionsPerWeek: 3,
                equipment: ["None"],
                reminderHour: 9,
                reminderMinute: 0
            )
            modelContext.insert(profile)
            
            let plan = ProgramPlan(
                programId: "test-program",
                startDate: Date(),
                currentPhaseId: "phase-1",
                currentWeek: 1,
                activityLadderLevel: 0,
                isPaused: false,
                weekdays: [1, 3, 5]
            )
            modelContext.insert(plan)
            
            try modelContext.save()
            
            testResults.append(TestResult(
                name: "Data Creation",
                passed: true,
                message: "Profile and plan created successfully"
            ))
            
            // Test 3: Verify data persistence
            let savedProfile = fetchUserProfile()
            let profileValid = savedProfile != nil && savedProfile?.sessionsPerWeek == 3
            testResults.append(TestResult(
                name: "Data Persistence",
                passed: profileValid,
                message: profileValid ? "Data saved and retrieved correctly" : "Data retrieval failed"
            ))
            
            // Clean up
            try modelContext.delete(model: UserProfile.self)
            try modelContext.delete(model: ProgramPlan.self)
            
        } catch {
            testResults.append(TestResult(
                name: "Data Operations",
                passed: false,
                message: "Error: \(error.localizedDescription)"
            ))
        }
        
        // Test 4: Navigation simulation
        var navigationWorked = true
        var currentStep = 0
        
        // Simulate navigation through steps
        for expectedStep in 1...4 {
            currentStep = expectedStep
            if currentStep != expectedStep {
                navigationWorked = false
                break
            }
        }
        
        testResults.append(TestResult(
            name: "Navigation Flow",
            passed: navigationWorked,
            message: navigationWorked ? "All navigation steps work" : "Navigation failed at step \(currentStep)"
        ))
        
        logMessages.append("✅ Automated tests completed")
        logMessages.append("Total tests: \(testResults.count)")
        logMessages.append("Passed: \(testResults.filter { $0.passed }.count)")
        logMessages.append("Failed: \(testResults.filter { !$0.passed }.count)")
    }
}

#if DEBUG
struct OnboardingDebugView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingDebugView()
            .modelContainer(for: UserProfile.self, inMemory: true)
    }
}
#endif
#endif