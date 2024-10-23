import Foundation

class StreakManager {
    
    static func updateStreaks() {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        var meditationDates = defaults.array(forKey: "meditationDates") as? [Date] ?? []
        var sessionsToday = defaults.integer(forKey: "sessionsToday")
        
        if !meditationDates.contains(today) {
            meditationDates.append(today)
            defaults.set(meditationDates, forKey: "meditationDates")
        }
        
        sessionsToday += 1
        defaults.set(sessionsToday, forKey: "sessionsToday")
        
        if sessionsToday == 2 {
            var currentStreak = defaults.integer(forKey: "currentStreak")
            currentStreak += 1
            defaults.set(currentStreak, forKey: "currentStreak")
            
            let bestStreak = defaults.integer(forKey: "bestStreak")
            if currentStreak > bestStreak {
                defaults.set(currentStreak, forKey: "bestStreak")
            }
            
            // Reset sessions for the next day
            defaults.set(0, forKey: "sessionsToday")
        }
    }

    static func checkAndResetStreak() {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let meditationDates = defaults.array(forKey: "meditationDates") as? [Date] ?? []
        
        if !meditationDates.contains(yesterday) && !meditationDates.contains(today) {
            defaults.set(0, forKey: "currentStreak")
        }
        
        // Reset sessions if it's a new day
        if !meditationDates.contains(today) {
            defaults.set(0, forKey: "sessionsToday")
        }
    }
}
