import SwiftUI

struct AppContentWrapper<Content: View>: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            if purchaseManager.hasFullAccess {
                // User has access, show app content without the trial banner
                content
                .sheet(isPresented: $showPaywall) {
                    PaywallView(allowDismissal: true)
                }
            } else {
                // User does not have access, show paywall with no way to dismiss it
                PaywallView(allowDismissal: false)
                    .transition(.opacity)
                    .zIndex(100) // Ensure it's above all other content
            }
        }
        .onAppear {
            // Refresh trial status whenever view appears
            purchaseManager.checkTrialStatus()
        }
    }
}

extension View {
    func withPurchaseAccess() -> some View {
        AppContentWrapper {
            self
        }
    }
}

struct AppContentWrapper_Previews: PreviewProvider {
    static var previews: some View {
        AppContentWrapper {
            VStack {
                Text("Your Progress")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("This is the main app content")
                    .font(.title)
                    .padding()
                
                Text("Only visible to users with access")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Configuration.backgroundColor)
        }
    }
} 