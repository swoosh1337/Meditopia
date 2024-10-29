//
//  ContentView.swift
//  TM.io
//
//  Created by Tazi Grigolia on 10/21/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Label("Meditate", systemImage: "timer")
                }

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
            
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book")
                }
            
            StreaksView()
                .tabItem {
                    Label("Streaks", systemImage: "flame")
                }
        }
        .accentColor(.yellow)
        .colorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .modelContainer(for: JournalEntry.self, inMemory: true)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            ContentView()
                .modelContainer(for: JournalEntry.self, inMemory: true)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
