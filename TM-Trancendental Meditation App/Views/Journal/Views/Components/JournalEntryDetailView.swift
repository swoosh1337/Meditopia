import SwiftUI
import SwiftData

struct JournalEntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @Bindable var entry: JournalEntry
    @State private var isEditing = false
    @State private var editedContent: String = ""
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            Configuration.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(entry.date.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(Configuration.secondaryTextColor)
                    
                    if isEditing {
                        ZStack(alignment: .topLeading) {
                            Configuration.backgroundColor
                            
                            if editedContent.isEmpty {
                                Text("Write about your meditation experience...")
                                    .foregroundColor(Configuration.secondaryTextColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                            }
                            
                            TextEditor(text: $editedContent)
                                .padding(4)
                                .background(Color.clear)
                                .foregroundColor(Configuration.textColor)
                                .frame(minHeight: 200)
                                .scrollContentBackground(.hidden)
                        }
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                        )
                    } else {
                        Text(entry.content)
                            .font(.body)
                            .foregroundColor(Configuration.textColor)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Configuration.cardBackgroundColor)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                            )
                    }
                    
                    if let duration = entry.meditationDuration {
                        Text("\(Int(duration / 60)) minute meditation session")
                            .font(.caption)
                            .foregroundColor(Configuration.secondaryTextColor)
                    }
                }
                .padding()
                .background(Configuration.backgroundColor)
                .cornerRadius(12)
                .padding()
            }
        }
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                            isEditing = false
                        }
                        .foregroundColor(.yellow)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                        .foregroundColor(.yellow)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                if isEditing {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            editedContent = entry.content
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
        } message: {
            Text("Are you sure you want to delete this journal entry? This action cannot be undone.")
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
    
    private func deleteEntry() {
        modelContext.delete(entry)
        do {
            try modelContext.save()
            dismiss()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error deleting entry: \(error)")
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
