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
                    .foregroundColor(.yellow)
                    .padding()
                }
                
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image(systemName: pages[index].image)
                                .font(.system(size: 100))
                                .foregroundColor(.yellow)
                                .padding()
                            
                            Text(pages[index].title)
                                .font(.title)
                                .bold()
                                .foregroundColor(Configuration.textColor)
                            
                            Text(pages[index].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Configuration.secondaryTextColor)
                                .padding(.horizontal, 40)
                            
                            if index == pages.count - 1 {
                                Button(action: completeOnboarding) {
                                    Text("Get Started")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 200, height: 50)
                                        .background(Color.yellow)
                                        .cornerRadius(25)
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
