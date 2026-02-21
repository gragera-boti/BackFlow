import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.services) private var services
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var offerings: Offerings?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xLarge) {
                    // Header
                    headerSection
                    
                    // Benefits
                    benefitsSection
                    
                    // Packages
                    if let offering = offerings?.current {
                        packagesSection(offering: offering)
                    } else if isLoading {
                        SwiftUI.ProgressView()
                            .padding(Theme.Spacing.xxLarge)
                    }
                    
                    // Footer
                    footerSection
                }
                .padding(Theme.Spacing.medium)
            }
            .navigationTitle("BackFlow Premium")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .task {
                await loadOfferings()
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)
            
            Text("Unlock Your Full Recovery")
                .font(Theme.Typography.title)
                .multilineTextAlignment(.center)
            
            Text("Get the most out of your rehab journey")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, Theme.Spacing.large)
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            BenefitRow(
                icon: "icloud",
                title: "iCloud Sync",
                description: "Access your data on all your devices"
            )
            
            BenefitRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Advanced Analytics",
                description: "Detailed progress insights and trends"
            )
            
            BenefitRow(
                icon: "square.and.arrow.up",
                title: "Data Export",
                description: "Export your data as CSV or PDF"
            )
            
            BenefitRow(
                icon: "widget.medium",
                title: "Home Screen Widgets",
                description: "Quick access to today's exercises"
            )
            
            BenefitRow(
                icon: "gear",
                title: "Custom Settings",
                description: "Fine-tune progression thresholds"
            )
        }
    }
    
    @ViewBuilder
    private func packagesSection(offering: Offering) -> some View {
        VStack(spacing: Theme.Spacing.medium) {
            // Yearly package (recommended)
            if let yearlyPackage = offering.availablePackages.first(where: { 
                $0.storeProduct.productIdentifier.contains("yearly") 
            }) {
                PackageCard(
                    package: yearlyPackage,
                    isRecommended: true,
                    onPurchase: { await purchasePackage(yearlyPackage) }
                )
            }
            
            // Monthly package
            if let monthlyPackage = offering.availablePackages.first(where: { 
                $0.storeProduct.productIdentifier.contains("monthly") 
            }) {
                PackageCard(
                    package: monthlyPackage,
                    isRecommended: false,
                    onPurchase: { await purchasePackage(monthlyPackage) }
                )
            }
            
            // Restore button
            Button(action: { Task { await restorePurchases() } }) {
                Text("Restore Purchases")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(Theme.Colors.primary)
            }
            .padding(.top, Theme.Spacing.small)
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: Theme.Spacing.xSmall) {
            Text("Subscriptions automatically renew unless cancelled")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
            
            HStack(spacing: Theme.Spacing.medium) {
                Link("Privacy Policy", destination: URL(string: "https://backflow.app/privacy")!)
                Text("•")
                Link("Terms of Service", destination: URL(string: "https://backflow.app/terms")!)
            }
            .font(Theme.Typography.caption)
            .foregroundStyle(Theme.Colors.primary)
        }
        .padding(.top, Theme.Spacing.large)
    }
    
    // MARK: - Actions
    
    private func loadOfferings() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            errorMessage = "Failed to load subscription options"
        }
    }
    
    private func purchasePackage(_ package: Package) async {
        isLoading = true
        defer { isLoading = false }
        
        guard let subscriptionService = services?.subscriptionService as? RevenueCatSubscriptionService else {
            errorMessage = "Subscription service unavailable"
            return
        }
        
        do {
            if package.storeProduct.productIdentifier.contains("yearly") {
                try await subscriptionService.purchaseYearly()
            } else {
                try await subscriptionService.purchaseMonthly()
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let subscriptionService = services?.subscriptionService else {
            errorMessage = "Subscription service unavailable"
            return
        }
        
        do {
            try await subscriptionService.restorePurchases()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Supporting Views

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                Text(title)
                    .font(Theme.Typography.headline)
                Text(description)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            
            Spacer()
        }
    }
}

struct PackageCard: View {
    let package: Package
    let isRecommended: Bool
    let onPurchase: () async -> Void
    
    @State private var isPurchasing = false
    
    private var periodText: String {
        switch package.storeProduct.subscriptionPeriod?.unit {
        case .month: return "per month"
        case .year: return "per year"
        default: return ""
        }
    }
    
    private var savingsText: String? {
        guard isRecommended else { return nil }
        
        // For yearly plans, show estimated savings
        if package.storeProduct.productIdentifier.contains("yearly") {
            // Estimate 20% savings for yearly plans
            return "Save 20%"
        }
        
        return nil
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.small) {
            if isRecommended {
                Text("RECOMMENDED")
                    .font(Theme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Theme.Spacing.small)
                    .padding(.vertical, Theme.Spacing.xxSmall)
                    .background(Theme.Colors.primary)
                    .cornerRadius(Theme.CornerRadius.small)
            }
            
            VStack(spacing: Theme.Spacing.xSmall) {
                Text(package.storeProduct.localizedTitle)
                    .font(Theme.Typography.headline)
                
                Text(package.storeProduct.localizedPriceString)
                    .font(Theme.Typography.title2)
                    .fontWeight(.bold)
                
                Text(periodText)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
                
                if let savings = savingsText {
                    Text(savings)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.success)
                }
            }
            
            Button(action: {
                isPurchasing = true
                Task {
                    await onPurchase()
                    isPurchasing = false
                }
            }) {
                if isPurchasing {
                    SwiftUI.ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                } else {
                    Text("Subscribe")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.medium)
            .background(isRecommended ? Theme.Colors.primary : Theme.Colors.primary.opacity(0.2))
            .foregroundStyle(isRecommended ? .white : Theme.Colors.primary)
            .cornerRadius(Theme.CornerRadius.medium)
            .disabled(isPurchasing)
        }
        .padding(Theme.Spacing.medium)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                .stroke(isRecommended ? Theme.Colors.primary : Color.gray.opacity(0.3), lineWidth: 2)
        )
        .cornerRadius(Theme.CornerRadius.large)
    }
}

#Preview {
    PaywallView()
}