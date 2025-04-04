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
                    ZStack(alignment: .topLeading) {
                        Configuration.backgroundColor
                        
                        if journalContent.isEmpty {
                            Text("Write about your meditation experience...")
                                .foregroundColor(Configuration.secondaryTextColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }
                        
                        TextEditor(text: $journalContent)
                            .padding(4)
                            .background(Color.clear)
                            .foregroundColor(Configuration.textColor)
                            .frame(minHeight: 200)
                            .scrollContentBackground(.hidden)
                    }
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Configuration.primaryColor.opacity(0.5), lineWidth: 1)
                    )
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Custom title view that uses the app's secondary text color
                    Text("New Journal Entry")
                        .font(.headline)
                        .foregroundColor(Configuration.secondaryTextColor)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Configuration.primaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .foregroundColor(Configuration.primaryColor)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    // .background(Configuration.primaryColor)
                    .cornerRadius(20)
                    .disabled(journalContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
        Group {
            NewJournalEntryView(meditationDuration: nil)
                .previewDisplayName("Light Mode")
            
            NewJournalEntryView(meditationDuration: nil)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
