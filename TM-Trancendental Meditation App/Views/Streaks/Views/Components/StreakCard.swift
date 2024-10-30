import SwiftUI

struct StreakCard: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Configuration.secondaryTextColor)
            Text("\(value)")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.yellow)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Configuration.cardBackgroundColor)
        .cornerRadius(15)
    }
}

struct StreakCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                StreakCard(title: "Current Streak", value: 5)
                StreakCard(title: "Best Streak", value: 10)
            }
            .padding()
            .background(Configuration.backgroundColor)
            .previewDisplayName("Light Mode")
            
            VStack {
                StreakCard(title: "Current Streak", value: 5)
                StreakCard(title: "Best Streak", value: 10)
            }
            .padding()
            .background(Configuration.backgroundColor)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .previewLayout(.sizeThatFits)
    }
}
