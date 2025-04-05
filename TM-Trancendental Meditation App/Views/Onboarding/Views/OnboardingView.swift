import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showStartTrialConfirmation = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "leaf.fill",
            title: "Welcome to Meditopia",
            description: "Start your journey to inner peace with Transcendental Meditation"
        ),
        OnboardingPage(
            image: "heart.fill",
            title: "Track Your Progress",
            description: "Monitor your heart rate and meditation streaks to see your improvement"
        ),
        OnboardingPage(
            image: "book.fill",
            title: "Journal Your Experience",
            description: "Record your thoughts and feelings after each meditation session"
        ),
        OnboardingPage(
            image: "gift.fill",
            title: "Start Your Free Trial",
            description: "7 days of full access - free"
        )
    ]
    
    var body: some View {
        ZStack {
            Configuration.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    // Only show skip button if not on the last page
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            // Skip to last page instead of completing onboarding
                            withAnimation {
                                currentPage = pages.count - 1
                            }
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Configuration.primaryColor)
                        .padding()
                    }
                }
                
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        VStack(spacing: 30) {
                            Image(systemName: pages[index].image)
                                .font(.system(size: 100))
                                .foregroundColor(Configuration.primaryColor)
                                .padding()
                                .shadow(color: Configuration.primaryColor.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            Text(pages[index].title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Configuration.primaryColor)
                                .padding(.bottom, 5)
                            
                            Text(pages[index].description)
                                .font(.system(size: 18, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.black.opacity(0.7))
                                .padding(.horizontal, 40)
                                .lineSpacing(4)
                            
                            if index == pages.count - 1 {
                                // Trial benefits
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("What you'll get:")
                                        .font(.headline)
                                        .foregroundColor(Configuration.textColor)
                                        .padding(.bottom, 4)
                                    
                                    benefitRow(icon: "infinity", text: "Unlimited meditation sessions")
                                    benefitRow(icon: "heart.fill", text: "Real-time heart rate monitoring")
                                    benefitRow(icon: "book.fill", text: "Journal entry tracking")
                                    benefitRow(icon: "flame.fill", text: "Streak and progress tracking")
                                }
                                .padding()
                                .background(Configuration.cardBackgroundColor)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                                
                                // Start free trial button
                                Button(action: {
                                    // Start the trial and complete onboarding
                                    showStartTrialConfirmation = true
                                }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 16))
                                        Text("Start 7-Day Free Trial")
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 280, height: 55)
                                    .background(Configuration.primaryColor)
                                    .cornerRadius(27.5)
                                    .shadow(color: Configuration.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .padding(.top, 30)
                                
                                // Purchase information
                                Text("After trial ends, continue with a one-time purchase of $1.00")
                                    .font(.caption)
                                    .foregroundColor(Configuration.secondaryTextColor)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                    .padding(.top, 12)
                                
                                // Restore purchases
                                Button(action: {
                                    // Attempt to restore purchases
                                    Task {
                                        do {
                                            try await purchaseManager.restorePurchases()
                                            // Only complete onboarding if they actually have a purchase
                                            if purchaseManager.hasFullAccess {
                                                completeOnboarding()
                                            }
                                        } catch {
                                            // Handle error (could add an alert here)
                                            print("Failed to restore: \(error.localizedDescription)")
                                        }
                                    }
                                }) {
                                    Text("Already purchased? Restore here")
                                        .font(.caption)
                                        .foregroundColor(Configuration.primaryColor)
                                        .padding(.top, 8)
                                }
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                Spacer()
            }
        }
        .colorScheme(.light) // Ensure consistent appearance
        .alert("Start Your Free Trial", isPresented: $showStartTrialConfirmation) {
            Button("Start Trial", role: .none) {
                // Start the trial and complete onboarding
                startTrial()
                completeOnboarding()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll get 7 days of unlimited access to all features. No payment required during the trial period.")
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasSeenOnboarding = true
        }
    }
    
    private func startTrial() {
        // Explicitly start the trial
        purchaseManager.startTrial()
    }
    
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(Configuration.primaryColor)
                .font(.system(size: 18))
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Configuration.textColor)
            
            Spacer()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
} 
