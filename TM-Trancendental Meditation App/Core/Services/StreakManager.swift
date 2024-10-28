import Foundation

class StreakManager {
    private static let defaults = UserDefaults.standard
    
    static func updateStreaks() {
        let today = Calendar.current.startOfDay(for: Date())
        let sessionCount = defaults.integer(forKey: "dailySessionCount")
        
        // Only update streak when exactly reaching 2 sessions
        if sessionCount == 2 {
            // Add today to meditation dates if not already there
            var meditationDates = defaults.array(forKey: "meditationDates") as? [Date] ?? []
            if !meditationDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                meditationDates.append(today)
                defaults.set(meditationDates, forKey: "meditationDates")
                
                // Increment streak
                var currentStreak = defaults.integer(forKey: "currentStreak")
                currentStreak += 1
                defaults.set(currentStreak, forKey: "currentStreak")
                
                // Update best streak if needed
                let bestStreak = defaults.integer(forKey: "bestStreak")
                if currentStreak > bestStreak {
                    defaults.set(currentStreak, forKey: "bestStreak")
                }
            }
        }
    }

    static func checkAndResetStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let meditationDates = defaults.array(forKey: "meditationDates") as? [Date] ?? []
        
        // Check if yesterday had 2 sessions
        let hadYesterdaySession = meditationDates.contains { date in
            calendar.isDate(date, inSameDayAs: yesterday)
        }
        
        // Reset streak if yesterday was missed
        if !hadYesterdaySession {
            defaults.set(0, forKey: "currentStreak")
        }
    }
    
    static func resetDailyProgress() {
        defaults.set(0, forKey: "dailySessionCount")
    }
}
