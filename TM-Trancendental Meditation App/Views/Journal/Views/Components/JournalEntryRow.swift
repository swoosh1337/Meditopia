import SwiftUI

struct JournalEntryRow: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundColor(Configuration.secondaryTextColor)
            
            Text(entry.content)
                .lineLimit(2)
                .font(.body)
                .foregroundColor(Configuration.textColor)
            
            if let duration = entry.meditationDuration {
                Text("\(Int(duration / 60)) min meditation")
                    .font(.caption)
                    .foregroundColor(Configuration.secondaryTextColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Configuration.cardBackgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Configuration.primaryColor.opacity(0.5), lineWidth: 1)
        )
    }
} 