import SwiftUI

struct CalendarDay: View {
    let date: Date
    let isMarked: Bool
    let isToday: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(isToday ? Configuration.primaryColor : Color.clear, lineWidth: 2)
                .background(Circle().fill(isMarked ? Configuration.primaryColor : Color.clear))
            Text("\(Calendar.current.component(.day, from: date))")
                .foregroundColor(isMarked ? .white : (isToday ? Configuration.primaryColor : .primary))
        }
        .frame(height: 30)
    }
}

struct CalendarDay_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            CalendarDay(date: Date(), isMarked: true, isToday: true)
            CalendarDay(date: Date(), isMarked: false, isToday: true)
            CalendarDay(date: Date().addingTimeInterval(-86400), isMarked: true, isToday: false)
            CalendarDay(date: Date().addingTimeInterval(-86400), isMarked: false, isToday: false)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
