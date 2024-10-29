import Foundation

struct StreakData: Codable {
    var currentStreak: Int
    var bestStreak: Int
    var meditationDates: Set<Date>
    var totalMeditationTime: TimeInterval
    
    static var empty: StreakData {
        StreakData(currentStreak: 0, 
                  bestStreak: 0, 
                  meditationDates: [], 
                  totalMeditationTime: 0)
    }
}
