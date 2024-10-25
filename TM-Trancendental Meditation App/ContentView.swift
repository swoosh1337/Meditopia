//
//  ContentView.swift
//  TM.io
//
//  Created by Tazi Grigolia on 10/21/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Meditate")
                }
            
            LibraryView()
                .tabItem {
                    Image(systemName: "video")
                    Text("Library")
                }
            
            JournalView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Journal")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .accentColor(.yellow)
        .background(Configuration.backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
