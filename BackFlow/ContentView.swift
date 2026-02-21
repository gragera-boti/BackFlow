import SwiftUI

struct ContentView: View {
    @Environment(\.router) private var router
    
    var body: some View {
        @Bindable var bindableRouter = router
        NavigationStack(path: $bindableRouter.path) {
            TabView {
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "calendar")
                    }
                
                // TODO: Add other tab views (Plan, Progress, Library)
                Text("Plan")
                    .tabItem {
                        Label("Plan", systemImage: "list.bullet.clipboard")
                    }
                
                Text("Progress")
                    .tabItem {
                        Label("Progress", systemImage: "chart.xyaxis.line")
                    }
                
                Text("Library")
                    .tabItem {
                        Label("Library", systemImage: "books.vertical")
                    }
            }
            .navigationDestination(for: AppDestination.self) { destination in
                destinationView(for: destination)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .exerciseDetail(let slug):
            Text("Exercise Detail: \(slug)")
            // TODO: ExerciseDetailView(exerciseSlug: slug)
            
        case .educationDetail(let cardId):
            Text("Education Detail: \(cardId)")
            // TODO: EducationDetailView(cardId: cardId)
            
        case .sessionPlayer(let sessionId):
            Text("Session Player: \(sessionId)")
            // TODO: SessionPlayerView(sessionId: sessionId)
            
        case .settings:
            Text("Settings")
            // TODO: SettingsView()
            
        case .quickLog:
            Text("Quick Log")
            // TODO: QuickLogSheet()
            
        case .walkingLog:
            Text("Walking Log")
            // TODO: WalkingLogSheet()
            
        case .baselineAssessment:
            Text("Baseline Assessment")
            // TODO: BaselineAssessmentView()
            
        case .redFlags:
            Text("Red Flags")
            // TODO: RedFlagsView()
            
        case .goalAndSchedule:
            Text("Goal and Schedule")
            // TODO: GoalAndScheduleView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppRouter())
}
