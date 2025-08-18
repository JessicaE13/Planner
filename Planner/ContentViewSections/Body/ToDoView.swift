//
//  ToDoView.swift
//  Planner
//
//  Updated to use ScheduleItem model instead of ToDoItem with floating action button
//

import SwiftUI

// MARK: - To Do Data Manager using ScheduleItem
class ToDoDataManager: ObservableObject {
    @Published var items: [ScheduleItem] = []
    
    static let shared = ToDoDataManager()
    
    private init() {
        loadItems()
    }
    
    func addItem(_ item: ScheduleItem) {
        items.append(item)
        saveItems()
    }
    
    func updateItem(_ item: ScheduleItem) {
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
            UserDefaults.standard.set(data, forKey: "ToDoScheduleItems")
        } catch {
            print("Failed to save to-do items: \(error)")
        }
    }
    
    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: "ToDoScheduleItems") else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            items = try decoder.decode([ScheduleItem].self, from: data)
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
    
    // Filter items based on selected category - only show items with no date/time (to-dos)
    private var filteredItems: [ScheduleItem] {
        let todoItems = dataManager.items.filter { item in
            // Only show items that don't have specific dates/times set (null/blank)
            // You can customize this logic based on how you want to identify "to-do" vs "scheduled" items
            return item.frequency == .never &&
                   Calendar.current.isDate(item.startTime, inSameDayAs: item.time) // Basic to-do check
        }
        
        if let filterCategory = filterCategory {
            return todoItems.filter { $0.category?.id == filterCategory.id }
        }
        return todoItems
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
                        
                        Text("Start by adding tasks, ideas, or reminders using the + button below!")
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
                                        onMoveToSchedule: { scheduleItem in
                                            // Remove from ToDo and add to Schedule with date/time
                                            dataManager.deleteItem(withId: scheduleItem.id)
                                            ScheduleDataManager.shared.addOrUpdateItem(scheduleItem)
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100) // Extra padding for floating action button
                    }
                }
                
                Spacer()
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddToDo = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 34) // Account for tab bar
                }
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

// MARK: - Add To Do View using ScheduleItem
struct AddToDoView: View {
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var notes = ""
    @State private var selectedCategory: Category?
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
        
        // Create a ScheduleItem with null/default date/time values for to-do
        let currentDate = Date()
        let newItem = ScheduleItem(
            title: trimmedTitle,
            time: currentDate, // Default to current time, but frequency will be .never
            icon: "checklist",
            color: selectedCategory?.color ?? "Color1",
            frequency: .never, // This marks it as a to-do (not recurring)
            customFrequencyConfig: nil,
            startTime: currentDate, // Default start time
            endTime: currentDate, // Default end time (same as start for to-dos)
            checklist: checklistItems,
            uniqueKey: "todo-\(UUID().uuidString)",
            category: selectedCategory,
            endRepeatOption: .never,
            endRepeatDate: currentDate
        )
        
        // Set the description (notes) and mark as incomplete
        var finalItem = newItem
        finalItem.descriptionText = notes
        finalItem.isCompleted = false
        finalItem.allDay = false // To-dos don't need all-day flag
        finalItem.location = "" // To-dos typically don't have locations
        
        onSave(finalItem)
    }
}

struct ToDoItemRow: View {
    let item: ScheduleItem // Now using ScheduleItem instead of ToDoItem
    let onToggle: () -> Void
    let onEdit: (ScheduleItem) -> Void
    let onDelete: () -> Void
    let onMoveToSchedule: (ScheduleItem) -> Void
    
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
                // Title
                Text(item.title)
                    .font(.body)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                
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
                if !item.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(item.descriptionText)
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
                scheduleItem: item,
                onSave: { updatedScheduleItem in
                    onMoveToSchedule(updatedScheduleItem)
                    showingMoveToSchedule = false
                }
            )
        }
    }
}

// MARK: - Edit To Do View using ScheduleItem
struct EditToDoView: View {
    @State private var item: ScheduleItem
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingManageCategories = false
    @State private var newChecklistItem = ""
    
    @FocusState private var notesIsFocused: Bool
    @FocusState private var checklistInputFocused: Bool
    
    init(item: ScheduleItem, onSave: @escaping (ScheduleItem) -> Void) {
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
                        TextField("Task title", text: $item.title)
                            .font(.body)
                        
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
                    
                    Section(header: Text("Notes")) {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $item.descriptionText)
                                .frame(minHeight: 100)
                                .focused($notesIsFocused)
                                .onTapGesture {
                                    notesIsFocused = true
                                }
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)

                            if item.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Add notes...")
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 6)
                                    .allowsHitTesting(false)
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.2), value: item.descriptionText)
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
                    .disabled(item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        item.checklist.append(newItem)
        newChecklistItem = ""
        checklistInputFocused = false
    }
    
    private func deleteChecklistItems(offsets: IndexSet) {
        item.checklist.remove(atOffsets: offsets)
    }
}

// MARK: - Updated Move to Schedule View
struct MoveToScheduleView: View {
    @State private var scheduleItem: ScheduleItem
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var allDay = false
    @State private var location = ""
    @State private var frequency: Frequency = .never
    @State private var endRepeatOption: EndRepeatOption = .never
    @State private var endRepeatDate: Date
    @State private var customFrequencyConfig = CustomFrequencyConfig()
    @State private var showingCustomFrequencyPicker = false
    
    init(scheduleItem: ScheduleItem, onSave: @escaping (ScheduleItem) -> Void) {
        self._scheduleItem = State(initialValue: scheduleItem)
        self.onSave = onSave
        
        let defaultEndRepeat = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
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
                            DatePicker("", selection: $scheduleItem.startTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        
                        HStack {
                            Text("End Time")
                            Spacer()
                            DatePicker("", selection: $scheduleItem.endTime, displayedComponents: .hourAndMinute)
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
                        Text(scheduleItem.title)
                            .foregroundColor(.secondary)
                    }
                    
                    if let category = scheduleItem.category {
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
            let timeComponents = calendar.dateComponents([.hour, .minute], from: scheduleItem.startTime)
            if let newStartTime = calendar.date(bySettingHour: timeComponents.hour ?? 9,
                                               minute: timeComponents.minute ?? 0,
                                               second: 0,
                                               of: newDate) {
                scheduleItem.startTime = newStartTime
                scheduleItem.endTime = calendar.date(byAdding: .hour, value: 1, to: newStartTime) ?? newStartTime
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
            let startTimeComponents = calendar.dateComponents([.hour, .minute], from: scheduleItem.startTime)
            let endTimeComponents = calendar.dateComponents([.hour, .minute], from: scheduleItem.endTime)
            
            finalStartTime = calendar.date(bySettingHour: startTimeComponents.hour ?? 9,
                                         minute: startTimeComponents.minute ?? 0,
                                         second: 0,
                                         of: selectedDate) ?? selectedDate
            
            finalEndTime = calendar.date(bySettingHour: endTimeComponents.hour ?? 10,
                                       minute: endTimeComponents.minute ?? 0,
                                       second: 0,
                                       of: selectedDate) ?? finalStartTime
        }
        
        // Update the schedule item with new values
        var updatedItem = scheduleItem
        updatedItem.time = finalStartTime
        updatedItem.startTime = finalStartTime
        updatedItem.endTime = finalEndTime
        updatedItem.location = location
        updatedItem.allDay = allDay
        updatedItem.frequency = frequency
        updatedItem.customFrequencyConfig = frequency == .custom ? customFrequencyConfig : nil
        updatedItem.endRepeatOption = endRepeatOption
        updatedItem.endRepeatDate = endRepeatDate
        updatedItem.uniqueKey = "scheduled-\(updatedItem.id.uuidString)"
        
        onSave(updatedItem)
    }
}

#Preview {
    ToDoView()
}
