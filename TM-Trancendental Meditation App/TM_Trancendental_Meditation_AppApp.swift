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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: JournalEntry.self)
    }
}
