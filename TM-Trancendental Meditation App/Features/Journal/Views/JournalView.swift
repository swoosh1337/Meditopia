import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        sort: \JournalEntry.date,
        order: .reverse,
        animation: .default
    ) private var entries: [JournalEntry]
    
    @State private var showingNewEntry = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Configuration.backgroundColor.edgesIgnoringSafeArea(.all)
                
                if entries.isEmpty {
                    Text("No journal entries yet")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(entries) { entry in
                                NavigationLink(destination: JournalEntryDetailView(entry: entry)) {
                                    JournalEntryRow(entry: entry)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView(meditationDuration: 1200)
        }
        .onAppear {
            print("JournalView appeared")
            print("Number of entries: \(entries.count)")
            
            // Debug: Print all entries
            entries.forEach { entry in
                print("Entry: \(entry.content), Date: \(entry.date)")
            }
            
            // Debug: Try to fetch entries manually
            do {
                let descriptor = FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
                let manualFetch = try modelContext.fetch(descriptor)
                print("Manual fetch count: \(manualFetch.count)")
            } catch {
                print("Manual fetch error: \(error)")
            }
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(entries[index])
            }
            do {
                try modelContext.save()
            } catch {
                print("Failed to save after deleting entries: \(error)")
            }
        }
    }
}

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
                .foregroundColor(.black)
            
            Text("\(Int(entry.meditationDuration / 60)) min meditation")
                .font(.caption)
                .foregroundColor(.secondary)
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, configurations: config)
    
    // Add sample data
    let entries = [
        JournalEntry(content: "Today's meditation was very peaceful. I felt a deep sense of calm and clarity.", meditationDuration: 1200),
        JournalEntry(content: "Had some difficulty focusing at first, but eventually found my center.", meditationDuration: 900),
        JournalEntry(content: "Experienced a moment of profound insight during today's session.", meditationDuration: 1500)
    ]
    
    for entry in entries {
        container.mainContext.insert(entry)
    }
    
    return JournalView()
        .modelContainer(container)
}
