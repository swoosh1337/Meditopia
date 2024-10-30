import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Configuration.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                    
                    Text("Relax Your Mind")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .colorScheme(.light)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SplashScreen()
                .previewDisplayName("Light Mode")
            
            SplashScreen()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode (will look same as light)")
        }
    }
}
