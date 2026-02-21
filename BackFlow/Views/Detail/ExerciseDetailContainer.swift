import SwiftUI

struct ExerciseDetailContainer: View {
    let exerciseSlug: String
    
    @Environment(\.services) private var services
    @State private var viewModel: ExerciseDetailViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                ProgressView()
                    .task {
                        guard let services = services else { return }
                        let vm = ExerciseDetailViewModel(
                            exerciseService: services.exerciseService
                        )
                        viewModel = vm
                        await vm.loadExercise(slug: exerciseSlug)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: ExerciseDetailViewModel) -> some View {
        if viewModel.isLoading {
            ProgressView("Loading exercise...")
        } else if let exercise = viewModel.exercise {
            ExerciseDetailView(exercise: exercise)
        } else {
            ContentUnavailableView(
                "Exercise Not Found",
                systemImage: "exclamationmark.triangle",
                description: Text(viewModel.errorMessage ?? "Unable to load exercise")
            )
        }
    }
}

#Preview {
    ExerciseDetailContainer(exerciseSlug: "bird-dog")
        .environment(AppRouter())
}