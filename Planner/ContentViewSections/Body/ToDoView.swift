//
//  ToDoView.swift
//  Planner
//
//  Updated to use UnifiedDataManager for consistency
//

import SwiftUI

struct ToDoView: View {
    @StateObject private var dataManager = UnifiedDataManager.shared
    @State private var filterCategory: Category?
    @State private var showingFilterOptions = false
    @State private var showingAddToDo = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    // Filter items based on selected category - only show to-do items
    private var filteredItems: [ScheduleItem] {
        let todoItems = dataManager.toDoItems
        
        if let filterCategory = filterCategory {
            return todoItems.filter { $0.category?.id == filterCategory.id }
        }
        return todoItems
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundPopup")
                .ignoresSafeArea()
            
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
                        .foregroundColor(.primary)
                    }
                    
                    // Clear completed button
                    if filteredItems.contains(where: { $0.isCompleted }) {
                        Button("Clear Done") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dataManager.clearCompletedToDoItems()
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
                
                if filteredItems.isEmpty {
                    // Empty state - centered
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "checklist.unchecked")
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
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredItems.indices, id: \.self) { filteredIndex in
                          
                                if let actualIndex = dataManager.items.firstIndex(where: { $0.id == filteredItems[filteredIndex].id }) {
                                    ToDoItemRow(
                                        item: dataManager.items[actualIndex],
                                        onToggle: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                dataManager.items[actualIndex].isCompleted.toggle()
                                                dataManager.updateItem(dataManager.items[actualIndex])
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
                                        onMoveToSchedule: { scheduledInfo in
                                            // Move the item to schedule using the unified data manager
                                            let toDoItem = dataManager.items[actualIndex]
                                            dataManager.moveToDoToSchedule(toDoItem, scheduledInfo: scheduledInfo)
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
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
                            .foregroundColor(Color("BackgroundPopup"))
                            .frame(width: 56, height: 56)
                            .background(Color.primary)
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
                Color("BackgroundPopup")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                                            .foregroundColor(checklistItem.isCompleted ? .primary : .gray)
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
                                    .foregroundColor(.primary)
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
                                    .foregroundColor(.primary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                    // Bottom Save Button
                    VStack {
                        Divider()
                        
                        Button(action: {
                            saveTask()
                        }) {
                            HStack {
                                Spacer()
                                Text("Save Task")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                          Color.gray.opacity(0.5) : Color.blue)
                            )
                        }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color("BackgroundPopup"))
                }
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
        
        // Create a to-do item using the convenience method
        let newItem = ScheduleItem.createToDo(
            title: trimmedTitle,
            descriptionText: notes,
            category: selectedCategory,
            checklist: checklistItems
        )
        
        onSave(newItem)
    }
}

struct ToDoItemRow: View {
    let item: ScheduleItem
    let onToggle: () -> Void
    let onEdit: (ScheduleItem) -> Void
    let onDelete: () -> Void
    let onMoveToSchedule: (ScheduledInfo) -> Void
    
    @State private var showingEditSheet = false
    @State private var showingMoveToSchedule = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
   
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .primary : .gray)
            }
            .buttonStyle(PlainButtonStyle())
  
            VStack(alignment: .leading, spacing: 6) {

                Text(item.title)
                    .font(.body)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                
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
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
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
                onSave: { scheduledInfo in
                    onMoveToSchedule(scheduledInfo)
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
                                        .foregroundColor(checklistItem.isCompleted ? .primary : .gray)
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
                                .foregroundColor(.primary)
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
                                .foregroundColor(.primary)
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
    let scheduleItem: ScheduleItem
    let onSave: (ScheduledInfo) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var allDay = false
    @State private var location = ""
    @State private var frequency: Frequency = .never
    @State private var endRepeatOption: EndRepeatOption = .never
    @State private var endRepeatDate: Date
    @State private var customFrequencyConfig = CustomFrequencyConfig()
    @State private var showingCustomFrequencyPicker = false
    
    // Icon selection states
    @State private var selectedIcon: String
    @State private var showingIconPicker = false
    
    // Helper function to get the next upcoming hour
    private static func nextUpcomingHour(from date: Date) -> Date {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: date)
        let currentMinute = calendar.component(.minute, from: date)
        
        // If we're at the top of the hour (0 minutes), use current hour
        // Otherwise, move to the next hour
        let targetHour = currentMinute == 0 ? currentHour : currentHour + 1
        
        // Set to the target hour with 0 minutes and 0 seconds
        return calendar.date(bySettingHour: targetHour, minute: 0, second: 0, of: date) ?? date
    }
    
    init(scheduleItem: ScheduleItem, onSave: @escaping (ScheduledInfo) -> Void) {
        self.scheduleItem = scheduleItem
        self.onSave = onSave
        
        let defaultEndRepeat = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        self._endRepeatDate = State(initialValue: defaultEndRepeat)
        
        // Initialize icon state
        self._selectedIcon = State(initialValue: scheduleItem.icon)
        
        // Initialize start and end times using smart defaults
        let calendar = Calendar.current
        let now = Date()
        let defaultStart = Self.nextUpcomingHour(from: now)
        let defaultEnd = calendar.date(byAdding: .hour, value: 1, to: defaultStart) ?? defaultStart
        
        self._startTime = State(initialValue: defaultStart)
        self._endTime = State(initialValue: defaultEnd)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Button(action: {
                            showingIconPicker = true
                        }) {
                            Image(systemName: selectedIcon)
                                .foregroundColor(.primary)
                                .padding(.trailing, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(scheduleItem.title)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            if let category = scheduleItem.category {
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
                        }
                        
                        Spacer()
                    }
                }
                
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
                                .onChange(of: startTime) { _, newStartTime in
                                    // Automatically update end time to be one hour after start time
                                    let calendar = Calendar.current
                                    endTime = calendar.date(byAdding: .hour, value: 1, to: newStartTime) ?? newStartTime
                                }
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
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon)
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
        
        // Create the ScheduledInfo struct
        let scheduledInfo = ScheduledInfo(
            startTime: finalStartTime,
            endTime: finalEndTime,
            location: location,
            allDay: allDay,
            frequency: frequency,
            customFrequencyConfig: frequency == .custom ? customFrequencyConfig : nil,
            endRepeatOption: endRepeatOption,
            endRepeatDate: endRepeatDate,
            icon: selectedIcon
        )
        
        onSave(scheduledInfo)
    }
}

#Preview {
    ToDoView()
}
