//
//  TM_Trancendental_Meditation_AppApp.swift
//  TM-Trancendental Meditation App
//
//  Created by Tazi Grigolia on 10/23/24.
//

import SwiftUI
import SwiftData

@main
struct TM_Trancendental_Meditation_AppApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([JournalEntry.self])
            let modelConfiguration = ModelConfiguration("JournalDatabase", schema: schema)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
