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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: JournalEntry.self, inMemory: true)
    }
}
