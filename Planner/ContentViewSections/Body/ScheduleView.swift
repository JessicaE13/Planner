//
//  ScheduleView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI
import MapKit

// MARK: - Sheet Content Enum
enum SheetContent: Identifiable {
    case detail(ScheduleItem)
    case edit(ScheduleItem)
    case create // Added case for creating new items
    
    var id: String {
        switch self {
        case .detail(let item): return "detail-\(item.id)"
        case .edit(let item): return "edit-\(item.id)"
        case .create: return "create-new"
        }
    }
}

// MARK: - Schedule View

struct ScheduleView: View {
    var selectedDate: Date
    @StateObject private var dataManager = ScheduleDataManager.shared
    @State private var sheetContent: SheetContent? = nil
    
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
                
                Button(action: {
                    sheetContent = .create
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 16)
            
            VStack(spacing: 12) {
                // Display all schedule items for the selected date, sorted by start time
                ForEach(getScheduleItemsForDate(selectedDate).sorted { $0.startTime < $1.startTime }, id: \.id) { item in
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(item.color))
                                .frame(width: 50, height: 75)
                            Image(systemName: item.icon)
                                .foregroundColor(.white)
                        }
                        
                        Text(formatTime(item.startTime))
                            .font(.body)
                            .foregroundColor(Color.gray)
                        Text(item.title)
                            .font(.body)
                        if item.frequency != .never {
                            Image(systemName: "repeat")
                                .foregroundColor(Color.gray.opacity(0.6))
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        sheetContent = .detail(item)
                    }
                }
                
                // If no items exist, still show the default items for demo purposes
                if getScheduleItemsForDate(selectedDate).isEmpty {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color("Color1"))
                                .frame(width: 50, height: 75)
                            Image(systemName: getScheduleIcon(for: selectedDate))
                        }
                        
                        let scheduleItem = dataManager.getOrCreateItem(
                            uniqueKey: "daily-routine",
                            title: getScheduleTitle(for: selectedDate),
                            time: getScheduleTimeAsDate(for: selectedDate),
                            icon: getScheduleIcon(for: selectedDate),
                            color: "Color1",
                            frequency: .everyDay,
                            startTime: getScheduleStartTime(for: selectedDate)
                        )
                        
                        Text(formatTime(scheduleItem.startTime))
                            .font(.body)
                            .foregroundColor(Color.gray)
                        Text(scheduleItem.title)
                            .font(.body)
                        if scheduleItem.frequency != .never {
                            Image(systemName: "repeat")
                                .foregroundColor(Color.gray.opacity(0.6))
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let item = dataManager.getOrCreateItem(
                            uniqueKey: "daily-routine",
                            title: getScheduleTitle(for: selectedDate),
                            time: getScheduleTimeAsDate(for: selectedDate),
                            icon: getScheduleIcon(for: selectedDate),
                            color: "Color1",
                            frequency: .everyDay,
                            startTime: getScheduleStartTime(for: selectedDate)
                        )
                        sheetContent = .detail(item)
                    }
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color("Color2"))
                                .frame(width: 50, height: 75)
                            Image(systemName: "figure.walk")
                        }
                        
                        let morningWalkItem = dataManager.getOrCreateItem(
                            uniqueKey: "morning-walk",
                            title: "Morning Walk",
                            time: getFixedTime(hour: 12, minute: 0),
                            icon: "figure.walk",
                            color: "Color2",
                            frequency: .never,
                            startTime: getFixedTime(hour: 12, minute: 0)
                        )
                        
                        Text(formatTime(morningWalkItem.startTime))
                            .font(.body)
                            .foregroundColor(Color.gray)
                        Text(morningWalkItem.title)
                            .font(.body)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let item = dataManager.getOrCreateItem(
                            uniqueKey: "morning-walk",
                            title: "Morning Walk",
                            time: getFixedTime(hour: 12, minute: 0),
                            icon: "figure.walk",
                            color: "Color2",
                            frequency: .never,
                            startTime: getFixedTime(hour: 12, minute: 0)
                        )
                        sheetContent = .detail(item)
                    }
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color("Color3"))
                                .frame(width: 50, height: 75)
                            Image(systemName: "person.3.fill")
                        }
                        
                        let teamMeetingItem = dataManager.getOrCreateItem(
                            uniqueKey: "team-meeting",
                            title: "Team Meeting",
                            time: getFixedTime(hour: 12, minute: 0),
                            icon: "person.3.fill",
                            color: "Color3",
                            frequency: .everyWeek,
                            startTime: getFixedTime(hour: 12, minute: 0)
                        )
                        
                        Text(formatTime(teamMeetingItem.startTime))
                            .font(.body)
                            .foregroundColor(Color.gray)
                        Text(teamMeetingItem.title)
                            .font(.body)
                        if teamMeetingItem.frequency != .never {
                            Image(systemName: "repeat")
                                .foregroundColor(Color.gray.opacity(0.6))
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let item = dataManager.getOrCreateItem(
                            uniqueKey: "team-meeting",
                            title: "Team Meeting",
                            time: getFixedTime(hour: 12, minute: 0),
                            icon: "person.3.fill",
                            color: "Color3",
                            frequency: .everyWeek,
                            startTime: getFixedTime(hour: 12, minute: 0)
                        )
                        sheetContent = .detail(item)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .sheet(item: $sheetContent) { content in
            switch content {
            case .detail(let item):
                ScheduleDetailView(
                    item: item,
                    onEdit: { editItem in
                        sheetContent = .edit(editItem)
                    },
                    onSave: { updatedItem in
                        dataManager.addOrUpdateItem(updatedItem)
                    }
                )
            case .edit(let item):
                ScheduleEditView(item: item) { updatedItem in
                    dataManager.addOrUpdateItem(updatedItem)
                    sheetContent = nil
                }
            case .create:
                ScheduleEditView(item: createNewScheduleItem()) { newItem in
                    dataManager.addOrUpdateItem(newItem)
                    sheetContent = nil
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getScheduleItemsForDate(_ date: Date) -> [ScheduleItem] {
        let calendar = Calendar.current
        return dataManager.scheduleItems.filter { item in
            // Show items that are scheduled for this specific date
            if calendar.isDate(item.startTime, inSameDayAs: date) {
                return true
            }
            
            // Show recurring items that should appear on this date
            if item.frequency != .never {
                return item.frequency.shouldTrigger(on: date, from: item.startTime)
            }
            
            return false
        }
    }
    
    private func createNewScheduleItem() -> ScheduleItem {
        let calendar = Calendar.current
        let defaultStartTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: selectedDate) ?? selectedDate
        let defaultEndTime = calendar.date(byAdding: .hour, value: 1, to: defaultStartTime) ?? defaultStartTime
        
        return ScheduleItem(
            title: "",
            time: defaultStartTime,
            icon: "calendar",
            color: "Color1",
            frequency: .never,
            startTime: defaultStartTime,
            endTime: defaultEndTime,
            checklist: [],
            uniqueKey: UUID().uuidString // Generate unique key for new items
        )
    }
    
    private func getScheduleIcon(for date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1, 7: return "figure.yoga"
        case 2, 4, 6: return "figure.run"
        default: return "figure.walk"
        }
    }
    
    private func getScheduleTime(for date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1, 7: return "10:00 AM"
        case 2, 4, 6: return "6:00 AM"
        default: return "12:00 PM"
        }
    }
    
    private func getScheduleTitle(for date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1, 7: return "Yoga Class"
        case 2, 4, 6: return "Morning Run"
        default: return "Lunch Walk"
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
    
    private func getScheduleStartTime(for date: Date) -> Date {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        switch dayOfWeek {
        case 1, 7: return getFixedTime(hour: 10, minute: 0)
        case 2, 4, 6: return getFixedTime(hour: 6, minute: 0)
        default: return getFixedTime(hour: 12, minute: 0)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Enhanced Schedule Detail View with Full Row Tap

struct ScheduleDetailView: View {
    @State private var item: ScheduleItem
    let onEdit: (ScheduleItem) -> Void
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(item: ScheduleItem, onEdit: @escaping (ScheduleItem) -> Void, onSave: @escaping (ScheduleItem) -> Void) {
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
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
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
                        if !item.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "text.alignleft")
                                        .foregroundColor(.purple)
                                        .frame(width: 20)
                                    Text("Description")
                                        .font(.headline)
                                    Spacer()
                                }
                                
                                Text(item.descriptionText)
                                    .font(.body)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Checklist - MODIFIED for full row tap
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
                                        // MODIFIED: Wrap entire row in button instead of just the circle
                                        Button(action: {
                                            item.checklist[index].isCompleted.toggle()
                                            onSave(item)
                                        }) {
                                            HStack {
                                                Image(systemName: checklistItem.isCompleted ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(checklistItem.isCompleted ? .green : .gray)
                                                    .font(.title3)
                                                
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
                                            .contentShape(Rectangle()) // Ensures entire area is tappable
                                        }
                                        .buttonStyle(PlainButtonStyle()) // Removes default button styling
                                        .animation(.easeInOut(duration: 0.2), value: checklistItem.isCompleted)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 20)
                        
                        // Edit Button
                        Button(action: {
                            onEdit(item)
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
}

// MARK: - Schedule Edit View

struct ScheduleEditView: View {
    @State private var item: ScheduleItem
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var locationSearchResults: [IdentifiableMapItem] = []
    @State private var isSearchingLocation = false
    @State private var locationSearchTask: Task<Void, Never>? = nil
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
        self._descriptionText = State(initialValue: item.descriptionText)
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
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        HStack {
                            Image(systemName: item.icon)
                                .foregroundColor(.blue)
                                .padding(.trailing, 8)
                            TextField("Title", text: $item.title)
                                .multilineTextAlignment(.leading)
                        }
                        
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
                    
                    Section(header: Text("Description")) {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $descriptionText)
                                .frame(minHeight: 100)
                                .focused($descriptionIsFocused)
                                .onTapGesture {
                                    descriptionIsFocused = true
                                }
                                .onChange(of: descriptionText) { _, newValue in
                                    item.descriptionText = newValue
                                }
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)

                            if descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Add description...")
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 6)
                                    .allowsHitTesting(false)
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.2), value: descriptionText)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Section(header: Text("Checklist")) {
                       
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
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(item.title.isEmpty ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        item.descriptionText = descriptionText
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
        }
        .onAppear {
            performLocationSearch()
            descriptionText = item.descriptionText
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
