import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.services) private var services
    @Environment(\.router) private var router
    
    @State private var viewModel: SettingsViewModel?
    @State private var showPaywall = false
    @State private var showResetConfirmation = false
    @State private var showResetOnboardingConfirmation = false
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                SwiftUI.ProgressView()
                    .task {
                        guard let services = services else { return }
                        viewModel = SettingsViewModel(
                            programService: services.programService,
                            subscriptionService: services.subscriptionService
                        )
                        await viewModel?.loadData()
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: SettingsViewModel) -> some View {
        NavigationStack {
            Form {
                // Premium Status
                premiumSection(viewModel: viewModel)
                
                // Profile
                if viewModel.userProfile != nil {
                    profileSection(viewModel: viewModel)
                    notificationSection(viewModel: viewModel)
                }
                
                // Premium Features
                if viewModel.isPremium {
                    premiumFeaturesSection(viewModel: viewModel)
                }
                
                // About
                aboutSection(viewModel: viewModel)
                
                // Developer
                developerSection(viewModel: viewModel)
                
                // Danger Zone
                dangerSection(viewModel: viewModel)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("Reset All Data", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    Task { await viewModel.resetAllData() }
                }
            } message: {
                Text("This will permanently delete all your data. This action cannot be undone.")
            }
            .alert("Reset Onboarding", isPresented: $showResetOnboardingConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    viewModel.resetOnboarding()
                }
            } message: {
                Text("This will reset onboarding and restart the app. Your data will be preserved.")
            }
            .alert("Error", isPresented: errorBinding(viewModel: viewModel)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Section Views
    
    @ViewBuilder
    private func premiumSection(viewModel: SettingsViewModel) -> some View {
        Section {
            if viewModel.isPremium {
                Label("Premium Active", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Theme.Colors.success)
            } else {
                Button(action: { showPaywall = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                            Text("Upgrade to Premium")
                                .font(Theme.Typography.headline)
                            Text("iCloud sync, exports, widgets & more")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func profileSection(viewModel: SettingsViewModel) -> some View {
        Section("Your Plan") {
            LabeledContent("Sessions per week", value: viewModel.sessionsPerWeekDisplay)
            LabeledContent("Equipment", value: viewModel.equipmentDisplay)
            
            Button("Edit Plan Settings") {
                // TODO: Navigate to plan settings
            }
        }
    }
    
    @ViewBuilder
    private func notificationSection(viewModel: SettingsViewModel) -> some View {
        Section("Notifications") {
            if let reminderTime = viewModel.reminderTimeDisplay {
                LabeledContent("Daily Reminder", value: reminderTime)
            } else {
                Text("No reminder set")
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            
            Button("Edit Reminders") {
                // TODO: Navigate to reminder settings
            }
        }
    }
    
    @ViewBuilder
    private func premiumFeaturesSection(viewModel: SettingsViewModel) -> some View {
        Section("Premium Features") {
            Button("iCloud Sync") {
                // TODO: Navigate to cloud sync settings
            }
            
            Button("Export Data") {
                // TODO: Implement export
            }
        }
    }
    
    @ViewBuilder
    private func aboutSection(viewModel: SettingsViewModel) -> some View {
        Section("About") {
            LabeledContent("Version", value: viewModel.appVersion)
            
            Button("Privacy Policy") {
                // TODO: Navigate to privacy policy
            }
            
            Button("Medical Disclaimer") {
                // TODO: Navigate to disclaimer
            }
            
            Link("Support & Feedback", destination: URL(string: "mailto:\(viewModel.supportEmail)")!)
        }
    }
    
    @ViewBuilder
    private func developerSection(viewModel: SettingsViewModel) -> some View {
        Section("Developer") {
            Button("Reset Onboarding") {
                showResetOnboardingConfirmation = true
            }
            
            LabeledContent("App Version", value: viewModel.appVersion)
            LabeledContent("Build", value: viewModel.buildNumber)
        }
    }
    
    @ViewBuilder
    private func dangerSection(viewModel: SettingsViewModel) -> some View {
        Section {
            Button("Reset All Data", role: .destructive) {
                showResetConfirmation = true
            }
        }
    }
    
    private func errorBinding(viewModel: SettingsViewModel) -> Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )
    }
}

// MARK: - Mock Service
private struct MockSubscriptionService: SubscriptionServiceProtocol {
    func checkPremiumStatus() async -> Bool {
        return false
    }
    
    func purchasePremium() async throws {
        // Mock implementation
    }
    
    func purchaseMonthly() async throws {
        // Mock implementation
    }
    
    func purchaseYearly() async throws {
        // Mock implementation
    }
    
    func restorePurchases() async throws {
        // Mock implementation
    }
}

#Preview {
    SettingsView()
        .environment(AppRouter())
}