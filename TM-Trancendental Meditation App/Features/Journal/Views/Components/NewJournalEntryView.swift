import SwiftUI
import SwiftData

struct NewJournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var journalContent: String = ""
    let meditationDuration: TimeInterval?
    
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
        let newEntry = JournalEntry(content: journalContent, meditationDuration: meditationDuration)
        modelContext.insert(newEntry)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save entry: \(error)")
        }
    }
}

struct NewJournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NewJournalEntryView(meditationDuration: nil)
    }
}
