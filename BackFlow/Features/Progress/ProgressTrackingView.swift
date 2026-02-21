import SwiftUI

struct ProgressTrackingView: View {
    @Environment(\.services) private var services
    @Environment(\.router) private var router
    
    @State private var viewModel: ProgressViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                SwiftUI.ProgressView()
                    .task {
                        guard let services = services else { return }
                        // TODO: Need to add symptomService to ServiceContainer
                        viewModel = ProgressViewModel(
                            sessionService: services.sessionService,
                            symptomService: MockSymptomService(), // Placeholder
                            walkingService: services.walkingService
                        )
                        await viewModel?.loadData()
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: ProgressViewModel) -> some View {
        @Bindable var bindableViewModel = viewModel
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xLarge) {
                    // Metric Selector
                    Picker("Metric", selection: $bindableViewModel.selectedMetric) {
                        ForEach(ProgressMetric.allCases) { metric in
                            Text(metric.rawValue).tag(metric)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Chart
                    switch viewModel.selectedMetric {
                    case .pain:
                        PainChartView(chartData: viewModel.painChartData)
                    case .walking:
                        WalkingChartView(weeklyData: viewModel.weeklyWalkingData)
                    case .adherence:
                        AdherenceChartView(weeklyAdherence: viewModel.weeklyAdherenceData)
                    }
                    
                    // Stats Summary
                    StatsGrid(
                        totalSessions: viewModel.totalCompletedSessions,
                        currentStreak: viewModel.currentStreak,
                        totalWalkingMinutes: viewModel.totalWalkingMinutes,
                        sessionsThisWeek: viewModel.sessionsThisWeek,
                        plannedThisWeek: viewModel.plannedSessionsThisWeek
                    )
                }
                .padding(Theme.Spacing.medium)
            }
            .navigationTitle("Progress")
            .alert("Error", isPresented: errorBinding(viewModel: viewModel)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private func errorBinding(viewModel: ProgressViewModel) -> Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )
    }
}

// MARK: - Mock Service
// TODO: Remove when proper service is implemented
private struct MockSymptomService: SymptomServiceProtocol {
    func fetchSymptomLogs(from startDate: Date?, to endDate: Date?) async throws -> [SymptomLog] {
        return []
    }
}

#Preview {
    ProgressTrackingView()
        .environment(AppRouter())
}