import Foundation
import SwiftData

@Model
final class JournalEntry {
    @Attribute(.unique) var id: UUID
    var content: String
    var meditationDuration: TimeInterval
    var date: Date
    
    init(id: UUID = UUID(), content: String, meditationDuration: TimeInterval, date: Date = Date()) {
        self.id = id
        self.content = content
        self.meditationDuration = meditationDuration
        self.date = date
    }
}
