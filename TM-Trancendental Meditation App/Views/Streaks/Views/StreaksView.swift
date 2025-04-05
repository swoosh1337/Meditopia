import SwiftUI

struct StreaksView: View {
    @StateObject private var viewModel = StreaksViewModel()
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        Group {
            if purchaseManager.hasFullAccess {
                // User has access, show the Streaks view with trial banner
                NavigationView {
                    ZStack {
                        VStack {
                            ZStack(alignment: .center) {
                                // Title text positioned to work with the trial banner
                                Text("Your Progress")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.top)
                            
                            ScrollView {
                                VStack(spacing: 20) {
                                    streakCards
                                    CalendarView(meditationDates: $viewModel.streakData.meditationDates)
                                    weeklyProgressView
                                    totalMeditationTimeView
                                }
                                .padding()
                            }
                        }
                        .background(Configuration.backgroundColor)
                        
                        // Trial banner only in StreaksView
                        if purchaseManager.isTrialActive {
                            VStack {
                                HStack {
                                    Spacer()
                                    TrialBannerView(onUpgradeTapped: {
                                        showPaywall = true
                                    })
                                }
                                .padding(.trailing, 45)
                                .padding(.top, 12)
                                
                                Spacer()
                            }
                        }
                    }
                    .sheet(isPresented: $showPaywall) {
                        PaywallView(allowDismissal: true)
                    }
                }
                .onAppear(perform: viewModel.loadData)
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
    
    private var streakCards: some View {
        HStack(spacing: 20) {
            StreakCard(title: "Current Streak", value: viewModel.streakData.currentStreak)
            StreakCard(title: "Best Streak", value: viewModel.streakData.bestStreak)
        }
    }
    
    private var weeklyProgressView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This Week's Progress")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                ForEach(0..<7) { day in
                    VStack {
                        Circle()
                            .fill(viewModel.didMeditateOnDay(day) ? Configuration.primaryColor : Color.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                        Text(viewModel.dayAbbreviation(for: day))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Configuration.primaryColor.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var totalMeditationTimeView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total Meditation Time")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "hourglass")
                    .foregroundColor(Configuration.primaryColor)
                Text(viewModel.formatTotalTime(viewModel.streakData.totalMeditationTime))
                    .font(.headline)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Configuration.primaryColor.opacity(0.1))
        .cornerRadius(15)
    }
}

struct StreaksView_Previews: PreviewProvider {
    static var previews: some View {
        StreaksView()
    }
}
