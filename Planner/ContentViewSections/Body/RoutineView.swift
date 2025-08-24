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
        NavigationView {
            ZStack {
                Color("BackgroundPopup")
                    .edgesIgnoringSafeArea(.all)
                Form {
                    Section(header: Text("Routine Details")) {
                        HStack {
                            Button(action: {
                                showingIconPicker = true
                            }) {
                                Image(systemName: selectedIcon)
                                    .foregroundColor(Color(selectedColor))
                                    .frame(width: 30)
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
                    if isEditing {
                        Section(header: Text("Overall Routine Frequency")) {
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
                            Text("This controls when the entire routine appears in your daily view. Individual items can have their own frequencies.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Section(header: Text("Routine Items")) {
                        ForEach(routineItems) { item in
                            let index = routineItems.firstIndex(where: { $0.id == item.id }) ?? 0
                            HStack {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
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
                                Spacer()
                                if isEditing && item.frequency != .everyDay {
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
                                if !item.name.isEmpty || routineItems.count > 1 {
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
                            }
                            .padding(.vertical, 4)
                        }
                        .onMove(perform: moveItems)
                        Button(action: {
                            routineItems.append(RoutineItem(name: "", frequency: .everyDay))
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                Text("Add Item")
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit Routine" : "New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRoutine()
                    }
                    .disabled(routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
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
                if let editingIndex = editingItemIndex {
                    RoutineItemDetailView(
                        item: $routineItems[editingIndex],
                        onDelete: {
                            routineItems.remove(at: editingIndex)
                            showingItemDetailSheet = false
                            self.editingItemIndex = nil
                        }
                    )
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
        .onChange(of: frequency) { _, newFrequency in
            if newFrequency == .never {
                endRepeatOption = .never
            }
            if newFrequency == .custom {
                showingCustomFrequencyPicker = true
            }
        }
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
    init(item: Binding<RoutineItem>, onDelete: @escaping () -> Void) {
        self._item = item
        self.onDelete = onDelete
        if let existingConfig = item.wrappedValue.customFrequencyConfig {
            self._customFrequencyConfig = State(initialValue: existingConfig)
        } else {
            self._customFrequencyConfig = State(initialValue: CustomFrequencyConfig())
        }
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
                        ForEach(Frequency.allCases) { frequency in
                            Button(action: {
                                item.frequency = frequency
                                if frequency == .custom {
                                    showingCustomFrequencyPicker = true
                                }
                            }) {
                                HStack {
                                    if frequency == .custom && item.frequency == .custom {
                                        Text(customFrequencyConfig.displayDescription())
                                            .foregroundColor(.primary)
                                    } else {
                                        Text(frequency.displayName)
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    if item.frequency == frequency {
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
                        Text("This frequency will override the routine's overall frequency for this specific item.")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                            if item.frequency == .custom {
                                item.customFrequencyConfig = customFrequencyConfig
                            } else {
                                item.customFrequencyConfig = nil
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
                if newFrequency == .custom {
                    showingCustomFrequencyPicker = true
                }
            }
        }
    }
}

struct RoutineDetailBottomSheetView: View {
    @Binding var routine: Routine
    let selectedDate: Date
    let onEdit: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var originalRoutine: Routine
    @State private var workingRoutine: Routine
    init(routine: Binding<Routine>, selectedDate: Date, onEdit: @escaping () -> Void) {
        self._routine = routine
        self.selectedDate = selectedDate
        self.onEdit = onEdit
        self._originalRoutine = State(initialValue: routine.wrappedValue)
        self._workingRoutine = State(initialValue: routine.wrappedValue)
    }
    private var visibleItems: [RoutineItem] {
        return workingRoutine.visibleItems(for: selectedDate)
    }
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Image(systemName: workingRoutine.icon)
                        .font(.system(size: 48))
                        .foregroundColor(workingRoutine.color)
                    Text(workingRoutine.name + " Routine")
                        .font(.title2)
                        .fontWeight(.semibold)
                    ProgressView(value: workingRoutine.progress(for: selectedDate), total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: workingRoutine.color))
                        .scaleEffect(y: 1.5)
                        .frame(maxWidth: 200)
                        .animation(.easeInOut(duration: 0.3), value: workingRoutine.progress(for: selectedDate))
                    if visibleItems.count != workingRoutine.routineItems.count {
                        Text("\(visibleItems.count) of \(workingRoutine.routineItems.count) items today")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 32)
                if !visibleItems.isEmpty {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ForEach(visibleItems.indices, id: \.self) { index in
                                let item = visibleItems[index]
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        workingRoutine.toggleItem(item.name, for: selectedDate)
                                        routine = workingRoutine
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: workingRoutine.isItemCompleted(item.name, for: selectedDate) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(workingRoutine.isItemCompleted(item.name, for: selectedDate) ? .primary : .gray)
                                            .animation(.easeInOut(duration: 0.3), value: workingRoutine.isItemCompleted(item.name, for: selectedDate))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.name)
                                                .strikethrough(workingRoutine.isItemCompleted(item.name, for: selectedDate))
                                                .foregroundColor(workingRoutine.isItemCompleted(item.name, for: selectedDate) ? .secondary : .primary)
                                                .animation(.easeInOut(duration: 0.3), value: workingRoutine.isItemCompleted(item.name, for: selectedDate))
                                            if item.frequency != workingRoutine.frequency {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "repeat")
                                                        .font(.caption2)
                                                    if item.frequency == .custom {
                                                        Text(item.customFrequencyConfig?.displayDescription() ?? "Custom")
                                                            .font(.caption2)
                                                    } else {
                                                        Text(item.frequency.displayName)
                                                            .font(.caption2)
                                                    }
                                                }
                                                .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                if index < visibleItems.count - 1 {
                                    Divider()
                                        .padding(.leading, 16)
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
                Button("Done") {
                    dismiss()
                }
                .font(.headline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(workingRoutine.color.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        routine = originalRoutine
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        routine = workingRoutine
                        onEdit()
                    }
                    .foregroundColor(.primary)
                }
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
            .padding(.bottom, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (spacing: 16) {
                    ForEach(visibleRoutines.indices, id: \.self) { idx in
                        let routineData = visibleRoutines[idx]
                        Button(action: {
                            selectedRoutineIndex = nil
                            showRoutineDetail = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                selectedRoutineIndex = routineData.index
                                showRoutineDetail = true
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemBackground))
                                    .frame(width: 176, height: 100)
                                VStack {
                                    HStack(alignment: .bottom) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(routineData.routine.name)
                                                .font(.headline)
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
                        .padding(.leading, idx == 0 ? 16 : 0)
                        .padding(.trailing, idx == visibleRoutines.count - 1 ? 16 : 0)
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: Binding(
            get: { selectedRoutineIndex != nil && editingRoutine == nil },
            set: { isPresented in
                if !isPresented {
                    selectedRoutineIndex = nil
                    showRoutineDetail = false
                }
            }
        )) {
            if let index = selectedRoutineIndex, index < routines.count {
                RoutineDetailBottomSheetView(
                    routine: $routines[index],
                    selectedDate: selectedDate,
                    onEdit: {
                        editingRoutineIndex = index
                        editingRoutine = routines[index]
                        selectedRoutineIndex = nil
                        showRoutineDetail = false
                    }
                )
                .presentationDetents([.fraction(0.85), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
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
