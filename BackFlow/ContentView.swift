import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.router) private var router
    @Query private var profiles: [UserProfile]
    @State private var showOnboarding = false
    
    var body: some View {
        @Bindable var bindableRouter = router
        
        if showOnboarding {
            OnboardingFlow()
                .onAppear {
                    checkOnboardingStatus()
                }
        } else {
            NavigationStack(path: $bindableRouter.path) {
                TabView {
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "calendar")
                    }
                
                PlanView()
                    .tabItem {
                        Label("Plan", systemImage: "list.bullet.clipboard")
                    }
                
                ProgressTrackingView()
                    .tabItem {
                        Label("Progress", systemImage: "chart.xyaxis.line")
                    }
                
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "books.vertical")
                    }
                }
                .navigationDestination(for: AppDestination.self) { destination in
                    destinationView(for: destination)
                }
            }
            .onAppear {
                checkOnboardingStatus()
            }
        }
    }
    
    private func checkOnboardingStatus() {
        // If no profiles exist or onboarding not completed, show onboarding
        showOnboarding = profiles.isEmpty || !(profiles.first?.onboardingCompleted ?? false)
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .exerciseDetail(let slug):
            ExerciseDetailContainer(exerciseSlug: slug)
            
        case .educationDetail(let cardId):
            EducationDetailContainer(cardId: cardId)
            
        case .sessionPlayer(let sessionId):
            SessionPlayerContainer(sessionId: sessionId)
            
        case .settings:
            SettingsView()
            
        case .quickLog:
            QuickLogSheet()
            
        case .walkingLog:
            WalkingLogSheet()
            
        case .baselineAssessment:
            BaselineAssessmentView(onComplete: { router.popToRoot() })
            
        case .redFlags:
            RedFlagsView(onPass: { router.popToRoot() }, onFail: { router.popToRoot() })
            
        case .goalAndSchedule:
            GoalAndScheduleView(onContinue: { router.popToRoot() })
        }
    }
}

#Preview {
    ContentView()
        .environment(AppRouter())
}
