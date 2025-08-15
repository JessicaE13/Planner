//
//  BrainDumpView.swift
//  Planner
//
//  Created by Assistant on 8/15/25.
//

import SwiftUI

struct BrainDumpItem: Identifiable, Codable {
    let id: UUID
    var text: String
    var isCompleted: Bool
    var dateCreated: Date
    
    init(text: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.text = text
        self.isCompleted = isCompleted
        self.dateCreated = Date()
    }
    
    // Custom Codable implementation
    enum CodingKeys: String, CodingKey {
        case id, text, isCompleted, dateCreated
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(dateCreated, forKey: .dateCreated)
    }
}

// MARK: - Brain Dump Data Manager
class BrainDumpDataManager: ObservableObject {
    @Published var items: [BrainDumpItem] = []
    
    static let shared = BrainDumpDataManager()
    
    private init() {
        loadItems()
    }
    
    func addItem(_ item: BrainDumpItem) {
        items.append(item)
        saveItems()
    }
    
    func updateItem(_ item: BrainDumpItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveItems()
        }
    }
    
    func deleteItem(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
        saveItems()
    }
    
    func toggleItem(at index: Int) {
        guard index < items.count else { return }
        items[index].isCompleted.toggle()
        saveItems()
    }
    
    func clearCompleted() {
        items.removeAll { $0.isCompleted }
        saveItems()
    }
    
    private func saveItems() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            UserDefaults.standard.set(data, forKey: "BrainDumpItems")
        } catch {
            print("Failed to save brain dump items: \(error)")
        }
    }
    
    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: "BrainDumpItems") else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            items = try decoder.decode([BrainDumpItem].self, from: data)
        } catch {
            print("Failed to load brain dump items: \(error)")
            items = []
        }
    }
}

struct BrainDumpView: View {
    @StateObject private var dataManager = BrainDumpDataManager.shared
    @State private var newItemText = ""
    @State private var isAddingItem = false
    @FocusState private var isTextFieldFocused: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Brain Dump")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Capture all your thoughts and to-dos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Clear completed button
                    if dataManager.items.contains(where: { $0.isCompleted }) {
                        Button("Clear Done") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dataManager.clearCompleted()
                            }
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                    }
                }
                .padding()
                
                // Quick add section
                VStack(spacing: 12) {
                    HStack {
                        TextField("What's on your mind?", text: $newItemText, axis: .vertical)
                            .focused($isTextFieldFocused)
                            .lineLimit(1...5)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .onSubmit {
                                addNewItem()
                            }
                        
                        Button(action: addNewItem) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        }
                        .disabled(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    // Quick add buttons for common items
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quickAddSuggestions, id: \.self) { suggestion in
                                Button(suggestion) {
                                    newItemText = suggestion
                                    addNewItem()
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                // Items list
                if dataManager.items.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No thoughts captured yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Start by adding anything that comes to mind - ideas, tasks, reminders, or random thoughts!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(dataManager.items.indices, id: \.self) { index in
                                BrainDumpItemRow(
                                    item: dataManager.items[index],
                                    onToggle: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            dataManager.toggleItem(at: index)
                                        }
                                    },
                                    onUpdate: { updatedText in
                                        dataManager.items[index].text = updatedText
                                        dataManager.updateItem(dataManager.items[index])
                                    },
                                    onDelete: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            dataManager.deleteItem(at: index)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100) // Extra padding for tab bar
                    }
                }
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
    
    private var quickAddSuggestions: [String] {
        [
            "Call...",
            "Buy...",
            "Remember to...",
            "Check...",
            "Schedule...",
            "Research...",
            "Email...",
            "Fix...",
            "Plan..."
        ]
    }
    
    private func addNewItem() {
        let trimmedText = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let newItem = BrainDumpItem(text: trimmedText)
        withAnimation(.easeInOut(duration: 0.3)) {
            dataManager.addItem(newItem)
        }
        newItemText = ""
        isTextFieldFocused = false
    }
}

struct BrainDumpItemRow: View {
    let item: BrainDumpItem
    let onToggle: () -> Void
    let onUpdate: (String) -> Void
    let onDelete: () -> Void
    
    @State private var isEditing = false
    @State private var editText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Completion toggle
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextField("Edit item", text: $editText, axis: .vertical)
                        .focused($isTextFieldFocused)
                        .lineLimit(1...10)
                        .onSubmit {
                            saveEdit()
                        }
                        .onAppear {
                            editText = item.text
                            isTextFieldFocused = true
                        }
                } else {
                    Text(item.text)
                        .font(.body)
                        .strikethrough(item.isCompleted)
                        .foregroundColor(item.isCompleted ? .secondary : .primary)
                        .onTapGesture {
                            startEditing()
                        }
                }
                
                Text(dateFormatter.string(from: item.dateCreated))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Actions menu
            Menu {
                if isEditing {
                    Button("Save") {
                        saveEdit()
                    }
                    Button("Cancel") {
                        cancelEdit()
                    }
                } else {
                    Button("Edit") {
                        startEditing()
                    }
                }
                
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func startEditing() {
        editText = item.text
        isEditing = true
    }
    
    private func saveEdit() {
        let trimmedText = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty && trimmedText != item.text {
            onUpdate(trimmedText)
        }
        isEditing = false
        isTextFieldFocused = false
    }
    
    private func cancelEdit() {
        editText = item.text
        isEditing = false
        isTextFieldFocused = false
    }
}

#Preview {
    BrainDumpView()
}
