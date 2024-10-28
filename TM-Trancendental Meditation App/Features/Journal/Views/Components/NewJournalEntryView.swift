import SwiftUI
import SwiftData

struct NewJournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var journalContent: String = ""
    let meditationDuration: TimeInterval
    
    var body: some View {
        NavigationView {
            ZStack {
                Configuration.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack {
                    ZStack {
                        Configuration.backgroundColor
                        
                        TextEditor(text: $journalContent)
                            .padding(4)
                            .background(Color.clear)
                            .foregroundColor(.black)
                    }
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                    )
                    .padding()
                }
            }
            .navigationTitle("New Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(journalContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .accentColor(.yellow)
    }
    
    private func saveEntry() {
        print("Starting to save entry...")
        let newEntry = JournalEntry(content: journalContent, meditationDuration: meditationDuration)
        print("Created new entry with content: \(newEntry.content)")
        
        modelContext.insert(newEntry)
        print("Inserted entry into modelContext")
        
        do {
            try modelContext.save()
            print("Successfully saved modelContext")
            
            // Debug: Try to fetch entries after saving
            let descriptor = FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            let count = try modelContext.fetch(descriptor).count
            print("Number of entries after save: \(count)")
            
            dismiss()
        } catch {
            print("Failed to save entry: \(error)")
            print("Error details: \(error.localizedDescription)")
        }
    }
}

struct NewJournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NewJournalEntryView(meditationDuration: 1200) // 20 minutes
    }
}
