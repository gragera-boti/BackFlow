import SwiftUI

struct EducationDetailContainer: View {
    let cardId: String
    
    @Environment(\.services) private var services
    @State private var viewModel: EducationDetailViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                ProgressView()
                    .task {
                        guard let services = services else { return }
                        let vm = EducationDetailViewModel(
                            educationService: services.educationService
                        )
                        viewModel = vm
                        await vm.loadCard(id: cardId)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: EducationDetailViewModel) -> some View {
        if viewModel.isLoading {
            ProgressView("Loading education content...")
        } else if let card = viewModel.educationCard {
            EducationDetailView(card: card)
        } else {
            ContentUnavailableView(
                "Content Not Found",
                systemImage: "exclamationmark.triangle",
                description: Text(viewModel.errorMessage ?? "Unable to load education content")
            )
        }
    }
}

#Preview {
    EducationDetailContainer(cardId: "pain-understanding")
        .environment(AppRouter())
}