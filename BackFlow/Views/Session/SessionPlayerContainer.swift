import SwiftUI

struct SessionPlayerContainer: View {
    let sessionId: UUID
    
    @Environment(\.services) private var services
    @State private var viewModel: SessionPlayerViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                ProgressView()
                    .task {
                        guard let services = services else { return }
                        let vm = SessionPlayerViewModel(
                            sessionService: services.sessionService,
                            exerciseService: services.exerciseService
                        )
                        viewModel = vm
                        await vm.loadSession(id: sessionId)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: SessionPlayerViewModel) -> some View {
        if viewModel.isLoading {
            ProgressView("Loading session...")
        } else if let session = viewModel.session {
            SessionPlayerView(session: session)
        } else {
            ContentUnavailableView(
                "Session Not Found",
                systemImage: "exclamationmark.triangle",
                description: Text(viewModel.errorMessage ?? "Unable to load session")
            )
        }
    }
}

#Preview {
    SessionPlayerContainer(sessionId: UUID())
        .environment(AppRouter())
}