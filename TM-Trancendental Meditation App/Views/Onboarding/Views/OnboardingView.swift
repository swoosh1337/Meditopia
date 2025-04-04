import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0
    
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
        )
    ]
    
    var body: some View {
        ZStack {
            Configuration.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Configuration.primaryColor)
                    .padding()
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
                                Button(action: completeOnboarding) {
                                    Text("Get Started")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 220, height: 55)
                                        .background(Configuration.primaryColor)
                                        .cornerRadius(27.5)
                                        .shadow(color: Configuration.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .padding(.top, 50)
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
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasSeenOnboarding = true
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
} 
