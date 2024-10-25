import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Configuration.backgroundColor.edgesIgnoringSafeArea(.all)
                
                // Your existing Profile view content goes here
                VStack {
                    // Profile information, settings, etc.
                }
            }
            .navigationTitle("Profile")
        }
        .accentColor(.yellow)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
