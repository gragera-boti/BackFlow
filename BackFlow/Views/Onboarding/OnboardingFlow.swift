import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    @State private var currentStep = 0
    @State private var redFlagsDetected = false
    
    var body: some View {
        let _ = print("OnboardingFlow - currentStep: \(currentStep), redFlagsDetected: \(redFlagsDetected)")
        Group {
            switch currentStep {
            case 0:
                WelcomeView(onContinue: { currentStep = 1 })
            case 1:
                DisclaimerView(onContinue: { currentStep = 2 })
            case 2:
                RedFlagsView(
                    onPass: { currentStep = 3 },
                    onFail: {
                        redFlagsDetected = true
                        currentStep = 3
                    }
                )
            case 3:
                if redFlagsDetected {
                    StopAndSeekCareView()
                } else {
                    GoalAndScheduleView(onContinue: { 
                        print("OnboardingFlow: Advancing from GoalAndSchedule to BaselineAssessment")
                        print("Current thread: \(Thread.isMainThread ? "Main" : "Background")")
                        DispatchQueue.main.async {
                            print("Setting currentStep to 4 on main queue")
                            self.currentStep = 4
                            print("currentStep is now: \(self.currentStep)")
                        }
                    })
                    .id("goals-\(currentStep)") // Force view recreation
                }
            case 4:
                BaselineAssessmentView(onComplete: completeOnboarding)
                    .id("baseline-\(currentStep)") // Force view recreation
            default:
                Text("Onboarding complete")
            }
        }
    }
    
    private func completeOnboarding() {
        print("🎯 OnboardingFlow.completeOnboarding() called")
        print("Current thread: \(Thread.isMainThread ? "Main" : "Background")")
        
        // Mark the user profile as having completed onboarding
        let descriptor = FetchDescriptor<UserProfile>()
        if let profiles = try? modelContext.fetch(descriptor),
           let profile = profiles.first {
            print("✅ Found UserProfile, setting onboardingCompleted = true")
            profile.onboardingCompleted = true
            do {
                try modelContext.save()
                print("✅ Successfully saved profile with onboardingCompleted = true")
            } catch {
                print("❌ Error saving profile: \(error)")
            }
        } else {
            print("❌ ERROR: No UserProfile found!")
        }
        
        print("Setting @AppStorage onboardingCompleted = true")
        onboardingCompleted = true
        print("✅ Onboarding complete!")
    }
}

struct WelcomeView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "figure.walk")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Welcome to BackFlow")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Evidence-based rehab for low back pain")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureBullet(icon: "calendar", text: "Simple daily plan")
                FeatureBullet(icon: "chart.line.uptrend.xyaxis", text: "Track your progress")
                FeatureBullet(icon: "brain.head.profile", text: "Learn about back pain")
                FeatureBullet(icon: "arrow.up.right", text: "Build capacity safely")
            }
            .padding()
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct FeatureBullet: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
        }
    }
}

struct DisclaimerView: View {
    let onContinue: () -> Void
    @State private var accepted = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Important Medical Information")
                .font(.title)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DisclaimerPoint(
                        icon: "exclamationmark.triangle.fill",
                        text: "This app provides general education and tracking tools."
                    )
                    
                    DisclaimerPoint(
                        icon: "cross.case.fill",
                        text: "It does NOT diagnose conditions or provide medical advice."
                    )
                    
                    DisclaimerPoint(
                        icon: "phone.fill",
                        text: "It is NOT for emergencies. Call emergency services for urgent issues."
                    )
                    
                    DisclaimerPoint(
                        icon: "stethoscope",
                        text: "Always consult a qualified healthcare provider for medical concerns."
                    )
                    
                    Text("By continuing, you acknowledge that you understand these limitations and will seek appropriate medical care when needed.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            
            Toggle(isOn: $accepted) {
                Text("I understand and accept")
                    .font(.body)
            }
            .padding(.horizontal)
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(accepted ? Color.blue : Color.gray)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .disabled(!accepted)
            .padding(.horizontal)
        }
        .padding()
    }
}

struct DisclaimerPoint: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    OnboardingFlow()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
