//
//  RoutineView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct Routine: Identifiable, Codable {
    let id = UUID()
    var name: String
    var icon: String
    var items: [String]
    
    // Add missing properties for compatibility
    var iconName: String {
        return icon
    }
    var color: Color = .blue
    
    // Changed from Set<String> to [String: Set<String>] to track completion per date
    var completedItemsByDate: [String: Set<String>] = [:]
    
    // Updated frequency properties with custom frequency support
    var frequency: Frequency = .everyDay
    var customFrequencyConfig: CustomFrequencyConfig? = nil
    var endRepeatOption: EndRepeatOption = .never
    var endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    var startDate: Date = Date()
    
    // Custom initializer with custom frequency support
    init(name: String, icon: String, items: [String], color: Color = .blue, frequency: Frequency = .everyDay, customFrequencyConfig: CustomFrequencyConfig? = nil, endRepeatOption: EndRepeatOption = .never, endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(), startDate: Date = Date()) {
        self.name = name
        self.icon = icon
        self.items = items
        self.color = color
        self.frequency = frequency
        self.customFrequencyConfig = customFrequencyConfig
        self.endRepeatOption = endRepeatOption
        self.endRepeatDate = endRepeatDate
        self.startDate = startDate
    }
    
    // Custom Codable implementation
    enum CodingKeys: String, CodingKey {
        case id, name, icon, items, completedItemsByDate, frequency, customFrequencyConfig, endRepeatOption, endRepeatDate, startDate, colorData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        items = try container.decode([String].self, forKey: .items)
        completedItemsByDate = try container.decode([String: Set<String>].self, forKey: .completedItemsByDate)
        frequency = try container.decodeIfPresent(Frequency.self, forKey: .frequency) ?? .everyDay
        customFrequencyConfig = try container.decodeIfPresent(CustomFrequencyConfig.self, forKey: .customFrequencyConfig)
        endRepeatOption = try container.decodeIfPresent(EndRepeatOption.self, forKey: .endRepeatOption) ?? .never
        endRepeatDate = try container.decodeIfPresent(Date.self, forKey: .endRepeatDate) ?? Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        
        // Handle color - default to blue if not available
        color = .blue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(items, forKey: .items)
        try container.encode(completedItemsByDate, forKey: .completedItemsByDate)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(customFrequencyConfig, forKey: .customFrequencyConfig)
        try container.encode(endRepeatOption, forKey: .endRepeatOption)
        try container.encode(endRepeatDate, forKey: .endRepeatDate)
        try container.encode(startDate, forKey: .startDate)
    }
    
    // Helper method to get date key
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // Get completed items for a specific date
    func completedItems(for date: Date) -> Set<String> {
        let key = dateKey(for: date)
        return completedItemsByDate[key] ?? []
    }
    
    // Calculate progress for a specific date
    func progress(for date: Date) -> Double {
        guard !items.isEmpty else { return 0 }
        let completed = completedItems(for: date)
        return Double(completed.count) / Double(items.count)
    }
    
    // Toggle item completion for a specific date
    mutating func toggleItem(_ item: String, for date: Date) {
        let key = dateKey(for: date)
        var completedForDate = completedItemsByDate[key] ?? []
        
        if completedForDate.contains(item) {
            completedForDate.remove(item)
        } else {
            completedForDate.insert(item)
        }
        
        completedItemsByDate[key] = completedForDate
    }
    
    // Check if item is completed for a specific date
    func isItemCompleted(_ item: String, for date: Date) -> Bool {
        let completed = completedItems(for: date)
        return completed.contains(item)
    }
    
    // Updated shouldAppear method to use custom frequency config
    func shouldAppear(on date: Date) -> Bool {
        // Check if the routine should trigger based on frequency from start date (including custom config)
        let shouldTrigger = frequency.shouldTrigger(on: date, from: startDate, customConfig: customFrequencyConfig)
        
        // If it shouldn't trigger based on frequency, don't show
        if !shouldTrigger {
            return false
        }
        
        // Check end repeat conditions
        if endRepeatOption == .onDate {
            return date <= endRepeatDate
        }
        
        // If endRepeatOption is .never, show indefinitely (as long as frequency matches)
        return true
    }
}

// MARK: - Supporting structs for compatibility
struct RoutineItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var isCompleted: Bool = false
    
    init(name: String, isCompleted: Bool = false) {
        self.name = name
        self.isCompleted = isCompleted
    }
}

// MARK: - Create Routine View (Simplified)

struct CreateRoutineView: View {
    @Binding var routines: [Routine]
    @Environment(\.dismiss) private var dismiss
    
    @State private var routineName = ""
    @State private var selectedIcon = "sunrise"
    @State private var selectedColor = "Color1"
    @State private var routineItems: [String] = [""]
    @State private var frequency: Frequency = .everyDay
    @State private var endRepeatOption: EndRepeatOption = .never
    @State private var endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var startDate: Date = Date()
    @State private var showingIconPicker = false
    @State private var showingCustomFrequencyPicker = false
    @State private var customFrequencyConfig = CustomFrequencyConfig()
    
    private let availableColors: [String] = [
        "Color1", "Color2", "Color3", "Color4", "Color5"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").opacity(0.2)
                    .ignoresSafeArea()
                
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
                        }
                        
                        // Color Picker - Updated to HStack
                        HStack {
                            Text("Choose Color")
                                .font(.headline)
                            
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
                    
                    Section(header: Text("Schedule")) {
                        HStack {
                            Text("Start Date")
                            Spacer()
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                        
                        // Updated Repeat Section with Custom Frequency Support
                        HStack {
                            Text("Repeat")
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
                    
                    Section(header: Text("Routine Items")) {
                        ForEach(routineItems.indices, id: \.self) { index in
                            HStack {
                                TextField("Item \(index + 1)", text: $routineItems[index])
                                
                                if routineItems.count > 1 {
                                    Button(action: {
                                        routineItems.remove(at: index)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .onDelete(perform: deleteChecklistItems)
                        
                        Button(action: {
                            routineItems.append("")
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
            .navigationTitle("New Routine")
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
            }
            .sheet(isPresented: $showingCustomFrequencyPicker) {
                CustomFrequencyPickerView(
                    customConfig: $customFrequencyConfig,
                    endRepeatOption: $endRepeatOption,
                    endRepeatDate: $endRepeatDate
                )
            }
        }
        .onChange(of: frequency) { _, newFrequency in
            if newFrequency == .never {
                endRepeatOption = .never
            }
            
            // Show custom frequency picker when custom is selected
            if newFrequency == .custom {
                showingCustomFrequencyPicker = true
            }
        }
    }
    
    private func deleteChecklistItems(offsets: IndexSet) {
        routineItems.remove(atOffsets: offsets)
    }
    
    private func saveRoutine() {
        let trimmedName = routineName.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredItems = routineItems.compactMap { item in
            let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        
        guard !trimmedName.isEmpty, !filteredItems.isEmpty else { return }
        
        let newRoutine = Routine(
            name: trimmedName,
            icon: selectedIcon,
            items: filteredItems,
            color: Color(selectedColor),
            frequency: frequency,
            customFrequencyConfig: frequency == .custom ? customFrequencyConfig : nil,
            endRepeatOption: endRepeatOption,
            endRepeatDate: endRepeatDate,
            startDate: startDate
        )
        
        routines.append(newRoutine)
        dismiss()
    }
}

// MARK: - Main Routine View
struct RoutineView: View {
    var selectedDate: Date
    @Binding var routines: [Routine]
    @Binding var showRoutineDetail: Bool
    @Binding var selectedRoutineIndex: Int?
    @State private var showCreateRoutine = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    // Computed binding for sheet presentation
    private var showSheet: Binding<Bool> {
        Binding(
            get: { selectedRoutineIndex != nil },
            set: { isPresented in
                if !isPresented {
                    selectedRoutineIndex = nil
                    showRoutineDetail = false
                }
            }
        )
    }
    
    // Filter routines that should appear on the selected date
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
                    ForEach(visibleRoutines, id: \.routine.id) { routineData in
                        Button(action: {
                            selectedRoutineIndex = routineData.index
                            showRoutineDetail = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("Background").opacity(0.75))
                                    .frame(width: 164, height: 100)
                                VStack {
                                    HStack(alignment: .bottom) {
                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(routineData.routine.name)
                                                .font(.system(size: 18, weight: .medium, design: .default))
                                                .foregroundColor(.primary)
                                               
                                            Text("Routine")
                                                .font(.system(size: 10, weight: .regular, design: .default))
                                                .kerning(1)
                                                .textCase(.uppercase)
                                                .foregroundColor(.primary.opacity(0.75))
                                             
                                        }
                                        Spacer()
                                        
                                        Image(systemName: routineData.routine.icon)
                                            .frame(width: 36, height: 36)
                                            .font(.largeTitle)
                                            .foregroundColor(Color(UIColor.lightGray).opacity(0.25))
                                
                                    }
                                    .padding(.horizontal, 8)
                                    
                                    // Updated to use progress for specific date
                                    ProgressView(value: routineData.routine.progress(for: selectedDate), total: 1.0)
                                        .progressViewStyle(LinearProgressViewStyle(tint: Color("Color1")))
                                        .scaleEffect(y: 1.5) // Makes the progress bar taller
                                        .padding(.top, 8)
                                        .animation(.easeInOut(duration: 0.3), value: routineData.routine.progress(for: selectedDate))
                                }
                                .frame(width: 136)
                            }
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding()
        .sheet(isPresented: showSheet) {
            if let index = selectedRoutineIndex {
                RoutineDetailBottomSheetView(
                    routine: $routines[index],
                    selectedDate: selectedDate
                )
                .presentationDetents([.fraction(0.85), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
            }
        }
        .sheet(isPresented: $showCreateRoutine) {
            CreateRoutineView(routines: $routines)
        }
        .onAppear {
            updateDefaultRoutinesStartDate()
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
}

// MARK: - Bottom Sheet View for Routine Details
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 16) {
                    Image(systemName: workingRoutine.icon)
                        .font(.system(size: 48))
                        .foregroundColor(.primary)
                    
                    Text(workingRoutine.name + " Routine")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ProgressView(value: workingRoutine.progress(for: selectedDate), total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("Color1")))
                        .scaleEffect(y: 1.5)
                        .frame(maxWidth: 200)
                        .animation(.easeInOut(duration: 0.3), value: workingRoutine.progress(for: selectedDate))
                }
                .padding(.top, 24)
                .padding(.bottom, 32)

                // Routine Items List
                if !workingRoutine.items.isEmpty {
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            VStack(spacing: 0) {
                                ForEach(workingRoutine.items.indices, id: \.self) { index in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            workingRoutine.toggleItem(workingRoutine.items[index], for: selectedDate)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: workingRoutine.isItemCompleted(workingRoutine.items[index], for: selectedDate) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(workingRoutine.isItemCompleted(workingRoutine.items[index], for: selectedDate) ? .primary : .gray)
                                                .animation(.easeInOut(duration: 0.3), value: workingRoutine.isItemCompleted(workingRoutine.items[index], for: selectedDate))
                                            
                                            Text(workingRoutine.items[index])
                                                .strikethrough(workingRoutine.isItemCompleted(workingRoutine.items[index], for: selectedDate))
                                                .foregroundColor(workingRoutine.isItemCompleted(workingRoutine.items[index], for: selectedDate) ? .secondary : .primary)
                                                .animation(.easeInOut(duration: 0.3), value: workingRoutine.isItemCompleted(workingRoutine.items[index], for: selectedDate))
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if index < workingRoutine.items.count - 1 {
                                        Divider()
                                            .padding(.leading, 16)
                                    }
                                }
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                    }
                }
                
                Spacer()
                
                // Done Button
                Button("Done") {
                    routine = workingRoutine
                    dismiss()
                }
                .font(.headline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color("Color1").opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        RoutineView(
            selectedDate: Date(),
            routines: .constant([
                Routine(name: "Morning", icon: "sunrise.fill", items: ["Wake up", "Brush teeth", "Exercise"]),
                Routine(name: "Evening", icon: "moon.stars.fill", items: ["Read", "Meditate", "Sleep"])
            ]),
            showRoutineDetail: .constant(false),
            selectedRoutineIndex: .constant(nil)
        )
    }
}
