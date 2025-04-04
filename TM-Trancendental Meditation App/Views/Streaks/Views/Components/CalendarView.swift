import SwiftUI

struct CalendarView: View {
    @Binding var meditationDates: Set<Date>
    @State private var currentDate = Date()
    let calendar = Calendar.current
    
    var body: some View {
        VStack {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Configuration.primaryColor)
                }
                Spacer()
                Text(monthYearString(from: currentDate))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Configuration.primaryColor)
                }
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        CalendarDay(
                            date: date,
                            isMarked: meditationDates.contains(calendar.startOfDay(for: date)),
                            isToday: calendar.isDateInToday(date)
                        )
                    } else {
                        Color.clear
                            .frame(height: 30) // Match the height of CalendarDay
                    }
                }
            }
        }
        .padding()
        .background(Configuration.primaryColor.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else { return [] }
        let days = calendar.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day!
        
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        let totalDays = leadingEmptyDays + days
        let totalCells = ((totalDays - 1) / 7 + 1) * 7
        
        return (0..<totalCells).map { index in
            if index < leadingEmptyDays || index >= leadingEmptyDays + days {
                return nil
            } else {
                return calendar.date(byAdding: .day, value: index - leadingEmptyDays, to: monthInterval.start)
            }
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
    }
    
    private func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(meditationDates: .constant(Set([
            Date(),
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        ])))
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.1))
        .environment(\.colorScheme, .light)
    }
}
