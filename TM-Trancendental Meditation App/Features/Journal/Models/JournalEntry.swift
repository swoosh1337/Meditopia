import Foundation
import SwiftData

@Model
final class JournalEntry {
    @Attribute(.unique) var id: UUID
    var content: String
    var meditationDuration: TimeInterval
    var date: Date
    
    init(content: String, meditationDuration: TimeInterval) {
        self.id = UUID()
        self.content = content
        self.meditationDuration = meditationDuration
        self.date = Date()
    }
}
