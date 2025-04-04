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
                
                VStack {
                    Text("Your Meditation Journey")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.top)
                    
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
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Configuration.primaryColor)
                            .font(.title)
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView(meditationDuration: nil)
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
