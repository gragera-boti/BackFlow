import SwiftUI

// MARK: - AppRouter

@MainActor @Observable
final class AppRouter {
    var path = NavigationPath()
    
    func navigate(to destination: AppDestination) {
        path.append(destination)
    }
    
    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
}

// MARK: - AppDestination

enum AppDestination: Hashable {
    case exerciseDetail(exerciseSlug: String)
    case educationDetail(cardId: String)
    case sessionPlayer(sessionId: UUID)
    case settings
    case quickLog
    case walkingLog
    case baselineAssessment
    case redFlags
    case goalAndSchedule
    
    // Add more destinations as needed
}

// MARK: - Environment Key

private struct AppRouterKey: EnvironmentKey {
    static let defaultValue = AppRouter()
}

extension EnvironmentValues {
    var router: AppRouter {
        get { self[AppRouterKey.self] }
        set { self[AppRouterKey.self] = newValue }
    }
}
