import StoreKit
import SwiftUI

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    // Product identifiers
    private let fullAccessProductID = "com.yourcompany.meditationapp.fullaccess"
    
    // UserDefaults keys
    private let hasLaunchedBeforeKey = "hasLaunchedBefore"
    private let trialEndDateKey = "trialEndDate"
    
    // Published properties for UI binding
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isTrialActive = false
    @Published var trialEndDate: Date?
    @Published var isPurchasing = false
    
    // Purchase status to check in various parts of the app
    var hasFullAccess: Bool {
        // User has full access if they've purchased the product
        if purchasedProductIDs.contains(fullAccessProductID) {
            return true
        }
        
        // Or if they're in an active trial period
        return isTrialActive
    }
    
    private init() {
        // Check trial status immediately
        checkTrialStatus()
        
        // Load products and purchase status
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
        
        // Listen for transactions
        listenForTransactions()
    }
    
    // MARK: - Trial Management
    
    func checkTrialStatus() {
        // First launch handling - start the trial for new users
        if !UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey) {
            startTrial()
        }
        
        // Check if trial is still active
        if let storedEndDate = UserDefaults.standard.object(forKey: trialEndDateKey) as? Date {
            self.trialEndDate = storedEndDate
            self.isTrialActive = Date() < storedEndDate
            
            if isTrialActive {
                let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: storedEndDate).day ?? 0
                print("Trial is active. Days remaining: \(daysLeft)")
            } else {
                print("Trial has expired on: \(storedEndDate)")
            }
        } else {
            self.isTrialActive = false
            print("No trial information found")
        }
        
        // Force UI update
        objectWillChange.send()
    }
    
    /// Explicitly start a trial period, calculating end date
    func startTrial() {
        let trialEnd = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        UserDefaults.standard.set(trialEnd, forKey: trialEndDateKey)
        UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
        
        self.trialEndDate = trialEnd
        self.isTrialActive = true
        
        print("Trial started, ending on: \(trialEnd)")
        objectWillChange.send()
    }
    
    /// For testing: Reset the trial to start again
    func resetTrial() {
        UserDefaults.standard.removeObject(forKey: hasLaunchedBeforeKey)
        UserDefaults.standard.removeObject(forKey: trialEndDateKey)
        checkTrialStatus()
    }
    
    /// For testing: End the trial immediately
    func endTrialImmediately() {
        UserDefaults.standard.set(Date().addingTimeInterval(-1), forKey: trialEndDateKey)
        checkTrialStatus()
    }
    
    // MARK: - StoreKit Product Management
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: [fullAccessProductID])
            print("Successfully loaded \(products.count) products")
            for product in products {
                print("Product: \(product.displayName) (\(product.displayPrice))")
            }
        } catch {
            print("Failed to load products: \(error.localizedDescription)")
        }
    }
    
    func updatePurchasedProducts() async {
        // Clear existing entitlements
        purchasedProductIDs.removeAll()
        
        // Get the most recent transaction for each product
        for await result in StoreKit.Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                print("Unverified transaction")
                continue
            }
            
            purchasedProductIDs.insert(transaction.productID)
            print("Found purchased product: \(transaction.productID)")
        }
    }
    
    // MARK: - Transaction Handling
    
    func listenForTransactions() {
        // Start a transaction listener as early as possible
        Task.detached(priority: .background) {
            for await result in StoreKit.Transaction.updates {
                // Handle transaction here
                if case .verified(let transaction) = result {
                    await self.handleVerifiedTransaction(transaction)
                } else {
                    print("Unverified transaction update received")
                }
            }
        }
    }
    
    func handleVerifiedTransaction(_ transaction: StoreKit.Transaction) async {
        // Add to our list of purchased products
        purchasedProductIDs.insert(transaction.productID)
        print("Transaction verified for product: \(transaction.productID)")
        
        // Always finish a transaction
        await transaction.finish()
        print("Transaction finalized")
    }
    
    // MARK: - Purchase Flow
    
    func purchase(product: Product) async throws {
        isPurchasing = true
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verificationResult):
                guard case .verified(let transaction) = verificationResult else {
                    isPurchasing = false
                    throw PurchaseError.failedVerification
                }
                
                await handleVerifiedTransaction(transaction)
                print("Successfully purchased: \(product.displayName)")
                
            case .userCancelled:
                isPurchasing = false
                throw PurchaseError.userCancelled
                
            case .pending:
                isPurchasing = false
                throw PurchaseError.pending
                
            @unknown default:
                isPurchasing = false
                throw PurchaseError.unknown
            }
        } catch {
            isPurchasing = false
            print("Purchase failed: \(error.localizedDescription)")
            throw error
        }
        
        isPurchasing = false
    }
    
    func restorePurchases() async throws {
        isPurchasing = true
        
        do {
            // This will automatically update purchasedProductIDs through the transaction listener
            try await AppStore.sync()
            print("Purchases restored successfully")
        } catch {
            print("Failed to restore purchases: \(error.localizedDescription)")
            throw error
        }
        
        isPurchasing = false
    }
}

enum PurchaseError: Error, LocalizedError {
    case failedVerification
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .failedVerification: return "Purchase verification failed"
        case .userCancelled: return "Purchase was cancelled"
        case .pending: return "Purchase is pending approval"
        case .unknown: return "An unknown error occurred"
        }
    }
} 