//
//  ToDoView.swift
//  Planner
//
//  Created by Assistant on 8/15/25.
//

import SwiftUI

struct ToDoItem: Identifiable, Codable {
    let id: UUID
    var text: String
    var isCompleted: Bool
    var dateCreated: Date
    var category: Category?
    
    init(text: String, isCompleted: Bool = false, category: Category? = nil) {
        self.id = UUID()
        self.text = text
        self.isCompleted = isCompleted
        self.dateCreated = Date()
        self.category = category
    }
    
    // Custom Codable implementation
    enum CodingKeys: String, CodingKey {
        case id, text, isCompleted, dateCreated, category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        category = try container.decodeIfPresent(Category.self, forKey: .category)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(category, forKey: .category)
    }
}

// MARK: - To Do Data Manager
class ToDoDataManager: ObservableObject {
    @Published var items: [ToDoItem] = []
    
    static let shared = ToDoDataManager()
    
    private init() {
        loadItems()
    }
    
    func addItem(_ item: ToDoItem) {
        items.append(item)
        saveItems()
    }
    
    func updateItem(_ item: ToDoItem) {
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
            UserDefaults.standard.set(data, forKey: "ToDoItems")
        } catch {
            print("Failed to save to-do items: \(error)")
        }
    }
    
    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: "ToDoItems") else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            items = try decoder.decode([ToDoItem].self, from: data)
        } catch {
            print("Failed to load to-do items: \(error)")
            items = []
        }
    }
}

struct ToDoView: View {
    @StateObject private var dataManager = ToDoDataManager.shared
    @State private var newItemText = ""
    @State private var selectedCategory: Category?
    @State private var showingCategoryPicker = false
    @State private var filterCategory: Category?
    @State private var showingFilterOptions = false
    @FocusState private var isTextFieldFocused: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    // Filter items based on selected category
    private var filteredItems: [ToDoItem] {
        if let filterCategory = filterCategory {
            return dataManager.items.filter { $0.category?.id == filterCategory.id }
        }
        return dataManager.items
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("To Do")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Move your items to the todo list")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Filter button
                    Button(action: {
                        showingFilterOptions = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                            if let filterCategory = filterCategory {
                                Text(filterCategory.name)
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    
                    // Clear completed button
                    if filteredItems.contains(where: { $0.isCompleted }) {
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
                
                // Items list or empty state
                if filteredItems.isEmpty {
                    // Empty state - centered
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text(filterCategory == nil ? "No thoughts captured yet" : "No items in \(filterCategory?.name ?? "this category")")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Start by adding anything that comes to mind - ideas, tasks, reminders, or random thoughts!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    Spacer()
                } else {
                    // Items list
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredItems.indices, id: \.self) { filteredIndex in
                                // Find the actual index in the main array
                                if let actualIndex = dataManager.items.firstIndex(where: { $0.id == filteredItems[filteredIndex].id }) {
                                    ToDoItemRow(
                                        item: dataManager.items[actualIndex],
                                        onToggle: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                dataManager.toggleItem(at: actualIndex)
                                            }
                                        },
                                        onUpdate: { updatedText in
                                            dataManager.items[actualIndex].text = updatedText
                                            dataManager.updateItem(dataManager.items[actualIndex])
                                        },
                                        onCategoryUpdate: { newCategory in
                                            dataManager.items[actualIndex].category = newCategory
                                            dataManager.updateItem(dataManager.items[actualIndex])
                                        },
                                        onDelete: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                dataManager.deleteItem(at: actualIndex)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 200) // Extra padding for floating input
                    }
                }
                
                Spacer()
            }
            
            // Floating input section at bottom
            VStack {
                Spacer()
                
                // Category selector (when focused)
                if isTextFieldFocused && showingCategoryPicker {
                    VStack {
                        CategoryPickerView(selectedCategory: $selectedCategory)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2)
                            .padding(.horizontal)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // Category indicator
                        if let selectedCategory = selectedCategory {
                            HStack(spacing: 4) {
                                Image(systemName: selectedCategory.icon)
                                    .foregroundColor(Color(selectedCategory.color))
                                    .font(.caption)
                                Text(selectedCategory.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    self.selectedCategory = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        
                        HStack {
                            TextField("What's on your mind?", text: $newItemText, axis: .vertical)
                                .focused($isTextFieldFocused)
                                .lineLimit(1...5)
                                .onSubmit {
                                    addNewItem()
                                }
                            
                            // Category picker toggle
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingCategoryPicker.toggle()
                                }
                            }) {
                                Image(systemName: showingCategoryPicker ? "folder.badge.minus" : "folder.badge.plus")
                                    .font(.title3)
                                    .foregroundColor(showingCategoryPicker ? .orange : .blue)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Button(action: addNewItem) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                    }
                    .disabled(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
            showingCategoryPicker = false
        }
        .onChange(of: isTextFieldFocused) { _, focused in
            if !focused {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingCategoryPicker = false
                }
            }
        }
        .actionSheet(isPresented: $showingFilterOptions) {
            ActionSheet(
                title: Text("Filter by Category"),
                buttons: createFilterButtons()
            )
        }
    }
    
    private func createFilterButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        
        // Show All button
        buttons.append(.default(Text("Show All")) {
            filterCategory = nil
        })
        
        // Category buttons
        let categoryManager = CategoryDataManager.shared
        for category in categoryManager.categories {
            buttons.append(.default(Text(category.name)) {
                filterCategory = category
            })
        }
        
        buttons.append(.cancel())
        return buttons
    }
    
    private func addNewItem() {
        let trimmedText = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let newItem = ToDoItem(text: trimmedText, category: selectedCategory)
        withAnimation(.easeInOut(duration: 0.3)) {
            dataManager.addItem(newItem)
        }
        newItemText = ""
        selectedCategory = nil
        isTextFieldFocused = false
        showingCategoryPicker = false
    }
}

struct ToDoItemRow: View {
    let item: ToDoItem
    let onToggle: () -> Void
    let onUpdate: (String) -> Void
    let onCategoryUpdate: (Category?) -> Void
    let onDelete: () -> Void
    
    @State private var isEditing = false
    @State private var editText = ""
    @State private var showingCategoryEdit = false
    @State private var editingCategory: Category?
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
                
                HStack {
                    // Category indicator
                    if let category = item.category {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .foregroundColor(Color(category.color))
                                .font(.caption2)
                            Text(category.name)
                                .font(.caption2)
                                .foregroundColor(Color(category.color))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(category.color).opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: item.dateCreated))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
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
                    
                    Button("Change Category") {
                        editingCategory = item.category
                        showingCategoryEdit = true
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
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingCategoryEdit) {
            NavigationView {
                VStack {
                    CategoryPickerView(selectedCategory: $editingCategory)
                        .padding()
                    
                    Spacer()
                }
                .navigationTitle("Select Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            onCategoryUpdate(editingCategory)
                            showingCategoryEdit = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingCategoryEdit = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
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
    ToDoView()
}
