import SwiftUI

struct ToDoDetailView: View {
    @State var item: ScheduleItem
    let onUpdate: (ScheduleItem) -> Void
    let onEdit: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    Text(item.title)
                        .font(.headline)
                    if let category = item.category {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(category.color))
                                .frame(width: 10, height: 10)
                            Text(category.name)
                                .font(.caption)
                                .foregroundColor(Color(category.color))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(category.color).opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                if !item.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Section(header: Text("Notes")) {
                        Text(item.descriptionText)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !item.checklist.isEmpty {
                    Section(header: Text("Subtasks")) {
                        ForEach(Array(item.checklist.enumerated()), id: \.element.id) { index, checklistItem in
                            HStack {
                                Button(action: {
                                    item.checklist[index].isCompleted.toggle()
                                    onUpdate(item)
                                }) {
                                    Image(systemName: checklistItem.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(checklistItem.isCompleted ? .primary : .gray)
                                        .font(.title2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                Text(checklistItem.text)
                                    .strikethrough(checklistItem.isCompleted)
                                    .foregroundColor(checklistItem.isCompleted ? .secondary : .primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Image(systemName: "pencil")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditToDoView(item: item) { updatedItem in
                    self.item = updatedItem
                    onEdit(updatedItem)
                    showingEditSheet = false
                }
            }
        }
    }
}
