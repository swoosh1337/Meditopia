import SwiftUI

struct JournalEntryRow: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(entry.content)
                .lineLimit(2)
                .font(.body)
                .foregroundColor(.primary)
            
            if let duration = entry.meditationDuration {  // Only show duration if it exists
                Text("\(Int(duration / 60)) min meditation")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Configuration.backgroundColor.opacity(0.5))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
        )
    }
} 