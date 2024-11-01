import Foundation

class StreakManager {
    private static let defaults = UserDefaults.standard
    
    static func updateStreaks() {
        let today = Calendar.current.startOfDay(for: Date())
        let sessionCount = defaults.integer(forKey: "dailySessionCount")
        
        print("=== Streak Update ===")
        print("Session count: \(sessionCount)")
        
        if sessionCount == 2 {
            var meditationDates = defaults.array(forKey: "meditationDates") as? [Date] ?? []
            let alreadyRecordedToday = meditationDates.contains { date in
                Calendar.current.isDate(Calendar.current.startOfDay(for: date), inSameDayAs: today)
            }
            
            print("Already recorded today: \(alreadyRecordedToday)")
            
            if !alreadyRecordedToday {
                meditationDates.append(today)
                defaults.set(meditationDates, forKey: "meditationDates")
                
                var currentStreak = defaults.integer(forKey: "currentStreak")
                var bestStreak = defaults.integer(forKey: "bestStreak")
                
                print("Before update - Current: \(currentStreak), Best: \(bestStreak)")
                
                currentStreak += 1
                if currentStreak > bestStreak {
                    bestStreak = currentStreak
                }
                
                defaults.set(currentStreak, forKey: "currentStreak")
                defaults.set(bestStreak, forKey: "bestStreak")
                defaults.synchronize()
                
                print("After update - Current: \(currentStreak), Best: \(bestStreak)")
            }
        }
    }
    
    static func checkAndResetStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let meditationDates = defaults.array(forKey: "meditationDates") as? [Date] ?? []
        print("Checking streak - Total meditation dates: \(meditationDates.count)")
        
        // Don't reset streak on the same day
        let currentStreak = defaults.integer(forKey: "currentStreak")
        if currentStreak > 0 {
            let hadRecentSession = meditationDates.contains { date in
                let startOfDate = calendar.startOfDay(for: date)
                return calendar.isDate(startOfDate, inSameDayAs: today) ||
                       calendar.isDate(startOfDate, inSameDayAs: yesterday)
            }
            
            print("Had recent session: \(hadRecentSession)")
            
            if !hadRecentSession {
                print("Resetting streak from \(currentStreak) to 0")
                defaults.set(0, forKey: "currentStreak")
                defaults.synchronize()
            }
        }
    }
    
    static func resetDailyProgress() {
        let calendar = Calendar.current
        let now = Date()
        let lastResetDate = defaults.object(forKey: "lastResetDate") as? Date ?? Date.distantPast
        
        if !calendar.isDate(lastResetDate, inSameDayAs: now) {
            defaults.set(0, forKey: "dailySessionCount")
            defaults.set(now, forKey: "lastResetDate")
            defaults.synchronize()
        }
    }
}
