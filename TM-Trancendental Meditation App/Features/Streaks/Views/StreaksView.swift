import SwiftUI

struct StreaksView: View {
    @StateObject private var viewModel = StreaksViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Your Progress")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.top)
                
                ScrollView {
                    VStack(spacing: 20) {
                        streakCards
                        CalendarView(meditationDates: $viewModel.streakData.meditationDates)
                        weeklyProgressView
                        totalMeditationTimeView
                    }
                    .padding()
                }
            }
            .background(Configuration.backgroundColor)
        }
        .onAppear(perform: viewModel.loadData)
    }
    
    private var streakCards: some View {
        HStack(spacing: 20) {
            StreakCard(title: "Current Streak", value: viewModel.streakData.currentStreak)
            StreakCard(title: "Best Streak", value: viewModel.streakData.bestStreak)
        }
    }
    
    private var weeklyProgressView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This Week's Progress")
                .font(.headline)
                .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                ForEach(0..<7) { day in
                    VStack {
                        Circle()
                            .fill(viewModel.didMeditateOnDay(day) ? Color.yellow : Color.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                        Text(viewModel.dayAbbreviation(for: day))
                            .font(.caption)
                            .foregroundColor(.gray)
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
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "hourglass")
                    .foregroundColor(.yellow)
                Text(viewModel.formatTotalTime(viewModel.streakData.totalMeditationTime))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(15)
    }
}

struct StreaksView_Previews: PreviewProvider {
    static var previews: some View {
        StreaksView()
    }
}
