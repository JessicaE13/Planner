import SwiftUI

struct RoutineItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var frequency: Frequency = .everyDay
    var customFrequencyConfig: CustomFrequencyConfig? = nil
    var endRepeatOption: EndRepeatOption = .never
    var endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    init(name: String, frequency: Frequency = .everyDay, customFrequencyConfig: CustomFrequencyConfig? = nil, endRepeatOption: EndRepeatOption = .never, endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()) {
        self.name = name
        self.frequency = frequency
        self.customFrequencyConfig = customFrequencyConfig
        self.endRepeatOption = endRepeatOption
        self.endRepeatDate = endRepeatDate
    }
    
    
    
    enum CodingKeys: String, CodingKey {
        case id, name, frequency, customFrequencyConfig, endRepeatOption, endRepeatDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        frequency = try container.decodeIfPresent(Frequency.self, forKey: .frequency) ?? .everyDay
        customFrequencyConfig = try container.decodeIfPresent(CustomFrequencyConfig.self, forKey: .customFrequencyConfig)
        endRepeatOption = try container.decodeIfPresent(EndRepeatOption.self, forKey: .endRepeatOption) ?? .never
        endRepeatDate = try container.decodeIfPresent(Date.self, forKey: .endRepeatDate) ?? Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(customFrequencyConfig, forKey: .customFrequencyConfig)
        try container.encode(endRepeatOption, forKey: .endRepeatOption)
        try container.encode(endRepeatDate, forKey: .endRepeatDate)
    }
    
    func shouldAppear(on date: Date, routineStartDate: Date) -> Bool {
        if frequency == .never {
            return Calendar.current.isDate(routineStartDate, inSameDayAs: date)
        }
        let shouldTrigger = frequency.shouldTrigger(on: date, from: routineStartDate, customConfig: customFrequencyConfig)
        if !shouldTrigger {
            return false
        }
        if endRepeatOption == .onDate {
            return date <= endRepeatDate
        }
        return true
    }
}

struct Routine: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var icon: String
    var routineItems: [RoutineItem] = []
    var items: [String] = []
    var iconName: String {
        return icon
    }
    var colorName: String = "Color1"
    var color: Color {
        return Color(colorName)
    }
    
    var completedItemsByDate: [String: Set<String>] = [:]
    
    var frequency: Frequency = .everyDay
    var customFrequencyConfig: CustomFrequencyConfig? = nil
    var endRepeatOption: EndRepeatOption = .never
    var endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    var startDate: Date = Date()
    
    init(name: String, icon: String, routineItems: [RoutineItem] = [], items: [String] = [], colorName: String = "Color1", frequency: Frequency = .everyDay, customFrequencyConfig: CustomFrequencyConfig? = nil, endRepeatOption: EndRepeatOption = .never, endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(), startDate: Date = Date()) {
        self.name = name
        self.icon = icon
        self.routineItems = routineItems
        self.items = items
        self.colorName = colorName
        self.frequency = frequency
        self.customFrequencyConfig = customFrequencyConfig
        self.endRepeatOption = endRepeatOption
        self.endRepeatDate = endRepeatDate
        self.startDate = startDate
        
        if routineItems.isEmpty && !items.isEmpty {
            self.routineItems = items.map { RoutineItem(name: $0, frequency: .everyDay) }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, routineItems, items, completedItemsByDate, frequency, customFrequencyConfig, endRepeatOption, endRepeatDate, startDate, colorName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        routineItems = try container.decodeIfPresent([RoutineItem].self, forKey: .routineItems) ?? []
        items = try container.decodeIfPresent([String].self, forKey: .items) ?? []
        completedItemsByDate = try container.decodeIfPresent([String: Set<String>].self, forKey: .completedItemsByDate) ?? [:]
        frequency = try container.decodeIfPresent(Frequency.self, forKey: .frequency) ?? .everyDay
        customFrequencyConfig = try container.decodeIfPresent(CustomFrequencyConfig.self, forKey: .customFrequencyConfig)
        endRepeatOption = try container.decodeIfPresent(EndRepeatOption.self, forKey: .endRepeatOption) ?? .never
        endRepeatDate = try container.decodeIfPresent(Date.self, forKey: .endRepeatDate) ?? Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        colorName = try container.decodeIfPresent(String.self, forKey: .colorName) ?? "Color1"
        if routineItems.isEmpty && !items.isEmpty {
            routineItems = items.map { RoutineItem(name: $0, frequency: .everyDay) }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(routineItems, forKey: .routineItems)
        try container.encode(items, forKey: .items)
        try container.encode(completedItemsByDate, forKey: .completedItemsByDate)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(customFrequencyConfig, forKey: .customFrequencyConfig)
        try container.encode(endRepeatOption, forKey: .endRepeatOption)
        try container.encode(endRepeatDate, forKey: .endRepeatDate)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(colorName, forKey: .colorName)
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func completedItems(for date: Date) -> Set<String> {
        let key = dateKey(for: date)
        return completedItemsByDate[key] ?? []
    }
    
    func visibleItems(for date: Date) -> [RoutineItem] {
        return routineItems.filter { item in
            item.shouldAppear(on: date, routineStartDate: startDate)
        }
    }
    
    func progress(for date: Date) -> Double {
        let visibleItems = self.visibleItems(for: date)
        guard !visibleItems.isEmpty else { return 0 }
        let completed = completedItems(for: date)
        let visibleItemNames = Set(visibleItems.map { $0.name })
        let completedVisibleItems = completed.intersection(visibleItemNames)
        return Double(completedVisibleItems.count) / Double(visibleItems.count)
    }
    
    mutating func toggleItem(_ itemName: String, for date: Date) {
        let key = dateKey(for: date)
        var completedForDate = completedItemsByDate[key] ?? []
        if completedForDate.contains(itemName) {
            completedForDate.remove(itemName)
        } else {
            completedForDate.insert(itemName)
        }
        completedItemsByDate[key] = completedForDate
    }
    
    func isItemCompleted(_ itemName: String, for date: Date) -> Bool {
        let completed = completedItems(for: date)
        return completed.contains(itemName)
    }
    
    func shouldAppear(on date: Date) -> Bool {
        let shouldTrigger = frequency.shouldTrigger(on: date, from: startDate, customConfig: customFrequencyConfig)
        if !shouldTrigger {
            return false
        }
        if endRepeatOption == .onDate {
            return date <= endRepeatDate
        }
        return true
    }
}

struct CreateRoutineView: View {
    @Binding var routines: [Routine]
    @Environment(\.dismiss) private var dismiss
    let isEditing: Bool
    let editingIndex: Int?
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
        "Color1", "Color2", "Color3", "Color4", "Color5"
    ]
    private let iconDataSource = IconDataSource.shared
    init(routines: Binding<[Routine]>) {
        self._routines = routines
        self.isEditing = false
        self.editingIndex = nil
    }
    init(routines: Binding<[Routine]>, editingRoutine: Routine, editingIndex: Int) {
        self._routines = routines
        self.isEditing = true
        self.editingIndex = editingIndex
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
            IconPickerView(selectedIcon: $selectedIcon, initialSearchText: routineName)
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
            itemDetailSheet
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
            Text("Choose Color")
            Spacer()
            HStack(spacing: 12) {
                ForEach(Array(availableColors.enumerated()), id: \.offset) { index, colorName in
                    Button(action: {
                        selectedColor = colorName
                    }) {
                        Circle()
                            .fill(Color(colorName))
                            .frame(width: 30, height: 30)
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
                routineItems[currentIndex].name = newValue
            }
        ))
        .focused($focusedItemID, equals: item.id)
        .onSubmit {
            createNewItemAfter(item)
        }
        .onKeyPress { keyPress in
            // Check for backspace/delete key when the field is empty
            if keyPress.characters == "\u{8}" || keyPress.characters == "\u{7F}" {
                guard let currentIndex = routineItems.firstIndex(where: { $0.id == item.id }) else { return .ignored }
                
                // Only handle backspace if the current item is empty and we have more than one item
                if routineItems[currentIndex].name.isEmpty && routineItems.count > 1 {
                    return handleBackspaceFor(item)
                }
            }
            return .ignored
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
            showingItemDetailSheet = true
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
    
    // Helper functions for item management
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
    
    private func handleBackspaceFor(_ item: RoutineItem) -> KeyPress.Result {
        guard let currentIndex = routineItems.firstIndex(where: { $0.id == item.id }) else { return .ignored }
        
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
            
            return .handled
        }
        
        return .ignored
    }
    
    private func updateIconBasedOnName(_ name: String) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        let matchedIcon = iconDataSource.getFirstMatchingIconByWords(
            searchText: name,
            defaultIcon: selectedIcon
        )
        if matchedIcon != selectedIcon {
            selectedIcon = matchedIcon
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
        if isEditing, let index = editingIndex {
            var updatedRoutine = routines[index]
            updatedRoutine.name = trimmedName
            updatedRoutine.icon = selectedIcon
            updatedRoutine.colorName = selectedColor
            updatedRoutine.routineItems = filteredItems
            updatedRoutine.items = []
            updatedRoutine.frequency = frequency
            updatedRoutine.customFrequencyConfig = frequency == .custom ? customFrequencyConfig : nil
            updatedRoutine.endRepeatOption = endRepeatOption
            updatedRoutine.endRepeatDate = endRepeatDate
            updatedRoutine.startDate = startDate
            routines[index] = updatedRoutine
        } else {
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
            routines.append(newRoutine)
        }
        dismiss()
    }
    
    private func deleteRoutine() {
        if let index = editingIndex {
            routines.remove(at: index)
            dismiss()
        }
    }
}

struct RoutineItemDetailView: View {
    @Binding var item: RoutineItem
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingCustomFrequencyPicker = false
    @State private var customFrequencyConfig: CustomFrequencyConfig
    @State private var showingDeleteConfirmation = false
    @State private var useRoutineFrequency = false
    
    // Add properties to access the parent routine's frequency
    let routineFrequency: Frequency
    let routineCustomFrequencyConfig: CustomFrequencyConfig?
    
    init(item: Binding<RoutineItem>, onDelete: @escaping () -> Void, routineFrequency: Frequency = .everyDay, routineCustomFrequencyConfig: CustomFrequencyConfig? = nil) {
        self._item = item
        self.onDelete = onDelete
        self.routineFrequency = routineFrequency
        self.routineCustomFrequencyConfig = routineCustomFrequencyConfig
        
        if let existingConfig = item.wrappedValue.customFrequencyConfig {
            self._customFrequencyConfig = State(initialValue: existingConfig)
        } else {
            self._customFrequencyConfig = State(initialValue: CustomFrequencyConfig())
        }
        
        // Check if item is currently using routine frequency
        self._useRoutineFrequency = State(initialValue: item.wrappedValue.frequency == routineFrequency)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundPopup")
                    .edgesIgnoringSafeArea(.all)
                Form {
                    Section(header: Text("Item Details")) {
                        TextField("Item Name", text: $item.name)
                    }
                    Section(header: Text("Frequency")) {
                        // Add "Use Routine Frequency" option first
                        Button(action: {
                            useRoutineFrequency = true
                            item.frequency = routineFrequency
                            if routineFrequency == .custom {
                                item.customFrequencyConfig = routineCustomFrequencyConfig
                            } else {
                                item.customFrequencyConfig = nil
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Use Routine Frequency")
                                        .foregroundColor(.primary)
                                    if routineFrequency == .custom {
                                        Text(routineCustomFrequencyConfig?.displayDescription() ?? "Custom")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text(routineFrequency.displayName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                if useRoutineFrequency && item.frequency == routineFrequency {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        // Show other frequency options
                        ForEach(Frequency.allCases) { frequency in
                            Button(action: {
                                useRoutineFrequency = false
                                item.frequency = frequency
                                if frequency == .custom {
                                    showingCustomFrequencyPicker = true
                                } else {
                                    item.customFrequencyConfig = nil
                                }
                            }) {
                                HStack {
                                    if frequency == .custom && item.frequency == .custom && !useRoutineFrequency {
                                        Text(customFrequencyConfig.displayDescription())
                                            .foregroundColor(.primary)
                                    } else {
                                        Text(frequency.displayName)
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    if !useRoutineFrequency && item.frequency == frequency {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    if item.frequency != .never {
                        Section(header: Text("End Repeat")) {
                            Picker("End Repeat", selection: $item.endRepeatOption) {
                                ForEach(EndRepeatOption.allCases) { option in
                                    Text(option.displayName).tag(option)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            if item.endRepeatOption == .onDate {
                                DatePicker("End Date", selection: $item.endRepeatDate, displayedComponents: .date)
                            }
                        }
                    }
                    Section {
                        Button("Delete Item", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                    Section {
                        if useRoutineFrequency {
                            Text("This item will follow the routine's overall frequency.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("This frequency will override the routine's overall frequency for this specific item.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .navigationTitle("Edit Item")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            if item.frequency == .custom && !useRoutineFrequency {
                                item.customFrequencyConfig = customFrequencyConfig
                            }
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCustomFrequencyPicker) {
                CustomFrequencyPickerView(
                    customConfig: $customFrequencyConfig,
                    endRepeatOption: $item.endRepeatOption,
                    endRepeatDate: $item.endRepeatDate
                )
            }
            .alert("Delete Item", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text("Are you sure you want to delete this item? This action cannot be undone.")
            }
            .onChange(of: item.frequency) { _, newFrequency in
                if newFrequency == .never {
                    item.endRepeatOption = .never
                }
                if newFrequency == .custom && !useRoutineFrequency {
                    showingCustomFrequencyPicker = true
                }
                // Update useRoutineFrequency state based on frequency match
                useRoutineFrequency = (newFrequency == routineFrequency)
            }
        }
    }
}

struct RoutineDetailBottomSheetView: View {
    @Binding var routine: Routine
    let selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var originalRoutine: Routine
    @State private var workingRoutine: Routine
    
    init(routine: Binding<Routine>, selectedDate: Date) {
        self._routine = routine
        self.selectedDate = selectedDate
        self._originalRoutine = State(initialValue: routine.wrappedValue)
        self._workingRoutine = State(initialValue: routine.wrappedValue)
    }
    
    private var visibleItems: [RoutineItem] {
        return workingRoutine.visibleItems(for: selectedDate)
    }
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: workingRoutine.icon)
                        .font(.system(size: 48))
                        .foregroundColor(workingRoutine.color)
                        .frame(minHeight: 56, alignment: .center)
                  
                    VStack(alignment: .leading, spacing: 8) {
                        Text(workingRoutine.name + " Routine")
                            .font(.title)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)
                        
                        ProgressView(value: workingRoutine.progress(for: selectedDate), total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: workingRoutine.color))
                            .scaleEffect(y: 1.5)
                            .animation(.easeInOut(duration: 0.3), value: workingRoutine.progress(for: selectedDate))
                            .padding(.trailing, 16)
                    }
                }
                if visibleItems.count != workingRoutine.routineItems.count {
                    Text("\(visibleItems.count) of \(workingRoutine.routineItems.count) items today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 32)
            .padding(.horizontal, 32)
            
            ScrollView {
                
                if !visibleItems.isEmpty {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ForEach(visibleItems.indices, id: \.self) { index in
                                let item = visibleItems[index]
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        workingRoutine.toggleItem(item.name, for: selectedDate)
                                        // Don't save to routine binding immediately
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: workingRoutine.isItemCompleted(item.name, for: selectedDate) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(workingRoutine.isItemCompleted(item.name, for: selectedDate) ? .primary : .gray)
                                            .animation(.easeInOut(duration: 0.3), value: workingRoutine.isItemCompleted(item.name, for: selectedDate))
                                        Text(item.name)
                                            .strikethrough(workingRoutine.isItemCompleted(item.name, for: selectedDate))
                                            .foregroundColor(workingRoutine.isItemCompleted(item.name, for: selectedDate) ? .secondary : .primary)
                                            .animation(.easeInOut(duration: 0.3), value: workingRoutine.isItemCompleted(item.name, for: selectedDate))
                                        Spacer()
                                        if item.frequency != workingRoutine.frequency {
                                            HStack(spacing: 4) {
                                                Image(systemName: "repeat")
                                                    .font(.caption2)
                                                if item.frequency == .custom {
                                                    Text(item.customFrequencyConfig?.displayDescription() ?? "Custom")
                                                        .font(.caption)
                                                } else {
                                                    Text(item.frequency.displayName)
                                                        .font(.caption)
                                                }
                                            }
                                            .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .padding(.trailing, 16)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                if index < visibleItems.count {
                                    Divider()
                                        .padding(.leading, 36)
                                        .padding(.trailing, 24)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No items scheduled for today")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("This routine has items with different frequencies. Check back on other days or edit the routine to adjust item schedules.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 40)
                }
                
                Spacer()
            }
            
            
            HStack {
                
                Button("Done") {
                    // Save changes to the routine binding before dismissing
                    routine = workingRoutine
                    dismiss()
                }
                .font(.headline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(workingRoutine.color.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 8)
                .padding(.bottom, 24)
                
//                Button("Done") {
//                    dismiss()
//                }
//                .font(.headline)
//                .padding(.vertical, 12)
//                .frame(maxWidth: .infinity)
//                .background(workingRoutine.color.opacity(0.9))
//                .foregroundColor(.white)
//                .cornerRadius(12)
//                .padding(.horizontal, 8)
//                .padding(.bottom, 24)
//
            }
            .padding(.horizontal, 36)
            .padding(.top, 24)
            
            
        }
        .navigationTitle("Routine")
        .navigationBarTitleDisplayMode(.inline)
        .background( Color("BackgroundPopup"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: EditRoutineNavigationView(routine: $routine)) {
                    Text("Edit")
                        .foregroundColor(.primary)
                }
            }
        }
        .onChange(of: routine) { _, newRoutine in
            // Update workingRoutine when the bound routine changes (e.g., after editing)
            workingRoutine = newRoutine
        }
        
    }
}


struct EditRoutineNavigationView: View {
    @Binding var routine: Routine
    @State private var routines: [Routine] = []
    @State private var routineIndex: Int = 0
    @Environment(\.dismiss) private var dismiss
    
    init(routine: Binding<Routine>) {
        self._routine = routine
    }
    
    var body: some View {
        CreateRoutineView(
            routines: $routines,
            editingRoutine: routine,
            editingIndex: routineIndex
        )
        .onAppear {
            routines = [routine]
            routineIndex = 0
        }
        .onChange(of: routines) { _, newRoutines in
            // Update the original routine binding immediately when routines array changes
            if routineIndex < newRoutines.count {
                routine = newRoutines[routineIndex]
            }
        }
        .onDisappear {
            // Ensure the routine is updated when view disappears as a fallback
            if routines.indices.contains(routineIndex) {
                routine = routines[routineIndex]
            }
        }
    }
}

struct RoutineView: View {
    var selectedDate: Date
    @Binding var routines: [Routine]
    @Binding var showRoutineDetail: Bool
    @Binding var selectedRoutineIndex: Int?
    @State private var showCreateRoutine = false
    @State private var editingRoutine: Routine?
    @State private var editingRoutineIndex: Int?
    @State private var showingRoutineDetail: Routine?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    private var visibleRoutines: [(routine: Routine, index: Int)] {
        return routines.enumerated().compactMap { index, routine in
            if routine.shouldAppear(on: selectedDate) {
                return (routine: routine, index: index)
            }
            return nil
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Routines")
                    .sectionHeaderStyle()
                Spacer()
                Button(action: {
                    showCreateRoutine = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (spacing: 16) {
                    ForEach(visibleRoutines.indices, id: \.self) { idx in
                        let routineData = visibleRoutines[idx]
                        Button(action: {
                            showingRoutineDetail = routineData.routine
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("Background"))
                                    .frame(width: 176, height: 100)
                                VStack {
                                    HStack(alignment: .bottom) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(routineData.routine.name)
                                                .font(.title3)
                                                .kerning(0.5)
                                                .foregroundColor(.primary)
                                            Text("Routine")
                                                .font(.caption2)
                                            // .kerning(0.5)
                                                .textCase(.uppercase)
                                                .foregroundColor(.primary.opacity(0.75))
                                        }
                                        Spacer()
                                        Image(systemName: routineData.routine.icon)
                                            .frame(width: 36, height: 36)
                                            .font(.largeTitle)
                                            .foregroundColor(Color(routineData.routine.color).opacity(0.75))
                                    }
                                    .padding(.horizontal, 8)
                                    ProgressView(value: routineData.routine.progress(for: selectedDate), total: 1.0)
                                        .progressViewStyle(LinearProgressViewStyle(tint: Color(routineData.routine.color)))
                                        .scaleEffect(y: 1.5)
                                        .padding(.top, 8)
                                        .animation(.easeInOut(duration: 0.3), value: routineData.routine.progress(for: selectedDate))
                                }
                                .frame(width: 144)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.leading, idx == 0 ? 36 : 0)
                        .padding(.trailing, idx == visibleRoutines.count - 1 ? 16 : 0)
                    }
                }
            }
        }
        .sheet(item: $showingRoutineDetail) { routine in
            if let index = routines.firstIndex(where: { $0.id == routine.id }) {
                NavigationView {
                    RoutineDetailBottomSheetView(
                        routine: $routines[index],
                        selectedDate: selectedDate
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                // Don't save any changes - just dismiss
                                showingRoutineDetail = nil
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateRoutine) {
            CreateRoutineView(routines: $routines)
        }
        .sheet(isPresented: Binding(
            get: { editingRoutine != nil },
            set: { isPresented in
                if !isPresented {
                    editingRoutine = nil
                    editingRoutineIndex = nil
                }
            }
        )) {
            if let routine = editingRoutine, let editIndex = editingRoutineIndex {
                CreateRoutineView(
                    routines: $routines,
                    editingRoutine: routine,
                    editingIndex: editIndex
                )
                .onDisappear {
                    editingRoutine = nil
                    editingRoutineIndex = nil
                }
            }
        }
        .onAppear {
            updateDefaultRoutinesStartDate()
            migrateRoutines()
        }
    }
    private func updateDefaultRoutinesStartDate() {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        for index in routines.indices {
            if Calendar.current.isDate(routines[index].startDate, inSameDayAs: Date()) {
                routines[index].startDate = weekAgo
            }
        }
    }
    private func migrateRoutines() {
        var needsUpdate = false
        let defaultColors = ["Color1", "Color2", "Color3", "Color4", "Color5"]
        for index in routines.indices {
            if routines[index].routineItems.isEmpty && !routines[index].items.isEmpty {
                routines[index].routineItems = routines[index].items.map {
                    RoutineItem(name: $0, frequency: .everyDay)
                }
                needsUpdate = true
            }
            if routines[index].colorName.isEmpty {
                routines[index].colorName = defaultColors[index % defaultColors.count]
                needsUpdate = true
            }
        }
        if needsUpdate {
            print("Migrated routines from legacy format and assigned default colors")
        }
    }
}

#Preview {
    ZStack {
        Color("BackgroundPopup")
            .ignoresSafeArea()
        
        RoutineView(
            selectedDate: Date(),
            routines: .constant([
                Routine(name: "Morning", icon: "sunrise.fill", routineItems: [
                    RoutineItem(name: "Wake up", frequency: .everyDay),
                    RoutineItem(name: "Brush teeth", frequency: .everyDay),
                    RoutineItem(name: "Exercise", frequency: .everyTwoWeeks)
                ]),
                Routine(name: "Evening", icon: "moon.stars.fill", routineItems: [
                    RoutineItem(name: "Read", frequency: .everyDay),
                    RoutineItem(name: "Meditate", frequency: .everyWeek),
                    RoutineItem(name: "Sleep", frequency: .everyDay)
                ])
            ]),
            showRoutineDetail: .constant(false),
            selectedRoutineIndex: .constant(nil)
        )
    }
}
