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
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some View {
        TabView {
            AppContentWrapper {
                TimerView()
            }
            .tabItem {
                Label("Meditate", systemImage: "timer")
            }
            
            // LibraryView()
            //     .tabItem {
            //         Label("Library", systemImage: "books.vertical")
            //     }
            
            AppContentWrapper {
                JournalView()
            }
            .tabItem {
                Label("Journal", systemImage: "book")
            }
            
            // StreaksView with built-in purchase access control and trial banner
            StreaksView()
                .tabItem {
                    Label("Streaks", systemImage: "flame")
                }
        }
        .accentColor(Configuration.primaryColor)
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
