import SwiftUI

struct TrialBannerView: View {
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @State private var isExpanded = false
    @State private var isVisible = true
    var showUpgradeButton: Bool = true
    var onUpgradeTapped: (() -> Void)?
    
    var body: some View {
        if let endDate = purchaseManager.trialEndDate, purchaseManager.isTrialActive, isVisible {
            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
            
            // Determine if this is critical (2 days or less)
            let isCritical = daysLeft <= 2
            
            // Compact but readable design
            HStack(spacing: 4) {
                if !isExpanded {
                    // Compact indicator with days left
                    Text("\(daysLeft)d")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                else {
                    // Expanded view
                    Image(systemName: isCritical ? "exclamationmark.triangle" : "clock")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                    
                    Text(daysLeft == 1 ? "Last day" : "\(daysLeft) days left")
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                    
                    if showUpgradeButton {
                        Button(action: {
                            onUpgradeTapped?()
                        }) {
                            Text("Upgrade")
                                .font(.system(size: 11, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                        .padding(.leading, 4)
                    }
                    
                    Button(action: {
                        withAnimation {
                            isVisible = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.leading, 2)
                }
            }
            .padding(.horizontal, isExpanded ? 8 : 6)
            .padding(.vertical, 4)
            .frame(height: 22)
            .background(
                Capsule()
                    .fill(isCritical ? Color.red.opacity(0.8) : Configuration.primaryColor.opacity(0.8))
            )
            .animation(.easeInOut(duration: 0.2), value: isExpanded)
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            .onAppear {
                // Automatically reset visibility when the view appears
                isVisible = true
                // Start with collapsed state
                isExpanded = false
            }
        } else {
            EmptyView()
        }
    }
}

struct TrialBannerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                Text("Your Progress")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Spacer()
                
                TrialBannerView(onUpgradeTapped: {})
            }
            .padding()
            
            Spacer()
        }
        .background(Configuration.backgroundColor)
        .previewDisplayName("With Trial Active")
    }
} 