//
//  ContentView.swift
//  TM.io
//
//  Created by Tazi Grigolia on 10/21/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timer")
                }
                .tag(0)
            
            LibraryView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Library")
                }
                .tag(1)
            
            Text("Events")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
                .tag(2)
            
            Text("Profile")
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .background(Color(red: 1.0, green: 1.0, blue: 0.9)) // Slightly yellow background
        .accentColor(Color(red: 0.9, green: 0.8, blue: 0.3)) // Yellowish accent color for selected items
        .edgesIgnoringSafeArea(.all)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
