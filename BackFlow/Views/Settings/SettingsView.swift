import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var subscriptionService = SubscriptionService.shared
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Premium Status
                Section {
                    if subscriptionService.isPremium {
                        Label("Premium Active", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Button(action: { showPaywall = true }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Upgrade to Premium")
                                        .font(.headline)
                                    Text("iCloud sync, exports, widgets & more")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                }
                
                // Profile
                if let profile = profiles.first {
                    Section("Your Plan") {
                        LabeledContent("Sessions per week", value: "\(profile.sessionsPerWeek)")
                        LabeledContent("Equipment", value: profile.equipment.joined(separator: ", "))
                        
                        NavigationLink("Edit Plan Settings") {
                            Text("Plan settings coming soon")
                        }
                    }
                    
                    Section("Notifications") {
                        if let reminderTime = profile.reminderTime {
                            LabeledContent("Daily Reminder") {
                                Text("\(reminderTime.hour ?? 9):\(String(format: "%02d", reminderTime.minute ?? 0))")
                            }
                        } else {
                            Text("No reminder set")
                                .foregroundStyle(.secondary)
                        }
                        
                        NavigationLink("Edit Reminders") {
                            Text("Reminder settings coming soon")
                        }
                    }
                }
                
                // Premium Features
                if subscriptionService.isPremium {
                    Section("Premium Features") {
                        NavigationLink("iCloud Sync") {
                            CloudSyncSettingsView()
                        }
                        
                        Button("Export Data") {
                            // TODO: Export
                        }
                    }
                }
                
                // About
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                    
                    NavigationLink("Medical Disclaimer") {
                        DisclaimerView(onContinue: {})
                    }
                    
                    Link("Support & Feedback", destination: URL(string: "mailto:support@backflow.app")!)
                }
                
                // Danger Zone
                Section {
                    Button("Reset All Data", role: .destructive) {
                        // TODO: Confirm and reset
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

struct CloudSyncSettingsView: View {
    @Query private var profiles: [UserProfile]
    @State private var cloudSyncEnabled = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable iCloud Sync", isOn: $cloudSyncEnabled)
                
                Text("Sync your data across all your devices using iCloud.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if cloudSyncEnabled {
                Section("Status") {
                    Label("Synced", systemImage: "checkmark.icloud")
                        .foregroundStyle(.green)
                }
            }
        }
        .navigationTitle("iCloud Sync")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("""
                BackFlow is committed to protecting your privacy.
                
                **Data Storage**
                All your health data is stored locally on your device. We do not collect, transmit, or store your personal health information on any server.
                
                **iCloud Sync (Premium)**
                If you enable iCloud sync, your data is synced to your private iCloud account. This data is end-to-end encrypted and only accessible to you.
                
                **Analytics**
                We do not use any third-party analytics or tracking tools.
                
                **Subscription Data**
                Apple manages all subscription transactions. We do not have access to your payment information.
                
                **Contact**
                For questions, email: privacy@backflow.app
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subscriptionService = SubscriptionService.shared
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    
    let features = [
        ("icloud", "iCloud Sync", "Sync across all devices"),
        ("chart.xyaxis.line", "Advanced Analytics", "Detailed progress charts"),
        ("square.and.arrow.up", "Export Data", "CSV & PDF exports"),
        ("slider.horizontal.3", "Custom Settings", "Pain thresholds & more"),
        ("app.badge", "Widgets", "Track from home screen")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.yellow)
                        
                        Text("Premium Features")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(features, id: \.0) { icon, title, description in
                            HStack(spacing: 16) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(title)
                                        .font(.headline)
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    VStack(spacing: 16) {
                        ForEach(subscriptionService.products, id: \.id) { product in
                            Button(action: { selectedProduct = product }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.displayName)
                                            .font(.headline)
                                        Text(product.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(product.displayPrice)
                                        .font(.headline)
                                }
                                .padding()
                                .background(selectedProduct?.id == product.id ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        if let product = selectedProduct {
                            Button(action: { purchaseProduct(product) }) {
                                if isPurchasing {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                } else {
                                    Text("Subscribe")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundStyle(.white)
                                        .cornerRadius(12)
                                }
                            }
                            .disabled(isPurchasing)
                        }
                        
                        Button("Restore Purchases") {
                            Task {
                                await subscriptionService.restorePurchases()
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func purchaseProduct(_ product: Product) {
        isPurchasing = true
        Task {
            do {
                let success = try await subscriptionService.purchase(product)
                isPurchasing = false
                if success {
                    dismiss()
                }
            } catch {
                isPurchasing = false
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
