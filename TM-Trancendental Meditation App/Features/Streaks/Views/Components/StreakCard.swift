import SwiftUI

struct StreakCard: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.yellow)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(15)
    }
}

struct StreakCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StreakCard(title: "Current Streak", value: 5)
            StreakCard(title: "Best Streak", value: 10)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
