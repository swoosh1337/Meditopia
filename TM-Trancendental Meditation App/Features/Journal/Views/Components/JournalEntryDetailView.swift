import SwiftUI
import SwiftData

struct JournalEntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var entry: JournalEntry
    @State private var isEditing = false
    @State private var editedContent: String = ""
    
    var body: some View {
        ZStack {
            Configuration.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(entry.date.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if isEditing {
                        TextEditor(text: $editedContent)
                            .font(.body)
                            .foregroundColor(.black)
                            .frame(minHeight: 200)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(8)
                    } else {
                        Text(entry.content)
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    
                    Text("\(Int(entry.meditationDuration / 60)) minute meditation session")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Configuration.backgroundColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding()
            }
        }
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }
            }
        }
        .onAppear {
            editedContent = entry.content
        }
    }
    
    private func saveChanges() {
        entry.content = editedContent
        do {
            try modelContext.save()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}

// Update the preview to use a mocked ModelContext
struct JournalEntryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: JournalEntry.self, configurations: config)
        let entry = JournalEntry(content: "Today's meditation session was particularly deep.", meditationDuration: 1200)
        container.mainContext.insert(entry)
        
        return NavigationView {
            JournalEntryDetailView(entry: entry)
        }
        .modelContainer(container)
    }
}
