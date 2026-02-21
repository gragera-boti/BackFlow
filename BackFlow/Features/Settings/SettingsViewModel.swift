import Foundation
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "SettingsViewModel")

@MainActor @Observable
final class SettingsViewModel {
    // MARK: - Published State
    private(set) var userProfile: UserProfile?
    private(set) var isPremium: Bool = false
    
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let programService: ProgramServiceProtocol
    private let subscriptionService: SubscriptionServiceProtocol
    
    // MARK: - Constants
    let appVersion: String = "1.0.0"
    let supportEmail: String = "support@backflow.app"
    
    // MARK: - Initialization
    init(
        programService: ProgramServiceProtocol,
        subscriptionService: SubscriptionServiceProtocol
    ) {
        self.programService = programService
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - Computed Properties
    var sessionsPerWeekDisplay: String {
        guard let profile = userProfile else { return "Not set" }
        return "\(profile.sessionsPerWeek)"
    }
    
    var equipmentDisplay: String {
        guard let profile = userProfile else { return "None" }
        return profile.equipment.isEmpty ? "None" : profile.equipment.joined(separator: ", ")
    }
    
    var reminderTimeDisplay: String? {
        guard let profile = userProfile,
              let hour = profile.reminderHour,
              let minute = profile.reminderMinute else { return nil }
        
        return "\(hour):\(String(format: "%02d", minute))"
    }
    
    var hasReminder: Bool {
        return userProfile?.reminderHour != nil
    }
    
    var isCloudSyncEnabled: Bool {
        return userProfile?.cloudSyncEnabled ?? false
    }
    
    // MARK: - Actions
    func loadData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // TODO: Need to fetch user profile properly
            // For now, just check premium status
            isPremium = await subscriptionService.checkPremiumStatus()
            
            logger.info("Loaded settings data")
        } catch {
            logger.error("Error loading settings: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleCloudSync() async {
        guard let profile = userProfile else { return }
        
        // TODO: Update profile cloud sync setting
        profile.cloudSyncEnabled.toggle()
        
        do {
            try await programService.updateProfile(profile)
            logger.info("Updated cloud sync: \(profile.cloudSyncEnabled)")
        } catch {
            logger.error("Failed to update cloud sync: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    func resetAllData() async {
        // TODO: Implement data reset
        logger.warning("Reset all data requested")
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// SubscriptionServiceProtocol moved to its own file

// Add to ProgramServiceProtocol
extension ProgramServiceProtocol {
    func updateProfile(_ profile: UserProfile) async throws {
        // TODO: Implement
    }
}