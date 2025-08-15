//
//  ScheduleView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI
import MapKit

// MARK: - Models

struct ChecklistItem: Identifiable, Hashable, Codable {
    let id = UUID()
    var text: String
    var isCompleted: Bool = false
}

struct ScheduleItem: Identifiable {
    let id = UUID()
    var title: String
    var time: Date
    var icon: String
    var color: String
    var isRepeating: Bool
    var frequency: Frequency = .never
    var description: AttributedString = ""
    var location: String = ""
    var allDay: Bool = false
    var category: String = ""
    var type: String = "Schedule"
    var isCompleted: Bool = false
    var startTime: Date = Date()
    var endTime: Date = Date()
    var checklist: [ChecklistItem] = []
}

// MARK: - Schedule View

struct ScheduleView: View {
    var selectedDate: Date
    @State private var selectedItem: ScheduleItem?
    @State private var showEdit: Bool = false
    @State private var itemToEdit: ScheduleItem? // Separate state for editing
    @State private var scheduleItems: [ScheduleItem] = [] // Store schedule items with their state
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Text("Schedule")
                    .sectionHeaderStyle()
                
                Spacer()
                
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .contentShape(Rectangle())
            }
            .padding(.bottom, 16)
            
            VStack {
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color("Color1"))
                            .frame(width: 50, height: 75)
                        Image(systemName: getScheduleIcon(for: selectedDate))
                    }
                    Text(formatTime(getScheduleStartTime(for: selectedDate)))
                        .font(.body)
                        .foregroundColor(Color.gray)
                    Text(getScheduleTitle(for: selectedDate))
                        .font(.body)
                    Image(systemName: "repeat")
                        .foregroundColor(Color.gray.opacity(0.6))
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    let item = getOrCreateScheduleItem(
                        id: "daily-routine",
                        title: getScheduleTitle(for: selectedDate),
                        time: getScheduleTimeAsDate(for: selectedDate),
                        icon: getScheduleIcon(for: selectedDate),
                        color: "Color1",
                        isRepeating: true,
                        startTime: getScheduleStartTime(for: selectedDate)
                    )
                    selectedItem = item
                }
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color("Color2"))
                            .frame(width: 50, height: 75)
                        Image(systemName: "figure.walk")
                    }
                    Text(formatTime(getFixedTime(hour: 12, minute: 0)))
                        .font(.body)
                        .foregroundColor(Color.gray)
                    Text("Morning Walk")
                        .font(.body)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    let item = getOrCreateScheduleItem(
                        id: "morning-walk",
                        title: "Morning Walk",
                        time: getFixedTime(hour: 12, minute: 0),
                        icon: "figure.walk",
                        color: "Color2",
                        isRepeating: false,
                        startTime: getFixedTime(hour: 12, minute: 0)
                    )
                    selectedItem = item
                }
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color("Color3"))
                            .frame(width: 50, height: 75)
                        Image(systemName: "person.3.fill")
                    }
                    Text(formatTime(getFixedTime(hour: 12, minute: 0)))
                        .font(.body)
                        .foregroundColor(Color.gray)
                    Text("Team Meeting")
                        .font(.body)
                    Image(systemName: "repeat")
                        .foregroundColor(Color.gray.opacity(0.6))
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    let item = getOrCreateScheduleItem(
                        id: "team-meeting",
                        title: "Team Meeting",
                        time: getFixedTime(hour: 12, minute: 0),
                        icon: "person.3.fill",
                        color: "Color3",
                        isRepeating: true,
                        startTime: getFixedTime(hour: 12, minute: 0)
                    )
                    selectedItem = item
                }
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .sheet(item: $selectedItem) { item in
            NavigationView {
                ScheduleDetailView(
                    item: item,
                    onEdit: {
                        // Store the item for editing and dismiss the detail view
                        itemToEdit = item
                        selectedItem = nil
                        showEdit = true
                    },
                    onSave: { updatedItem in
                        updateScheduleItem(updatedItem)
                    }
                )
            }
        }
        .sheet(isPresented: $showEdit) {
            if let item = itemToEdit {
                NavigationView {
                    ScheduleEditView(item: item) { updatedItem in
                        updateScheduleItem(updatedItem)
                        showEdit = false
                        itemToEdit = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getOrCreateScheduleItem(id: String, title: String, time: Date, icon: String, color: String, isRepeating: Bool, startTime: Date) -> ScheduleItem {
        // Check if we already have this item stored with checklist state
        if let existingItem = scheduleItems.first(where: { $0.id.uuidString == id }) {
            return existingItem
        }
        
        // Create new item with default checklist based on the type
        let defaultChecklist = getDefaultChecklist(for: title)
        let newItem = ScheduleItem(
            title: title,
            time: time,
            icon: icon,
            color: color,
            isRepeating: isRepeating,
            startTime: startTime,
            checklist: defaultChecklist
        )
        
        // Store it for future reference
        scheduleItems.append(newItem)
        return newItem
    }
    
    private func updateScheduleItem(_ updatedItem: ScheduleItem) {
        if let index = scheduleItems.firstIndex(where: { $0.id == updatedItem.id }) {
            scheduleItems[index] = updatedItem
        } else {
            scheduleItems.append(updatedItem)
        }
    }
    
    private func getDefaultChecklist(for title: String) -> [ChecklistItem] {
        switch title {
        case "Yoga Class", "Morning Run", "Lunch Walk":
            return [
                ChecklistItem(text: "Wear workout clothes", isCompleted: false),
                ChecklistItem(text: "Bring water bottle", isCompleted: false),
                ChecklistItem(text: "Warm up properly", isCompleted: false),
                ChecklistItem(text: "Cool down and stretch", isCompleted: false)
            ]
        case "Morning Walk":
            return [
                ChecklistItem(text: "Check weather", isCompleted: false),
                ChecklistItem(text: "Bring water", isCompleted: false),
                ChecklistItem(text: "Choose route", isCompleted: false)
            ]
        case "Team Meeting":
            return [
                ChecklistItem(text: "Review agenda", isCompleted: false),
                ChecklistItem(text: "Prepare updates", isCompleted: false),
                ChecklistItem(text: "Test video/audio", isCompleted: false),
                ChecklistItem(text: "Take notes", isCompleted: false)
            ]
        default:
            return []
        }
    }
    
    private func getScheduleIcon(for date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1, 7: return "figure.yoga" // Weekend - Yoga
        case 2, 4, 6: return "figure.run" // Mon, Wed, Fri - Running
        default: return "figure.walk" // Other days - Walking
        }
    }
    
    private func getScheduleTime(for date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1, 7: return "10:00 AM" // Weekend - Morning
        case 2, 4, 6: return "6:00 AM" // Mon, Wed, Fri - Early morning
        default: return "12:00 PM" // Other days - Noon
        }
    }
    
    private func getScheduleTitle(for date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1, 7: return "Yoga Class" // Weekend
        case 2, 4, 6: return "Morning Run" // Mon, Wed, Fri
        default: return "Lunch Walk" // Other days
        }
    }
    
    private func getScheduleTimeAsDate(for date: Date) -> Date {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeString = getScheduleTime(for: date)
        let components = timeString.split(separator: ":")
        let hourMinute = components[0].trimmingCharacters(in: .whitespaces)
        let ampm = timeString.suffix(2)
        var hour = Int(hourMinute) ?? 12
        let minute = Int(components[1].prefix(2))
        if ampm == "PM" && hour != 12 { hour += 12 }
        if ampm == "AM" && hour == 12 { hour = 0 }
        return calendar.date(bySettingHour: hour, minute: minute ?? 0, second: 0, of: date) ?? date
    }
    
    private func getFixedTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
    
    // Helper to get the correct startTime for the selected date
    private func getScheduleStartTime(for date: Date) -> Date {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        switch dayOfWeek {
        case 1, 7: return getFixedTime(hour: 10, minute: 0) // Weekend - 10:00 AM
        case 2, 4, 6: return getFixedTime(hour: 6, minute: 0) // Mon, Wed, Fri - 6:00 AM
        default: return getFixedTime(hour: 12, minute: 0) // Other days - 12:00 PM
        }
    }
    
    // Helper to format Date to time string
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Enhanced Schedule Detail View

struct ScheduleDetailView: View {
    @State private var item: ScheduleItem
    let onEdit: () -> Void
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    // Initialize with a copy of the item for potential modifications
    init(item: ScheduleItem, onEdit: @escaping () -> Void, onSave: @escaping (ScheduleItem) -> Void) {
        self._item = State(initialValue: item)
        self.onEdit = onEdit
        self.onSave = onSave
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Event Icon and Color
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(item.color))
                        .frame(width: 80, height: 120)
                    Image(systemName: item.icon)
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding(.top)
                
                // Event Title
                VStack(spacing: 8) {
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    if !item.category.isEmpty {
                        Text(item.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                // Time and Date Information
                VStack(spacing: 16) {
                    // All-day or time-specific
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        if item.allDay {
                            Text("All Day")
                                .font(.body)
                        } else {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(timeFormatter.string(from: item.startTime)) - \(timeFormatter.string(from: item.endTime))")
                                    .font(.body)
                                if !Calendar.current.isDate(item.startTime, inSameDayAs: item.endTime) {
                                    Text("\(dateFormatter.string(from: item.startTime)) - \(dateFormatter.string(from: item.endTime))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Frequency/Repeat Information
                    if item.frequency != .never {
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            Text(item.frequency.displayName)
                                .font(.body)
                            Spacer()
                        }
                    }
                    
                    // Location
                    if !item.location.isEmpty {
                        HStack(alignment: .top) {
                            Image(systemName: "location")
                                .foregroundColor(.red)
                                .frame(width: 20)
                            Text(item.location)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
                
                // Description
                if !String(item.description.characters).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(.purple)
                                .frame(width: 20)
                            Text("Description")
                                .font(.headline)
                            Spacer()
                        }
                        
                        Text(item.description)
                            .font(.body)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                // Checklist
                if !item.checklist.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checklist")
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            Text("Checklist")
                                .font(.headline)
                            Spacer()
                            Text("\(item.checklist.filter(\.isCompleted).count)/\(item.checklist.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(6)
                        }
                        
                        VStack(spacing: 8) {
                            ForEach(Array(item.checklist.enumerated()), id: \.element.id) { index, checklistItem in
                                HStack {
                                    Button(action: {
                                        // Toggle completion and save changes
                                        item.checklist[index].isCompleted.toggle()
                                        onSave(item)
                                    }) {
                                        Image(systemName: checklistItem.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(checklistItem.isCompleted ? .green : .gray)
                                            .font(.title3)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Text(checklistItem.text)
                                        .strikethrough(checklistItem.isCompleted)
                                        .foregroundColor(checklistItem.isCompleted ? .secondary : .primary)
                                        .font(.body)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                                .animation(.easeInOut(duration: 0.2), value: checklistItem.isCompleted)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Event Type and Completion Status
                HStack(spacing: 16) {
                    if !item.type.isEmpty && item.type != "Schedule" {
                        VStack {
                            Image(systemName: "tag")
                                .foregroundColor(.blue)
                            Text("Type")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(item.type)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    if item.isCompleted {
                        VStack {
                            Image(systemName: "checkmark.seal")
                                .foregroundColor(.green)
                            Text("Status")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Completed")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Spacer(minLength: 20)
                
                // Edit Button
                Button(action: {
                    onEdit()
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Event")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
}

// MARK: - Schedule Edit View

struct ScheduleEditView: View {
    @State private var item: ScheduleItem
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showMapPicker = false
    @State private var locationSearchResults: [IdentifiableMapItem] = []
    @State private var isSearchingLocation = false
    @State private var locationSearchTask: Task<Void, Never>? = nil
    @State private var isDescriptionFocused = false
    @FocusState private var descriptionIsFocused: Bool
    
    // String representation of the description for editing
    @State private var descriptionText: String = ""
    
    // Checklist management
    @State private var checklistItems: [ChecklistItem] = []
    @State private var newChecklistItem: String = ""
    @FocusState private var checklistInputFocused: Bool
    
    init(item: ScheduleItem, onSave: @escaping (ScheduleItem) -> Void) {
        self._item = State(initialValue: item)
        self.onSave = onSave
        // Convert AttributedString to String for editing
        self._descriptionText = State(initialValue: String(item.description.characters))
        // Initialize checklist items from the item
        self._checklistItems = State(initialValue: item.checklist)
    }
    
    private func performLocationSearch() {
        locationSearchTask?.cancel()
        guard !item.location.isEmpty else {
            locationSearchResults = []
            return
        }
        locationSearchTask = Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = item.location
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            if let items = response?.mapItems {
                let mapped = items.prefix(10).map { IdentifiableMapItem(mapItem: $0) }
                await MainActor.run {
                    locationSearchResults = mapped
                }
            } else {
                await MainActor.run {
                    locationSearchResults = []
                }
            }
        }
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(.blue)
                        .padding(.trailing, 8)
                    TextField("Title", text: $item.title)
                        .multilineTextAlignment(.leading)
                }
                
                // Inline Location Search as Form Rows
                TextField("Location", text: $item.location, onEditingChanged: { editing in
                    isSearchingLocation = editing
                    if editing { performLocationSearch() }
                })
                .multilineTextAlignment(.leading)
                .onChange(of: item.location) { _, _ in
                    performLocationSearch()
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                if isSearchingLocation && !locationSearchResults.isEmpty {
                    ForEach(Array(locationSearchResults.prefix(3).enumerated()), id: \.offset) { index, itemResult in
                        Button(action: {
                            let name = itemResult.mapItem.name ?? "Selected Location"
                            let address = itemResult.mapItem.placemark.title ?? ""
                            item.location = name + (address.isEmpty ? "" : "\n" + address)
                            isSearchingLocation = false
                            locationSearchResults = []
                        }) {
                            VStack(alignment: .leading) {
                                Text(itemResult.mapItem.name ?? "Unknown")
                                    .foregroundColor(.primary)
                                Text(itemResult.mapItem.placemark.title ?? "")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            
            Section {
                HStack {
                    Text("All-day")
                    Spacer()
                    Toggle("", isOn: $item.allDay)
                }
                
                HStack {
                    Text("Start")
                    Spacer()
                    DatePicker("", selection: $item.startTime, displayedComponents: .date)
                        .labelsHidden()
                    
                    if !item.allDay {
                        DatePicker("", selection: $item.startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                
                HStack {
                    Text("End")
                    Spacer()
                    DatePicker("", selection: $item.endTime, displayedComponents: .date)
                        .labelsHidden()
                    
                    // Only show time picker if not all-day
                    if !item.allDay {
                        DatePicker("", selection: $item.endTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                
                HStack {
                    Text("Repeat")
                    Spacer()
                    Picker("", selection: $item.frequency) {
                        ForEach(Frequency.allCases) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            Section {
                HStack {
                    Text("Icon")
                    Spacer()
                }
                
                HStack {
                    Text("Color")
                    Spacer()
                    Circle()
                        .fill(Color(item.color))
                        .frame(width: 20, height: 20)
                }
            }
            
            Section(header: Text("")) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $descriptionText)
                        .frame(minHeight: 100)
                        .focused($descriptionIsFocused)
                        .onTapGesture {
                            descriptionIsFocused = true
                        }
                        .onChange(of: descriptionText) { _, newValue in
                            item.description = AttributedString(newValue)
                        }
                        // Optional: match your design
                        .scrollContentBackground(.hidden)

                    // Placeholder
                    if descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Description")
                            .foregroundColor(.secondary.opacity(0.5))
                            .padding(.top, 8)
                            .padding(.leading, 6)
                            .allowsHitTesting(false) // do not block taps on the editor
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.2), value: descriptionText)
                    }
                }
                .padding(.vertical, 4)
            }

            Section(header: Text("")) {
               
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
                        
                        TextField("Item", text: Binding(
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
        .navigationTitle("Edit Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Ensure the description and checklist are updated before saving
                    item.description = AttributedString(descriptionText)
                    item.checklist = checklistItems
                    onSave(item)
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            performLocationSearch()
            // Initialize descriptionText from the item's description
            descriptionText = String(item.description.characters)
            // Initialize checklist items from the item
            checklistItems = item.checklist
        }
        .onDisappear {
            locationSearchTask?.cancel()
        }
    }
    
    // MARK: - Checklist Helper Methods
    
    private func addChecklistItem() {
        guard !newChecklistItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newItem = ChecklistItem(text: newChecklistItem.trimmingCharacters(in: .whitespacesAndNewlines))
        checklistItems.append(newItem)
        newChecklistItem = ""
        checklistInputFocused = false
    }
    
    private func removeChecklistItem(at index: Int) {
        checklistItems.remove(at: index)
    }
    
    private func deleteChecklistItems(offsets: IndexSet) {
        checklistItems.remove(atOffsets: offsets)
    }
}

// MARK: - Supporting Types for Map Picker

struct IdentifiableMapItem: Identifiable, Hashable {
    let id = UUID()
    let mapItem: MKMapItem
}

// MARK: - Previews

#Preview("Schedule View") {
    ZStack {
        BackgroundView()
        ScheduleView(selectedDate: Date())
    }
}

#Preview("Schedule Detail View") {
    NavigationView {
        ScheduleDetailView(
            item: ScheduleItem(
                title: "Sample Event",
                time: Date(),
                icon: "calendar",
                color: "blue",
                isRepeating: true,
                frequency: .everyWeek,
                description: "Sample description",
                location: "123 Main St, Anytown, USA",
                startTime: Date(),
                endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
                checklist: [
                    ChecklistItem(text: "Prepare presentation", isCompleted: true),
                    ChecklistItem(text: "Review agenda", isCompleted: false),
                    ChecklistItem(text: "Print handouts", isCompleted: false)
                ]
            ),
            onEdit: { },
            onSave: { _ in }
        )
    }
}

#Preview("Schedule Edit View") {
    NavigationView {
        ScheduleEditView(
            item: ScheduleItem(
                title: "Sample Event",
                time: Date(),
                icon: "calendar",
                color: "blue",
                isRepeating: true,
                frequency: .everyWeek,
                description: "",
                location: "",
                startTime: Date(),
                endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
                checklist: []
            ),
            onSave: { _ in }
        )
    }
}
