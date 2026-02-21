import SwiftUI

struct PlanView: View {
    @Environment(\.services) private var services
    @Environment(\.router) private var router
    
    @State private var viewModel: PlanViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                SwiftUI.ProgressView()
                    .task {
                        guard let services = services else { return }
                        viewModel = PlanViewModel(
                            programService: services.programService,
                            sessionService: services.sessionService
                        )
                        await viewModel?.loadData()
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: PlanViewModel) -> some View {
        NavigationStack {
            ScrollView {
                if viewModel.hasActivePlan {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xLarge) {
                        // Plan Overview
                        PlanOverviewSection(
                            weekDisplay: viewModel.currentWeekDisplay,
                            phaseDisplay: viewModel.currentPhaseDisplay,
                            isPaused: viewModel.isPlanPaused,
                            pausedReason: viewModel.pausedReason
                        )
                        
                        // Current Phase
                        CurrentPhaseSection(
                            exercises: viewModel.currentPhaseExercises
                        )
                        
                        // Upcoming Sessions
                        UpcomingSessionsSection(
                            upcomingDates: viewModel.getUpcomingSessionDates(),
                            formatWeekday: viewModel.formatWeekday
                        )
                        
                        // Activity Ladder
                        ActivityLadderSection(
                            level: viewModel.activityLadderLevel,
                            progress: viewModel.activityLadderProgress
                        )
                    }
                    .padding(Theme.Spacing.medium)
                } else {
                    ContentUnavailableView(
                        "No Active Plan",
                        systemImage: "list.clipboard",
                        description: Text("Complete onboarding to create your rehab plan")
                    )
                }
            }
            .navigationTitle("Plan")
            .alert("Error", isPresented: errorBinding(viewModel: viewModel)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private func errorBinding(viewModel: PlanViewModel) -> Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )
    }
}

#Preview {
    PlanView()
        .environment(AppRouter())
}