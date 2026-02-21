import SwiftUI
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "OnboardingFlow")

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    @State private var currentStep = 0
    @State private var redFlagsDetected = false
    
    var body: some View {
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
                        logger.info("Advancing from GoalAndSchedule to BaselineAssessment")
                        currentStep = 4
                    })
                    .id("goals-\(currentStep)")
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
        logger.info("Completing onboarding")
        
        // Mark the user profile as having completed onboarding
        let descriptor = FetchDescriptor<UserProfile>()
        
        do {
            guard let profiles = try? modelContext.fetch(descriptor),
                  let profile = profiles.first else {
                logger.error("No UserProfile found during onboarding completion")
                // Still mark as complete to prevent user from being stuck
                onboardingCompleted = true
                return
            }
            
            profile.onboardingCompleted = true
            
            try modelContext.save()
            logger.info("✅ Successfully marked profile as onboarding complete")
            
            onboardingCompleted = true
            logger.info("✅ Onboarding flow complete")
            
        } catch {
            logger.error("Failed to save onboarding completion: \(error.localizedDescription)")
            // Still mark as complete to prevent user from being stuck
            onboardingCompleted = true
        }
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
            .accessibilityLabel("Get started with BackFlow")
            .accessibilityHint("Begins the onboarding process")
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
            .accessibilityLabel("I understand and accept these limitations")
            
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
            .accessibilityLabel("Continue")
            .accessibilityHint("Proceeds to safety screening")
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
