//
//  TM_Trancendental_Meditation_AppApp.swift
//  TM-Trancendental Meditation App
//
//  Created by Tazi Grigolia on 10/23/24.
//

import SwiftUI
import SwiftData
import StoreKit

@main
struct TM_Trancendental_Meditation_AppApp: App {
    let container: ModelContainer
    
    // Reference to PurchaseManager to ensure it's initialized early
    @StateObject private var purchaseManager = PurchaseManager.shared
    
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
            SplashScreen()
                .modelContainer(container)
                .task {
                    // Listen for transactions when the app launches
                    // This ensures we capture transactions that may have been made when the app wasn't running
                    for await result in StoreKit.Transaction.updates {
                        if case .verified(let transaction) = result {
                            await purchaseManager.handleVerifiedTransaction(transaction)
                        }
                    }
                }
        }
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
