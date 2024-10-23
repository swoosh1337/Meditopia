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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
