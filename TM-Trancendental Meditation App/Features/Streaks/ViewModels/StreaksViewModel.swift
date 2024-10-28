import SwiftUI

class StreaksViewModel: ObservableObject {
    @Published var streakData: StreakData
    @Published var selectedDate: Date = Date()
    
    private let calendar = Calendar.current
    private let defaults = UserDefaults.standard
    
    init() {
        self.streakData = StreakData.empty
        loadData()
        
        // Observe UserDefaults changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(defaultsChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func defaultsChanged() {
        DispatchQueue.main.async {
            self.loadData()
        }
    }
    
    func loadData() {
        let currentStreak = defaults.integer(forKey: "currentStreak")
        let bestStreak = defaults.integer(forKey: "bestStreak")
        let totalMeditationTime = defaults.double(forKey: "totalMeditationTime")
        
        if let dates = defaults.array(forKey: "meditationDates") as? [Date] {
            let meditationDates = Set(dates.map { calendar.startOfDay(for: $0) })
            streakData = StreakData(
                currentStreak: currentStreak,
                bestStreak: bestStreak,
                meditationDates: meditationDates,
                totalMeditationTime: totalMeditationTime
            )
        }
    }
    
    func didMeditateOnDay(_ dayOffset: Int) -> Bool {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
        return streakData.meditationDates.contains(calendar.startOfDay(for: date))
    }
    
    func dayAbbreviation(for dayOffset: Int) -> String {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
        let weekday = calendar.component(.weekday, from: date)
        return calendar.veryShortWeekdaySymbols[weekday - 1]
    }
    
    func meditationsThisWeek() -> Int {
        let currentDate = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        
        return streakData.meditationDates.filter { date in
            date >= startOfWeek && date < endOfWeek
        }.count
    }
    
    func getCalendarDays() -> [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        return (0..<leadingEmptyDays).map { _ in nil } +
               range.map { day in calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) }
    }
    
    func formatTotalTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
