import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Configuration.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "leaf.fill")  // Or your app icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.yellow)
                
                Text("Relax Your Mind")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    LaunchScreen()
} 