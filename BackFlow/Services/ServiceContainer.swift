import SwiftUI
import SwiftData

// MARK: - Service Container

@MainActor
final class ServiceContainer {
    let programService: ProgramServiceProtocol
    let sessionService: SessionServiceProtocol
    let exerciseService: ExerciseServiceProtocol
    let educationService: EducationServiceProtocol
    let walkingService: WalkingServiceProtocol
    let subscriptionService: SubscriptionServiceProtocol
    
    init(modelContext: ModelContext) {
        self.programService = ProgramService(modelContext: modelContext)
        self.sessionService = SessionService(modelContext: modelContext)
        self.exerciseService = ExerciseService(modelContext: modelContext)
        self.educationService = EducationService(modelContext: modelContext)
        self.walkingService = WalkingService(modelContext: modelContext)
        self.subscriptionService = RevenueCatSubscriptionService.shared
    }
}

// MARK: - Environment Key

private struct ServiceContainerKey: EnvironmentKey {
    static let defaultValue: ServiceContainer? = nil
}

extension EnvironmentValues {
    var services: ServiceContainer? {
        get { self[ServiceContainerKey.self] }
        set { self[ServiceContainerKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func serviceContainer(_ container: ServiceContainer) -> some View {
        environment(\.services, container)
    }
}
