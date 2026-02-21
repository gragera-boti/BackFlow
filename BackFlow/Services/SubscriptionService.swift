import Foundation
import StoreKit

@MainActor
@Observable
class SubscriptionService {
    static let shared = SubscriptionService()
    
    private(set) var isPremium: Bool = false
    private(set) var products: [Product] = []
    private var updateListenerTask: Task<Void, Never>?
    
    private let productIdentifiers: [String] = [
        "com.backflow.premium.monthly",
        "com.backflow.premium.yearly"
    ]
    
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactionUpdates()
        
        Task {
            await loadProducts()
            await checkPremiumStatus()
        }
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIdentifiers)
            print("Loaded \(products.count) products")
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                await checkPremiumStatus()
                return true
            case .unverified:
                return false
            }
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await checkPremiumStatus()
    }
    
    private func checkPremiumStatus() async {
        var hasPremium = false
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID.contains("premium") {
                    hasPremium = true
                    break
                }
            }
        }
        
        isPremium = hasPremium
    }
    
    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await checkPremiumStatus()
                }
            }
        }
    }
}
