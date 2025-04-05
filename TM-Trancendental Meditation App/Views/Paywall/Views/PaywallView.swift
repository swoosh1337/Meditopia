import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var errorMessage: String?
    @State private var showError = false
    @Environment(\.dismiss) private var dismiss
    
    // Whether the view can be dismissed (false for expired trials)
    var allowDismissal: Bool = true
    
    var body: some View {
        ZStack {
            Configuration.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header section
                    VStack(spacing: 16) {
                        Image(systemName: "leaf.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .foregroundColor(Configuration.primaryColor)
                        
                        if let endDate = purchaseManager.trialEndDate, Date() > endDate {
                            // Trial has expired message
                            Text("Your Trial Has Ended")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Configuration.textColor)
                            
                            Text("Purchase now to continue your meditation journey")
                                .font(.body)
                                .foregroundColor(Configuration.secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            // Add a label describing what happens after purchase
                            Text("One-time payment - No subscription required")
                                .font(.caption)
                                .foregroundColor(Configuration.primaryColor)
                                .padding(.top, 8)
                        } else {
                            // Standard unlock message
                            Text("Unlock Full Access")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Configuration.textColor)
                            
                            Text("Continue your meditation journey with unlimited access")
                                .font(.body)
                                .foregroundColor(Configuration.secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Benefits section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Benefits")
                            .font(.headline)
                            .foregroundColor(Configuration.textColor)
                            .padding(.leading)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            benefitRow(icon: "infinity", text: "Unlimited meditation sessions")
                            benefitRow(icon: "heart.fill", text: "Real-time heart rate monitoring")
                            benefitRow(icon: "book.fill", text: "Journal entry tracking")
                            benefitRow(icon: "flame.fill", text: "Streak and progress tracking")
                        }
                        .padding()
                        .background(Configuration.cardBackgroundColor)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Trial status section (if applicable)
                    if let endDate = purchaseManager.trialEndDate, purchaseManager.isTrialActive {
                        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
                        TrialStatusView(daysLeft: daysLeft)
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Purchase buttons
                    VStack(spacing: 12) {
                        if purchaseManager.products.isEmpty {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                                .padding()
                            
                            Text("Loading...")
                                .font(.subheadline)
                                .foregroundColor(Configuration.secondaryTextColor)
                        } else if let product = purchaseManager.products.first {
                            Button {
                                Task {
                                    do {
                                        try await purchaseManager.purchase(product: product)
                                    } catch {
                                        errorMessage = error.localizedDescription
                                        showError = true
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Continue for")
                                    Text(product.displayPrice)
                                        .fontWeight(.bold)
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    purchaseManager.isPurchasing ? 
                                    Configuration.primaryColor.opacity(0.6) : 
                                    Configuration.primaryColor
                                )
                                .cornerRadius(12)
                                .overlay(
                                    Group {
                                        if purchaseManager.isPurchasing {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        }
                                    }
                                )
                            }
                            .disabled(purchaseManager.isPurchasing)
                            
                            Button {
                                Task {
                                    do {
                                        try await purchaseManager.restorePurchases()
                                    } catch {
                                        errorMessage = error.localizedDescription
                                        showError = true
                                    }
                                }
                            } label: {
                                Text("Restore Purchases")
                                    .font(.subheadline)
                                    .foregroundColor(Configuration.primaryColor)
                            }
                            .padding(.vertical, 8)
                            .disabled(purchaseManager.isPurchasing)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("Purchase Error", isPresented: $showError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(errorMessage ?? "Unknown error occurred")
        })
        .toolbar {
            if allowDismissal {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        // For testing purposes in development
        #if DEBUG
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Button("Reset Trial") {
                        purchaseManager.resetTrial()
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    
                    Button("End Trial") {
                        purchaseManager.endTrialImmediately()
                    }
                    .padding(8)
                    .background(Color.red.opacity(0.7))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }
                .padding()
            }
        )
        #endif
    }
    
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(Configuration.primaryColor)
                .font(.system(size: 20))
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(Configuration.textColor)
            
            Spacer()
        }
    }
}

struct TrialStatusView: View {
    let daysLeft: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Your Free Trial")
                .font(.headline)
                .foregroundColor(Configuration.textColor)
            
            HStack(spacing: 4) {
                Text("\(daysLeft)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Configuration.primaryColor)
                
                Text("days left")
                    .font(.body)
                    .foregroundColor(Configuration.secondaryTextColor)
                    .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
            }
            
            Text("Enjoy full access during your trial period")
                .font(.subheadline)
                .foregroundColor(Configuration.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Configuration.primaryColor.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
            .previewDisplayName("Light Mode")
        
        PaywallView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
} 