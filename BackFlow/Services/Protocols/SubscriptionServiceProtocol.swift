import Foundation

// MARK: - Service Protocol

protocol SubscriptionServiceProtocol {
    func checkPremiumStatus() async -> Bool
    func purchasePremium() async throws
    func purchaseMonthly() async throws
    func purchaseYearly() async throws
    func restorePurchases() async throws
}