import Foundation
import RevenueCat
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "RevenueCatSubscriptionService")

@MainActor
final class RevenueCatSubscriptionService: SubscriptionServiceProtocol {
    static let shared = RevenueCatSubscriptionService()
    
    // MARK: - Constants
    private var apiKey: String {
        #if DEBUG
        return "appl_RXHcJwOudlHkCnQGUzrHnTwLNXt" // Test store API key
        #else
        return "appl_PRODUCTION_KEY_TO_BE_ADDED" // Production API key
        #endif
    }
    
    private let monthlyProductId = "com.albgra.BackFlow.premium.monthly"
    private let yearlyProductId = "com.albgra.BackFlow.premium.yearly"
    
    // MARK: - State
    @Published private(set) var isPremium: Bool = false
    @Published private(set) var offerings: Offerings?
    @Published private(set) var customerInfo: CustomerInfo?
    
    // MARK: - Initialization
    init() {
        Task {
            await configure()
        }
    }
    
    // MARK: - Configuration
    private func configure() async {
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.simulatesAskToBuyInSandbox = true
        #else
        Purchases.logLevel = .info
        #endif
        
        Purchases.configure(withAPIKey: apiKey)
        
        // Enable StoreKit 2 if available (iOS 15+)
        if #available(iOS 15.0, *) {
            Purchases.shared.purchasesAreCompletedBy = .revenueCat
        }
        
        // Set user ID if available
        // Purchases.shared.logIn(...)
        
        // Fetch initial data
        await refreshCustomerInfo()
        await fetchOfferings()
    }
    
    // MARK: - SubscriptionServiceProtocol
    
    func checkPremiumStatus() async -> Bool {
        await refreshCustomerInfo()
        return isPremium
    }
    
    func purchasePremium() async throws {
        guard let offering = offerings?.current else {
            throw SubscriptionError.noOfferings
        }
        
        // Default to yearly package
        guard let package = offering.availablePackages.first(where: { $0.storeProduct.productIdentifier == yearlyProductId })
                ?? offering.availablePackages.first else {
            throw SubscriptionError.noPackages
        }
        
        try await purchasePackage(package)
    }
    
    // MARK: - Public Methods
    
    func purchaseMonthly() async throws {
        guard let offering = offerings?.current,
              let package = offering.availablePackages.first(where: { 
                  $0.storeProduct.productIdentifier == monthlyProductId 
              }) else {
            throw SubscriptionError.packageNotFound(monthlyProductId)
        }
        
        try await purchasePackage(package)
    }
    
    func purchaseYearly() async throws {
        guard let offering = offerings?.current,
              let package = offering.availablePackages.first(where: { 
                  $0.storeProduct.productIdentifier == yearlyProductId 
              }) else {
            throw SubscriptionError.packageNotFound(yearlyProductId)
        }
        
        try await purchasePackage(package)
    }
    
    func restorePurchases() async throws {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            await updateCustomerInfo(customerInfo)
            logger.info("Purchases restored successfully")
        } catch {
            logger.error("Failed to restore purchases: \(error.localizedDescription)")
            throw SubscriptionError.restoreFailed(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func purchasePackage(_ package: Package) async throws {
        do {
            let result = try await Purchases.shared.purchase(package: package)
            await updateCustomerInfo(result.customerInfo)
            
            if !result.userCancelled {
                logger.info("Purchase successful: \(package.storeProduct.productIdentifier)")
            }
        } catch {
            logger.error("Purchase failed: \(error.localizedDescription)")
            throw SubscriptionError.purchaseFailed(error)
        }
    }
    
    private func refreshCustomerInfo() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await updateCustomerInfo(customerInfo)
        } catch {
            logger.error("Failed to fetch customer info: \(error.localizedDescription)")
        }
    }
    
    private func fetchOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            self.offerings = offerings
            logger.info("Fetched offerings: \(offerings.current?.identifier ?? "none")")
        } catch {
            logger.error("Failed to fetch offerings: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func updateCustomerInfo(_ customerInfo: CustomerInfo) {
        self.customerInfo = customerInfo
        self.isPremium = !customerInfo.entitlements.active.isEmpty
        logger.info("Premium status: \(self.isPremium)")
    }
}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case noOfferings
    case noPackages
    case packageNotFound(String)
    case purchaseFailed(Error)
    case restoreFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .noOfferings:
            return "No subscription offerings available"
        case .noPackages:
            return "No subscription packages available"
        case .packageNotFound(let id):
            return "Subscription package not found: \(id)"
        case .purchaseFailed(let error):
            return "Purchase failed: \(error.localizedDescription)"
        case .restoreFailed(let error):
            return "Restore failed: \(error.localizedDescription)"
        }
    }
}