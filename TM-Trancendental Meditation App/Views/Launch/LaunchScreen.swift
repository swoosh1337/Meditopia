import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Configuration.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.yellow)
                
                Text("Relax Your Mind")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
        .colorScheme(.light)
    }
}

#Preview {
    Group {
        LaunchScreen()
            .previewDisplayName("Light Mode")
        
        LaunchScreen()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode (will look same as light)")
    }
} 