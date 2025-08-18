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
    var priority: Priority
    var dueDate: Date?
    var hasDueDate: Bool
    var notes: String
    var checklist: [ChecklistItem]
    
    init(text: String, isCompleted: Bool = false, category: Category? = nil, priority: Priority = .medium, dueDate: Date? = nil, hasDueDate: Bool = false, notes: String = "", checklist: [ChecklistItem] = []) {
        self.id = UUID()
        self.text = text
        self.isCompleted = isCompleted
        self.dateCreated = Date()
        self.category = category
        self.priority = priority
        self.dueDate = dueDate
        self.hasDueDate = hasDueDate
        self.notes = notes
        self.checklist = checklist
    }
    
    // Custom Codable implementation
    enum CodingKeys: String, CodingKey {
        case id, text, isCompleted, dateCreated, category, priority, dueDate, hasDueDate, notes, checklist
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        category = try container.decodeIfPresent(Category.self, forKey: .category)
        priority = try container.decodeIfPresent(Priority.self, forKey: .priority) ?? .medium
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        hasDueDate = try container.decodeIfPresent(Bool.self, forKey: .hasDueDate) ?? false
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        checklist = try container.decodeIfPresent([ChecklistItem].self, forKey: .checklist) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(category, forKey: .category)
        try container.encode(priority, forKey: .priority)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(hasDueDate, forKey: .hasDueDate)
        try container.encode(notes, forKey: .notes)
        try container.encode(checklist, forKey: .checklist)
    }
}

// MARK: - Priority Enum
enum Priority: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
    
    var icon: String {
        switch self {
        case .low:
            return "arrow.down.circle.fill"
        case .medium:
            return "minus.circle.fill"
        case .high:
            return "arrow.up.circle.fill"
        }
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
    
    func deleteItem(withId id: UUID) {
        items.removeAll { $0.id == id }
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
    @State private var filterCategory: Category?
    @State private var showingFilterOptions = false
    @State private var showingAddToDo = false
    
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
                        Text("Organize your tasks and ideas")
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
                    
                    // Add button
                    Button(action: {
                        showingAddToDo = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
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
                        
                        Text(filterCategory == nil ? "No tasks yet" : "No items in \(filterCategory?.name ?? "this category")")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Start by adding tasks, ideas, or reminders using the + button above!")
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
                                        onEdit: { updatedItem in
                                            dataManager.updateItem(updatedItem)
                                        },
                                        onDelete: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                dataManager.deleteItem(at: actualIndex)
                                            }
                                        },
                                        onMoveToSchedule: { toDoItem in
                                            // The item will be deleted from ToDo after successful move
                                            dataManager.deleteItem(withId: toDoItem.id)
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100) // Extra padding for bottom
                    }
                }
                
                Spacer()
            }
        }
        .actionSheet(isPresented: $showingFilterOptions) {
            ActionSheet(
                title: Text("Filter by Category"),
                buttons: createFilterButtons()
            )
        }
        .sheet(isPresented: $showingAddToDo) {
            AddToDoView { newItem in
                withAnimation(.easeInOut(duration: 0.3)) {
                    dataManager.addItem(newItem)
                }
                showingAddToDo = false
            }
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
}

// MARK: - Add To Do View
struct AddToDoView: View {
    let onSave: (ToDoItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var notes = ""
    @State private var selectedCategory: Category?
    @State private var priority: Priority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var checklistItems: [ChecklistItem] = []
    @State private var newChecklistItem = ""
    @State private var showingManageCategories = false
    
    @FocusState private var notesIsFocused: Bool
    @FocusState private var checklistInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").opacity(0.2)
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Task Details")) {
                        TextField("Task title", text: $title)
                            .font(.body)
                        
                        // Priority Picker
                        HStack {
                            Text("Priority")
                            Spacer()
                            Menu {
                                ForEach(Priority.allCases) { priorityOption in
                                    Button(action: {
                                        priority = priorityOption
                                    }) {
                                        HStack {
                                            Image(systemName: priorityOption.icon)
                                                .foregroundColor(priorityOption.color)
                                            Text(priorityOption.displayName)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: priority.icon)
                                        .foregroundColor(priority.color)
                                    Text(priority.displayName)
                                        .foregroundColor(.primary)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(.secondary)
                                        .font(.caption2)
                                }
                            }
                        }
                        
                        // Category Selection
                        HStack {
                            Text("Category")
                            Spacer()
                            Menu {
                                Button("None") {
                                    selectedCategory = nil
                                }
                                ForEach(CategoryDataManager.shared.categories) { category in
                                    Button(category.name) {
                                        selectedCategory = category
                                    }
                                }
                                Button("Manage Categories") {
                                    showingManageCategories = true
                                }
                            } label: {
                                HStack {
                                    if let category = selectedCategory {
                                        Circle()
                                            .fill(Color(category.color))
                                            .frame(width: 12, height: 12)
                                        Text(category.name)
                                            .foregroundColor(.primary)
                                    } else {
                                        Text("None")
                                            .foregroundColor(.primary)
                                    }
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(.secondary)
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Due Date")) {
                        HStack {
                            Text("Has due date")
                            Spacer()
                            Toggle("", isOn: $hasDueDate)
                        }
                        
                        if hasDueDate {
                            HStack {
                                Text("Due date")
                                Spacer()
                                DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                            }
                        }
                    }
                    
                    Section(header: Text("Notes")) {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $notes)
                                .frame(minHeight: 100)
                                .focused($notesIsFocused)
                                .onTapGesture {
                                    notesIsFocused = true
                                }
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)

                            if notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Add notes...")
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 6)
                                    .allowsHitTesting(false)
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.2), value: notes)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section(header: Text("Subtasks")) {
                        ForEach(Array(checklistItems.enumerated()), id: \.element.id) { index, checklistItem in
                            HStack {
                                Button(action: {
                                    checklistItems[index].isCompleted.toggle()
                                }) {
                                    Image(systemName: checklistItem.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(checklistItem.isCompleted ? .green : .gray)
                                        .font(.title2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                TextField("Subtask", text: Binding(
                                    get: { checklistItems[index].text },
                                    set: { checklistItems[index].text = $0 }
                                ))
                                .strikethrough(checklistItem.isCompleted)
                                .foregroundColor(checklistItem.isCompleted ? .secondary : .primary)
                            }
                            .padding(.vertical, 2)
                        }
                        .onDelete(perform: deleteChecklistItems)
                        
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            TextField("Add subtask", text: $newChecklistItem)
                                .focused($checklistInputFocused)
                                .onSubmit {
                                    addChecklistItem()
                                }
                            
                            if !newChecklistItem.isEmpty {
                                Button("Add") {
                                    addChecklistItem()
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingManageCategories) {
            ManageCategoriesView()
        }
    }
    
    private func addChecklistItem() {
        guard !newChecklistItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newItem = ChecklistItem(text: newChecklistItem.trimmingCharacters(in: .whitespacesAndNewlines))
        checklistItems.append(newItem)
        newChecklistItem = ""
        checklistInputFocused = false
    }
    
    private func deleteChecklistItems(offsets: IndexSet) {
        checklistItems.remove(atOffsets: offsets)
    }
    
    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let newItem = ToDoItem(
            text: trimmedTitle,
            isCompleted: false,
            category: selectedCategory,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            hasDueDate: hasDueDate,
            notes: notes,
            checklist: checklistItems
        )
        
        onSave(newItem)
    }
}

struct ToDoItemRow: View {
    let item: ToDoItem
    let onToggle: () -> Void
    let onEdit: (ToDoItem) -> Void
    let onDelete: () -> Void
    let onMoveToSchedule: (ToDoItem) -> Void
    
    @State private var showingEditSheet = false
    @State private var showingMoveToSchedule = false
    
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
            VStack(alignment: .leading, spacing: 6) {
                // Title and priority
                HStack {
                    Text(item.text)
                        .font(.body)
                        .strikethrough(item.isCompleted)
                        .foregroundColor(item.isCompleted ? .secondary : .primary)
                    
                    Spacer()
                    
                    // Priority indicator
                    Image(systemName: item.priority.icon)
                        .foregroundColor(item.priority.color)
                        .font(.caption)
                }
                
                // Due date (if present)
                if item.hasDueDate, let dueDate = item.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(dateFormatter.string(from: dueDate))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Category indicator (if present)
                if let category = item.category {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(category.color))
                            .frame(width: 8, height: 8)
                        Text(category.name)
                            .font(.caption2)
                            .foregroundColor(Color(category.color))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(category.color).opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Notes preview (if present)
                if !item.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(item.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Checklist progress (if present)
                if !item.checklist.isEmpty {
                    let completedCount = item.checklist.filter { $0.isCompleted }.count
                    let totalCount = item.checklist.count
                    
                    HStack(spacing: 4) {
                        Image(systemName: "checklist")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(completedCount)/\(totalCount) subtasks")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Actions menu
            Menu {
                Button("Edit") {
                    showingEditSheet = true
                }
                
                Button(action: {
                    showingMoveToSchedule = true
                }) {
                    Label("Move to Schedule", systemImage: "calendar.badge.plus")
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
        .sheet(isPresented: $showingEditSheet) {
            EditToDoView(item: item) { updatedItem in
                onEdit(updatedItem)
                showingEditSheet = false
            }
        }
        .sheet(isPresented: $showingMoveToSchedule) {
            MoveToScheduleView(
                todoItem: item,
                onSave: { scheduleItem in
                    // Add to schedule
                    ScheduleDataManager.shared.addOrUpdateItem(scheduleItem)
                    // Remove from todo
                    onMoveToSchedule(item)
                    showingMoveToSchedule = false
                }
            )
        }
    }
}

// MARK: - Edit To Do View
struct EditToDoView: View {
    @State private var item: ToDoItem
    let onSave: (ToDoItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingManageCategories = false
    @State private var newChecklistItem = ""
    
    @FocusState private var notesIsFocused: Bool
    @FocusState private var checklistInputFocused: Bool
    
    init(item: ToDoItem, onSave: @escaping (ToDoItem) -> Void) {
        self._item = State(initialValue: item)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").opacity(0.2)
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Task Details")) {
                        TextField("Task title", text: $item.text)
                            .font(.body)
                        
                        // Priority Picker
                        HStack {
                            Text("Priority")
                            Spacer()
                            Menu {
                                ForEach(Priority.allCases) { priorityOption in
                                    Button(action: {
                                        item.priority = priorityOption
                                    }) {
                                        HStack {
                                            Image(systemName: priorityOption.icon)
                                                .foregroundColor(priorityOption.color)
                                            Text(priorityOption.displayName)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: item.priority.icon)
                                        .foregroundColor(item.priority.color)
                                    Text(item.priority.displayName)
                                        .foregroundColor(.primary)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(.secondary)
                                        .font(.caption2)
                                }
                            }
                        }
                        
                        // Category Selection
                        HStack {
                            Text("Category")
                            Spacer()
                            Menu {
                                Button("None") {
                                    item.category = nil
                                }
                                ForEach(CategoryDataManager.shared.categories) { category in
                                    Button(category.name) {
                                        item.category = category
                                    }
                                }
                                Button("Manage Categories") {
                                    showingManageCategories = true
                                }
                            } label: {
                                HStack {
                                    if let category = item.category {
                                        Circle()
                                            .fill(Color(category.color))
                                            .frame(width: 12, height: 12)
                                        Text(category.name)
                                            .foregroundColor(.primary)
                                    } else {
                                        Text("None")
                                            .foregroundColor(.primary)
                                    }
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(.secondary)
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Due Date")) {
                        HStack {
                            Text("Has due date")
                            Spacer()
                            Toggle("", isOn: $item.hasDueDate)
                        }
                        
                        if item.hasDueDate {
                            HStack {
                                Text("Due date")
                                Spacer()
                                DatePicker("", selection: Binding(
                                    get: { item.dueDate ?? Date() },
                                    set: { item.dueDate = $0 }
                                ), displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                            }
                        }
                    }
                    
                    Section(header: Text("Notes")) {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $item.notes)
                                .frame(minHeight: 100)
                                .focused($notesIsFocused)
                                .onTapGesture {
                                    notesIsFocused = true
                                }
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)

                            if item.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Add notes...")
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 6)
                                    .allowsHitTesting(false)
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.2), value: item.notes)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section(header: Text("Subtasks")) {
                        ForEach(Array(item.checklist.enumerated()), id: \.element.id) { index, checklistItem in
                            HStack {
                                Button(action: {
                                    item.checklist[index].isCompleted.toggle()
                                }) {
                                    Image(systemName: checklistItem.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(checklistItem.isCompleted ? .green : .gray)
                                        .font(.title2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                TextField("Subtask", text: Binding(
                                    get: { item.checklist[index].text },
                                    set: { item.checklist[index].text = $0 }
                                ))
                                .strikethrough(checklistItem.isCompleted)
                                .foregroundColor(checklistItem.isCompleted ? .secondary : .primary)
                            }
                            .padding(.vertical, 2)
                        }
                        .onDelete(perform: deleteChecklistItems)
                        
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            TextField("Add subtask", text: $newChecklistItem)
                                .focused($checklistInputFocused)
                                .onSubmit {
                                    addChecklistItem()
                                }
                            
                            if !newChecklistItem.isEmpty {
                                Button("Add") {
                                    addChecklistItem()
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(item)
                    }
                    .disabled(item.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingManageCategories) {
            ManageCategoriesView()
        }
        .onChange(of: item.hasDueDate) { _, newValue in
            if !newValue {
                item.dueDate = nil
            } else if item.dueDate == nil {
                item.dueDate = Date()
            }
        }
    }
    
    private func addChecklistItem() {
        guard !newChecklistItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newItem = ChecklistItem(text: newChecklistItem.trimmingCharacters(in: .whitespacesAndNewlines))
        item.checklist.append(newItem)
        newChecklistItem = ""
        checklistInputFocused = false
    }
    
    private func deleteChecklistItems(offsets: IndexSet) {
        item.checklist.remove(atOffsets: offsets)
    }
}

// MARK: - Move to Schedule View (keeping the existing implementation)
struct MoveToScheduleView: View {
    let todoItem: ToDoItem
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime: Date
    @State private var allDay = false
    @State private var location = ""
    @State private var frequency: Frequency = .never
    @State private var endRepeatOption: EndRepeatOption = .never
    @State private var endRepeatDate: Date
    @State private var customFrequencyConfig = CustomFrequencyConfig()
    @State private var showingCustomFrequencyPicker = false
    
    init(todoItem: ToDoItem, onSave: @escaping (ScheduleItem) -> Void) {
        self.todoItem = todoItem
        self.onSave = onSave
        
        let defaultStart = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        let defaultEnd = Calendar.current.date(byAdding: .hour, value: 1, to: defaultStart) ?? defaultStart
        let defaultEndRepeat = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        
        self._startTime = State(initialValue: defaultStart)
        self._endTime = State(initialValue: defaultEnd)
        self._endRepeatDate = State(initialValue: defaultEndRepeat)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Schedule Details")) {
                    HStack {
                        Text("Date")
                        Spacer()
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    
                    HStack {
                        Text("All-day")
                        Spacer()
                        Toggle("", isOn: $allDay)
                    }
                    
                    if !allDay {
                        HStack {
                            Text("Start Time")
                            Spacer()
                            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        
                        HStack {
                            Text("End Time")
                            Spacer()
                            DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                    
                    TextField("Location (optional)", text: $location)
                }
                
                Section(header: Text("Repeat")) {
                    HStack {
                        Text("Frequency")
                        Spacer()
                        Menu {
                            ForEach(Frequency.allCases) { freq in
                                Button(freq.displayName) {
                                    frequency = freq
                                    if freq == .custom {
                                        showingCustomFrequencyPicker = true
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                if frequency == .custom {
                                    Text(customFrequencyConfig.displayDescription())
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                } else {
                                    Text(frequency.displayName)
                                        .foregroundColor(.primary)
                                }
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundColor(.secondary)
                                    .font(.caption2)
                            }
                        }
                    }
                    
                    if frequency != .never {
                        HStack {
                            Text("End Repeat")
                            Spacer()
                            Picker("", selection: $endRepeatOption) {
                                ForEach(EndRepeatOption.allCases) { option in
                                    Text(option.displayName).tag(option)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        if endRepeatOption == .onDate {
                            HStack {
                                Text("End Date")
                                Spacer()
                                DatePicker("", selection: $endRepeatDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                        }
                    }
                }
                
                Section(header: Text("Task")) {
                    HStack {
                        Text("Title")
                        Spacer()
                        Text(todoItem.text)
                            .foregroundColor(.secondary)
                    }
                    
                    if let category = todoItem.category {
                        HStack {
                            Text("Category")
                            Spacer()
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(category.color))
                                    .frame(width: 12, height: 12)
                                Text(category.name)
                                    .font(.caption)
                                    .foregroundColor(Color(category.color))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Schedule Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveToSchedule()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCustomFrequencyPicker) {
            CustomFrequencyPickerView(
                customConfig: $customFrequencyConfig,
                endRepeatOption: $endRepeatOption,
                endRepeatDate: $endRepeatDate
            )
        }
        .onChange(of: frequency) { _, newFrequency in
            if newFrequency == .never {
                endRepeatOption = .never
            }
            if newFrequency == .custom {
                showingCustomFrequencyPicker = true
            }
        }
        .onChange(of: selectedDate) { _, newDate in
            // Update start and end times to use the selected date
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
            if let newStartTime = calendar.date(bySettingHour: timeComponents.hour ?? 9,
                                               minute: timeComponents.minute ?? 0,
                                               second: 0,
                                               of: newDate) {
                startTime = newStartTime
                endTime = calendar.date(byAdding: .hour, value: 1, to: newStartTime) ?? newStartTime
            }
        }
    }
    
    private func saveToSchedule() {
        let calendar = Calendar.current
        
        // Create final start and end times using selected date
        let finalStartTime: Date
        let finalEndTime: Date
        
        if allDay {
            finalStartTime = calendar.startOfDay(for: selectedDate)
            finalEndTime = calendar.date(byAdding: .day, value: 1, to: finalStartTime) ?? finalStartTime
        } else {
            let startTimeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
            let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endTime)
            
            finalStartTime = calendar.date(bySettingHour: startTimeComponents.hour ?? 9,
                                         minute: startTimeComponents.minute ?? 0,
                                         second: 0,
                                         of: selectedDate) ?? selectedDate
            
            finalEndTime = calendar.date(bySettingHour: endTimeComponents.hour ?? 10,
                                       minute: endTimeComponents.minute ?? 0,
                                       second: 0,
                                       of: selectedDate) ?? finalStartTime
        }
        
        let scheduleItem = ScheduleItem(
            title: todoItem.text,
            time: finalStartTime,
            icon: "checkmark.circle.fill",
            color: todoItem.category?.color ?? "Color1",
            frequency: frequency,
            customFrequencyConfig: frequency == .custom ? customFrequencyConfig : nil,
            startTime: finalStartTime,
            endTime: finalEndTime,
            checklist: todoItem.checklist,
            uniqueKey: "todo-\(todoItem.id.uuidString)",
            category: todoItem.category,
            endRepeatOption: endRepeatOption,
            endRepeatDate: endRepeatDate
        )
        
        // Update additional properties
        var finalItem = scheduleItem
        finalItem.location = location
        finalItem.allDay = allDay
        finalItem.descriptionText = todoItem.notes
        
        onSave(finalItem)
    }
}

#Preview {
    ToDoView()
}
