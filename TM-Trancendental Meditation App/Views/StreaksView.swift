import SwiftUI

struct StreaksView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    @AppStorage("bestStreak") private var bestStreak: Int = 0
    @AppStorage("totalMeditationTime") private var totalMeditationTime: TimeInterval = 0
    @State private var meditationDates: Set<Date> = []
    
    let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    streakCards
                    CalendarView(meditationDates: $meditationDates)
                    weeklyProgressView
                    totalMeditationTimeView
                }
                .padding()
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarTitle("Meditation Progress", displayMode: .inline)
            .navigationBarItems(trailing: doneButton)
        }
        .onAppear(perform: loadData)
    }
    
    private var doneButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Done")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.yellow)
                .cornerRadius(20)
        }
    }
    
    private var streakCards: some View {
        HStack(spacing: 20) {
            StreakCard(title: "Current Streak", value: currentStreak)
            StreakCard(title: "Best Streak", value: bestStreak)
        }
    }
    
    private var calendarView: some View {
        VStack(alignment: .leading) {
            Text("Meditation Calendar")
                .font(.headline)
                .padding(.bottom, 5)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(getCalendarDays(), id: \.self) { date in
                    if let date = date {
                        CalendarDay(
                            date: date,
                            isMarked: meditationDates.contains(calendar.startOfDay(for: date)),
                            isToday: calendar.isDateInToday(date)
                        )
                    } else {
                        Color.clear
                    }
                }
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var weeklyProgressView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This Week's Progress")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 8) {
                ForEach(0..<7) { day in
                    VStack {
                        Circle()
                            .fill(self.didMeditateOnDay(day) ? Color.yellow : Color.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                        Text(self.dayAbbreviation(for: day))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var totalMeditationTimeView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total Meditation Time")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: "hourglass")
                    .foregroundColor(.yellow)
                Text(formatTotalTime(totalMeditationTime))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func formatTotalTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
    
    private func didMeditateOnDay(_ dayOffset: Int) -> Bool {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
        return meditationDates.contains(calendar.startOfDay(for: date))
    }
    
    private func dayAbbreviation(for dayOffset: Int) -> String {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
        let weekday = calendar.component(.weekday, from: date)
        return calendar.veryShortWeekdaySymbols[weekday - 1]
    }
    
    private func meditationsThisWeek() -> Int {
        let currentDate = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        
        return meditationDates.filter { date in
            date >= startOfWeek && date < endOfWeek
        }.count
    }
    
    private func loadData() {
        if let dates = UserDefaults.standard.array(forKey: "meditationDates") as? [Date] {
            meditationDates = Set(dates.map { calendar.startOfDay(for: $0) })
        }
        StreakManager.checkAndResetStreak()
    }
    
    private func getCalendarDays() -> [Date?] {
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        return (0..<leadingEmptyDays).map { _ in nil } +
               range.map { day in calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) }
    }
}

struct StreaksView_Previews: PreviewProvider {
    static var previews: some View {
        StreaksView()
    }
}
