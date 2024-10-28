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
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Failed to create ModelContainer: \(error)")
            print("Detailed error: \(String(describing: error))")
            fatalError("Could not initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}

enum JournalEntryMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] = [
        JournalEntrySchemaV1.self,
        JournalEntrySchemaV2.self
    ]
    
    static var stages: [MigrationStage] = [
        .lightweight(fromVersion: JournalEntrySchemaV1.self, toVersion: JournalEntrySchemaV2.self)
    ]
}

enum JournalEntrySchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [JournalEntryV1.self]
    }
    
    @Model
    final class JournalEntryV1 {
        var content: String
        var meditationDuration: TimeInterval
        var date: Date
        
        init(content: String, meditationDuration: TimeInterval, date: Date) {
            self.content = content
            self.meditationDuration = meditationDuration
            self.date = date
        }
    }
}

enum JournalEntrySchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [JournalEntry.self]
    }
}
