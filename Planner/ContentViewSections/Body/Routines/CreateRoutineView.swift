import SwiftUI

struct CreateRoutineView: View {
    @StateObject private var dataManager = PlannerDataManager.shared
    @Environment(\.dismiss) private var dismiss
    let isEditing: Bool
    let editingIndex: Int?
    let originalRoutineId: UUID? // Add this to track the original routine ID
    @State private var routineName = ""
    @State private var selectedIcon = "sunrise"
    @State private var selectedColor = "Color1"
    @State private var routineItems: [RoutineItem] = [RoutineItem(name: "", frequency: .everyDay)]
    @State private var frequency: Frequency = .everyDay
    @State private var endRepeatOption: EndRepeatOption = .never
    @State private var endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var startDate: Date = Date()
    @State private var showingIconPicker = false
    @State private var showingCustomFrequencyPicker = false
    @State private var customFrequencyConfig = CustomFrequencyConfig()
    @State private var showingDeleteConfirmation = false
    @State private var editingItemIndex: Int?
    @State private var showingItemDetailSheet = false
    @State private var hasManuallySelectedIcon = false
    @FocusState private var focusedItemID: UUID?
    private let availableColors: [String] = [
        "Color1", "Color2", "Color3", "Color4", "Color5", "Color6", "Color7"
    ]
    private let iconDataSource = IconDataSource.shared
    
    init() {
        self.isEditing = false
        self.editingIndex = nil
        self.originalRoutineId = nil
    }
    
    init(editingRoutine: Routine, editingIndex: Int) {
        self.isEditing = true
        self.editingIndex = editingIndex
        self.originalRoutineId = editingRoutine.id // Store the original routine ID
        self._routineName = State(initialValue: editingRoutine.name)
        self._selectedIcon = State(initialValue: editingRoutine.icon)
        self._selectedColor = State(initialValue: editingRoutine.colorName)
        let initialItems = editingRoutine.routineItems.isEmpty && !editingRoutine.items.isEmpty
        ? editingRoutine.items.map { RoutineItem(name: $0, frequency: .everyDay) }
        : editingRoutine.routineItems
        self._routineItems = State(initialValue: initialItems.isEmpty ? [RoutineItem(name: "", frequency: .everyDay)] : initialItems)
        self._frequency = State(initialValue: editingRoutine.frequency)
        self._endRepeatOption = State(initialValue: editingRoutine.endRepeatOption)
        self._endRepeatDate = State(initialValue: editingRoutine.endRepeatDate)
        self._startDate = State(initialValue: editingRoutine.startDate)
        self._customFrequencyConfig = State(initialValue: editingRoutine.customFrequencyConfig ?? CustomFrequencyConfig())
        self._hasManuallySelectedIcon = State(initialValue: true)
    }
    
    var body: some View {
        Group {
            if isEditing {
                // For editing, don't wrap in NavigationView
                contentView
            } else {
                // For creating new routines, wrap in NavigationView
                NavigationView {
                    contentView
                }
            }
        }
        .onChange(of: frequency) { _, newFrequency in
            if newFrequency == .never {
                endRepeatOption = .never
            }
            if newFrequency == .custom {
                showingCustomFrequencyPicker = true
            }
        }
    }
    
    private var contentView: some View {
        ZStack {
            Color("BackgroundPopup")
                .ignoresSafeArea()
            
            mainScrollView
        }
        .navigationTitle(isEditing ? "Edit Routine" : "New Routine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon)
                .onDisappear {
                    hasManuallySelectedIcon = true
                }
        }
        .sheet(isPresented: $showingCustomFrequencyPicker) {
            CustomFrequencyPickerView(
                customConfig: $customFrequencyConfig,
                endRepeatOption: $endRepeatOption,
                endRepeatDate: $endRepeatDate
            )
        }
        .sheet(isPresented: $showingItemDetailSheet) {
            if let editingIndex = editingItemIndex,
               editingIndex < routineItems.count {
                RoutineItemDetailView(
                    item: $routineItems[editingIndex],
                    onDelete: {
                        routineItems.remove(at: editingItemIndex!)
                        showingItemDetailSheet = false
                        self.editingItemIndex = nil
                    },
                    routineFrequency: frequency,
                    routineCustomFrequencyConfig: frequency == .custom ? customFrequencyConfig : nil
                )
            } else {
                // Fallback view if binding is not ready
                Text("Loading...")
                    .onAppear {
                        // Reset state if something went wrong
                        showingItemDetailSheet = false
                        editingItemIndex = nil
                    }
            }
        }
        .alert("Delete Routine", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteRoutine()
            }
        } message: {
            Text("Are you sure you want to delete this routine? This action cannot be undone.")
        }
    }
    
    private var mainScrollView: some View {
        ScrollViewReader { proxy in
            Form {
                routineDetailsSection
                
                if isEditing {
                    routineFrequencySection
                }
                
                routineItemsSection(proxy: proxy)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }
    
    private var routineDetailsSection: some View {
        Section(header: Text("Routine Details")) {
            HStack {
                Button(action: {
                    showingIconPicker = true
                }) {
                    Image(systemName: selectedIcon)
                        .foregroundColor(Color(selectedColor))
                        .frame(width: 36, height: 36)
                }
                
                TextField("Routine Name", text: $routineName)
                    .onChange(of: routineName) { _, newValue in
                        if !hasManuallySelectedIcon && !isEditing {
                            updateIconBasedOnName(newValue)
                        }
                    }
                
                Spacer()
            }
            HStack {
                Text("Start Date")
                Spacer()
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
            }
            colorSelectionView
        }
        .id("top")
    }
    
    private var colorSelectionView: some View {
        HStack {
            Text("Color")
            Spacer()
            HStack(spacing: 12) {
                ForEach(Array(availableColors.enumerated()), id: \.offset) { index, colorName in
                    Button(action: {
                        selectedColor = colorName
                    }) {
                        Circle()
                            .fill(Color(colorName))
                            .frame(width: 25, height: 25)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == colorName ? Color.primary : Color.clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var routineFrequencySection: some View {
        Section(header: Text("Overall Routine Frequency")) {
            frequencySelectionView
            
            if frequency != .never {
                endRepeatSelectionView
            }
            
            Text("This controls when the entire routine appears in your daily view. Individual items can have their own frequencies.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var frequencySelectionView: some View {
        HStack {
            Text("Routine Repeat")
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
    }
    
    private var endRepeatSelectionView: some View {
        VStack(spacing: 8) {
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
    
    private func routineItemsSection(proxy: ScrollViewProxy) -> some View {
        Section(header: Text("Routine Items")) {
            ForEach(routineItems) { item in
                routineItemRow(item: item)
            }
            .onMove(perform: moveItems)
            
            addItemButton(proxy: proxy)
        }
    }
    
    private func routineItemRow(item: RoutineItem) -> some View {
        let index = routineItems.firstIndex(where: { $0.id == item.id }) ?? 0
        
        return HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.caption)
            
            routineItemTextField(item: item, index: index)
            
            Spacer()
            
            if isEditing && item.frequency != .everyDay {
                frequencyBadge(for: item)
            }
            
            if !item.name.isEmpty || routineItems.count > 1 {
                itemOptionsButton(item: item)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func routineItemTextField(item: RoutineItem, index: Int) -> some View {
        TextField("Item \(index + 1)", text: Binding(
            get: {
                guard let currentIndex = routineItems.firstIndex(where: { $0.id == item.id }) else { return "" }
                return routineItems[currentIndex].name
            },
            set: { newValue in
                guard let currentIndex = routineItems.firstIndex(where: { $0.id == item.id }) else { return }
                let oldValue = routineItems[currentIndex].name
                routineItems[currentIndex].name = newValue
                
                // Handle backspace when text becomes empty (works on iPhone)
                if oldValue.count == 1 && newValue.isEmpty && routineItems.count > 1 {
                    // This means backspace was pressed on a single character, making it empty
                    DispatchQueue.main.async {
                        handleBackspaceFor(item)
                    }
                }
            }
        ))
        .focused($focusedItemID, equals: item.id)
        .onSubmit {
            createNewItemAfter(item)
        }
    }
    
    private func frequencyBadge(for item: RoutineItem) -> some View {
        HStack(spacing: 4) {
            if item.frequency == .custom {
                Text(item.customFrequencyConfig?.displayDescription() ?? "Custom")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text(item.frequency.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func itemOptionsButton(item: RoutineItem) -> some View {
        Button(action: {
            guard let currentIndex = routineItems.firstIndex(where: { $0.id == item.id }) else { return }
            editingItemIndex = currentIndex
            // Delay the sheet presentation slightly to ensure the editingItemIndex is properly set
            DispatchQueue.main.async {
                showingItemDetailSheet = true
            }
        }) {
            Image(systemName: "ellipsis")
                .foregroundColor(.secondary)
                .frame(width: 20, height: 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func addItemButton(proxy: ScrollViewProxy) -> some View {
        Button(action: {
            let newItem = RoutineItem(name: "", frequency: .everyDay)
            withAnimation(.easeInOut(duration: 0.2)) {
                routineItems.append(newItem)
            }
            // Scroll to bottom to show the new item
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo("addButton", anchor: .bottom)
            }
            // Delay focus slightly to allow scrolling and TextField to render
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                focusedItemID = newItem.id
            }
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                Text("Add Item")
            }
        }
        .buttonStyle(PlainButtonStyle())
        .id("addButton")
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if !isEditing {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
                saveRoutine()
            }
            .disabled(routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
    
    @ViewBuilder
    private var itemDetailSheet: some View {
        if let editingIndex = editingItemIndex {
            RoutineItemDetailView(
                item: $routineItems[editingIndex],
                onDelete: {
                    routineItems.remove(at: editingItemIndex!)
                    showingItemDetailSheet = false
                    self.editingItemIndex = nil
                },
                routineFrequency: frequency,
                routineCustomFrequencyConfig: frequency == .custom ? customFrequencyConfig : nil
            )
        }
    }
    
    // MARK: - Helper functions
    private func createNewItemAfter(_ item: RoutineItem) {
        let newItem = RoutineItem(name: "", frequency: .everyDay)
        withAnimation(.easeInOut(duration: 0.2)) {
            if let currentIndex = routineItems.firstIndex(where: { $0.id == item.id }) {
                routineItems.insert(newItem, at: currentIndex + 1)
            } else {
                routineItems.append(newItem)
            }
        }
        // Focus the new item after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focusedItemID = newItem.id
        }
    }
    
    private func handleBackspaceFor(_ item: RoutineItem) {
        guard let currentIndex = routineItems.firstIndex(where: { $0.id == item.id }) else { return }
        
        // Only delete if the current item is empty and we have more than one item
        if routineItems[currentIndex].name.isEmpty && routineItems.count > 1 {
            // Find the previous item to focus on
            let previousIndex = currentIndex > 0 ? currentIndex - 1 : 0
            let previousItemID = previousIndex < routineItems.count ? routineItems[previousIndex].id : nil
            
            // Remove the current empty item
            _ = withAnimation(.easeInOut(duration: 0.2)) {
                routineItems.remove(at: currentIndex)
            }
            
            // Focus the previous item
            if let previousID = previousItemID {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedItemID = previousID
                }
            }
        }
    }
    
    private func updateIconBasedOnName(_ name: String) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Use the existing filtering functionality to find a matching icon
        let filteredCategories = iconDataSource.getFilteredCategories(searchText: name)
        
        // Get the first matching icon from the filtered results
        if let firstCategory = filteredCategories.first,
           let firstIcon = firstCategory.icons.first {
            selectedIcon = firstIcon.name
        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        routineItems.move(fromOffsets: source, toOffset: destination)
    }
    
    private func saveRoutine() {
        let trimmedName = routineName.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredItems = routineItems.compactMap { item in
            let trimmed = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : RoutineItem(
                name: trimmed,
                frequency: item.frequency,
                customFrequencyConfig: item.customFrequencyConfig,
                endRepeatOption: item.endRepeatOption,
                endRepeatDate: item.endRepeatDate
            )
        }
        guard !trimmedName.isEmpty, !filteredItems.isEmpty else { return }
        
        if isEditing, let _ = editingIndex, let routineId = originalRoutineId {
            // Find the routine by ID to ensure we're editing the correct one
            guard let currentRoutineIndex = dataManager.routines.firstIndex(where: { $0.id == routineId }) else {
                print("Error: Could not find routine with ID \(routineId) to update")
                return
            }
            
            // Create a completely new routine object with the same ID to avoid reference issues
            let updatedRoutine = Routine(
                name: trimmedName,
                icon: selectedIcon,
                routineItems: filteredItems,
                items: [],
                colorName: selectedColor,
                frequency: frequency,
                customFrequencyConfig: frequency == .custom ? customFrequencyConfig : nil,
                endRepeatOption: endRepeatOption,
                endRepeatDate: endRepeatDate,
                startDate: startDate
            )
            
            // Preserve the original ID and other important data
            var finalRoutine = updatedRoutine
            finalRoutine.id = routineId
            finalRoutine.createdDate = dataManager.routines[currentRoutineIndex].createdDate
            finalRoutine.completedItemsByDate = dataManager.routines[currentRoutineIndex].completedItemsByDate
            
            dataManager.updateRoutine(finalRoutine)
        } else {
            // Creating a new routine - ensure it has a unique ID
            let newRoutine = Routine(
                name: trimmedName,
                icon: selectedIcon,
                routineItems: filteredItems,
                items: [],
                colorName: selectedColor,
                frequency: frequency,
                customFrequencyConfig: frequency == .custom ? customFrequencyConfig : nil,
                endRepeatOption: endRepeatOption,
                endRepeatDate: endRepeatDate,
                startDate: startDate
            )
            dataManager.addRoutine(newRoutine)
        }
        dismiss()
    }
    
    private func deleteRoutine() {
        if let routineId = originalRoutineId {
            dataManager.deleteRoutine(withId: routineId)
            dismiss()
        }
    }
}
