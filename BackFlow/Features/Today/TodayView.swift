import SwiftUI

struct TodayView: View {
    @Environment(\.services) private var services
    @Environment(\.router) private var router
    
    @State private var viewModel: TodayViewModel?
    @State private var showQuickLog = false
    @State private var showWalkingLog = false
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                SwiftUI.ProgressView()
                    .task {
                        guard let services = services else { return }
                        viewModel = TodayViewModel(
                            programService: services.programService,
                            sessionService: services.sessionService,
                            walkingService: services.walkingService,
                            educationService: services.educationService
                        )
                        await viewModel?.loadData()
                    }
            }
        }
        .navigationTitle("Today")
    }
    
    @ViewBuilder
    private func contentView(viewModel: TodayViewModel) -> some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.medium) {
                // Today's Session Card
                if let plan = viewModel.activePlan {
                    TodaySessionCard(
                        phaseDisplay: viewModel.currentPhaseDisplay,
                        isPaused: viewModel.isPlanPaused,
                        pausedReason: viewModel.pausedReason,
                        hasSession: viewModel.todaySession != nil,
                        nextSessionDate: viewModel.nextSessionDate,
                        onStartSession: {
                            if let session = viewModel.todaySession {
                                router.navigate(to: .sessionPlayer(sessionId: session.id))
                            }
                        }
                    )
                }
                
                // Walking Target Card
                WalkingTargetCard(
                    todayMinutes: viewModel.todayWalkingMinutes,
                    targetMinutes: viewModel.walkingTargetMinutes,
                    progress: viewModel.walkingProgress,
                    onLogWalk: {
                        showWalkingLog = true
                    }
                )
                
                // Quick Log Card
                QuickLogCard(
                    onTap: {
                        showQuickLog = true
                    }
                )
                
                // Education Bite
                if let card = viewModel.randomEducationCard {
                    EducationBiteCard(
                        card: card,
                        onTap: {
                            router.navigate(to: .educationDetail(cardId: card.cardId))
                        }
                    )
                }
            }
            .padding(Theme.Spacing.medium)
        }
        .refreshable {
            await viewModel.refreshData()
        }
        .sheet(isPresented: $showQuickLog) {
            QuickLogSheet()
        }
        .sheet(isPresented: $showWalkingLog) {
            WalkingLogSheet()
        }
        .alert("Error", isPresented: errorBinding(viewModel: viewModel)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private func errorBinding(viewModel: TodayViewModel) -> Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )
    }
}

#Preview {
    TodayView()
}
