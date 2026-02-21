import SwiftUI

struct LibraryView: View {
    @Environment(\.services) private var services
    @Environment(\.router) private var router
    
    @State private var viewModel: LibraryViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                SwiftUI.ProgressView()
                    .task {
                        guard let services = services else { return }
                        viewModel = LibraryViewModel(
                            exerciseService: services.exerciseService,
                            educationService: services.educationService
                        )
                        await viewModel?.loadData()
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: LibraryViewModel) -> some View {
        @Bindable var bindableViewModel = viewModel
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Library", selection: $bindableViewModel.selectedTab) {
                    ForEach(LibraryTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                switch viewModel.selectedTab {
                case .exercises:
                    ExerciseLibraryList(
                        groupedExercises: viewModel.groupedExercises,
                        onExerciseSelected: { exercise in
                            router.navigate(to: .exerciseDetail(exerciseSlug: exercise.slug))
                        }
                    )
                case .education:
                    EducationLibraryList(
                        cards: viewModel.filteredEducationCards,
                        onCardSelected: { card in
                            router.navigate(to: .educationDetail(cardId: card.cardId))
                        }
                    )
                }
            }
            .navigationTitle("Library")
            .searchable(text: $bindableViewModel.searchText, prompt: "Search...")
            .alert("Error", isPresented: errorBinding(viewModel: viewModel)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private func errorBinding(viewModel: LibraryViewModel) -> Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )
    }
}

#Preview {
    LibraryView()
        .environment(AppRouter())
}