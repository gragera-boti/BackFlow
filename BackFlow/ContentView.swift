import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @State private var seedingComplete = false
    
    var body: some View {
        Group {
            if !seedingComplete {
                ProgressView("Loading...")
                    .task {
                        await SeedImportService.shared.importSeedDataIfNeeded(modelContext: modelContext)
                        seedingComplete = true
                    }
            } else if !onboardingCompleted {
                OnboardingFlow()
            } else {
                MainTabView()
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(0)
            
            PlanView()
                .tabItem {
                    Label("Plan", systemImage: "list.bullet.clipboard")
                }
                .tag(1)
            
            ProgressTrackingView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(3)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: UserProfile.self, Exercise.self, Session.self,
        configurations: config
    )
    return ContentView()
        .modelContainer(container)
}
