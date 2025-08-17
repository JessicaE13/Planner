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

// MARK: - Delete Confirmation Types
enum DeleteOption: String, CaseIterable {
    case thisEvent = "This Event Only"
    case allEvents = "All Events in Series"
    
    var title: String { self.rawValue }
}

// MARK: - Schedule View

struct ScheduleView: View {
    var selectedDate: Date
    @StateObject private var dataManager = ScheduleDataManager.shared
    @State private var sheetContent: SheetContent? = nil
    @State private var defaultItems: [ScheduleItem] = []
    
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
                let scheduleItems = getScheduleItemsForDate(selectedDate).sorted { $0.startTime < $1.startTime }
                
                ForEach(scheduleItems, id: \.id) { item in
                    ScheduleRowView(item: item) {
                        sheetContent = .detail(item)
                    }
                }
                
                // Show default items if no custom items exist
                if scheduleItems.isEmpty {
                    ForEach(defaultItems, id: \.id) { item in
                        ScheduleRowView(item: item) {
                            sheetContent = .detail(item)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .onAppear {
            initializeDefaultItems()
        }
        .onChange(of: selectedDate) { _, _ in
            initializeDefaultItems()
        }
        .sheet(item: $sheetContent) { content in
            switch content {
            case .detail(let item):
                ScheduleDetailView(
                    item: item,
                    selectedDate: selectedDate,
                    onEdit: { editItem in
                        sheetContent = .edit(editItem)
                    },
                    onSave: { updatedItem in
                        Task {
                            await MainActor.run {
                                dataManager.addOrUpdateItem(updatedItem)
                            }
                        }
                    }
                )
            case .edit(let item):
                ScheduleEditView(
                    item: item,
                    selectedDate: selectedDate,
                    onSave: { updatedItem in
                        Task {
                            await MainActor.run {
                                dataManager.addOrUpdateItem(updatedItem)
                                sheetContent = nil
                            }
                        }
                    },
                    onDelete: { deleteOption in
                        Task {
                            await MainActor.run {
                                handleDelete(item: item, option: deleteOption)
                                sheetContent = nil
                            }
                        }
                    }
                )
            case .create:
                ScheduleEditView(
                    item: createNewScheduleItem(),
                    selectedDate: selectedDate,
                    onSave: { newItem in
                        Task {
                            await MainActor.run {
                                dataManager.addOrUpdateItem(newItem)
                                sheetContent = nil
                            }
                        }
                    },
                    onDelete: nil
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleDelete(item: ScheduleItem, option: DeleteOption) {
        switch option {
        case .thisEvent:
            // For single event deletion from a recurring series, we add this date to excluded dates
            dataManager.excludeDateFromRecurring(item: item, excludeDate: selectedDate)
        case .allEvents:
            // Delete the entire series
            dataManager.deleteItem(item)
        }
    }
    
    private func getScheduleItemsForDate(_ date: Date) -> [ScheduleItem] {
        return dataManager.scheduleItems.filter { item in
            item.shouldAppear(on: date)
        }
    }
    
    private func initializeDefaultItems() {
        // Create default items without immediately saving them to the data manager
        let calendar = Calendar.current
        
        let dailyRoutineItem = ScheduleItem(
            title: getScheduleTitle(for: selectedDate),
            time: getScheduleTimeAsDate(for: selectedDate),
            icon: getScheduleIcon(for: selectedDate),
            color: "Color1",
            frequency: .everyDay,
            startTime: getScheduleStartTime(for: selectedDate),
            endTime: calendar.date(byAdding: .hour, value: 1, to: getScheduleStartTime(for: selectedDate)) ?? getScheduleStartTime(for: selectedDate),
            uniqueKey: "daily-routine"
        )
        
        let morningWalkItem = ScheduleItem(
            title: "Morning Walk",
            time: getFixedTime(hour: 12, minute: 0),
            icon: "figure.walk",
            color: "Color2",
            frequency: .never,
            startTime: getFixedTime(hour: 12, minute: 0),
            endTime: calendar.date(byAdding: .hour, value: 1, to: getFixedTime(hour: 12, minute: 0)) ?? getFixedTime(hour: 12, minute: 0),
            uniqueKey: "morning-walk"
        )
        
        let teamMeetingItem = ScheduleItem(
            title: "Team Meeting",
            time: getFixedTime(hour: 12, minute: 0),
            icon: "person.3.fill",
            color: "Color3",
            frequency: .everyWeek,
            startTime: getFixedTime(hour: 12, minute: 0),
            endTime: calendar.date(byAdding: .hour, value: 1, to: getFixedTime(hour: 12, minute: 0)) ?? getFixedTime(hour: 12, minute: 0),
            uniqueKey: "team-meeting"
        )
        
        defaultItems = [dailyRoutineItem, morningWalkItem, teamMeetingItem]
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
            uniqueKey: UUID().uuidString,
            endRepeatOption: .never,
            endRepeatDate: Calendar.current.date(byAdding: .month, value: 1, to: defaultStartTime) ?? defaultStartTime
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

// MARK: - Schedule Row View Component
struct ScheduleRowView: View {
    let item: ScheduleItem
    let onTap: () -> Void
    
    var body: some View {
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
            onTap()
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Enhanced Schedule Detail View with Repeat Icon
// Updated ScheduleDetailView with Category Display
// This replaces the existing ScheduleDetailView in ScheduleView.swift

struct ScheduleDetailView: View {
    @State private var item: ScheduleItem
    let selectedDate: Date
    let onEdit: (ScheduleItem) -> Void
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingMapOptions = false
    
    init(item: ScheduleItem, selectedDate: Date, onEdit: @escaping (ScheduleItem) -> Void, onSave: @escaping (ScheduleItem) -> Void) {
        self._item = State(initialValue: item)
        self.selectedDate = selectedDate
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
               
                ScrollView {
                    VStack(spacing: 24) {
                        // Event Icon and Header Section
                        HStack(alignment: .center, spacing: 16) {
                            // Icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(item.color))
                                    .frame(width: 56, height: 80)
                                Image(systemName: item.icon)
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .padding(.leading)
                            
                            // Title and Details Section
                            VStack(alignment: .leading, spacing: 8) {
                                
                                // Event Title - Left Aligned
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(item.title)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    // Category display
                                    if let category = item.category {
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(Color(category.color))
                                                .frame(width: 12, height: 12)
                                            Text(category.name)
                                                .font(.caption)
                                                .foregroundColor(Color(category.color))
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(category.color).opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                                
                                // Updated time information with repeat icon
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                    
                                    // Create the time string with repeat icon using HStack
                                    createTimeView()
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Location - Clickable and Left Aligned
                                if !item.location.isEmpty {
                                    Button(action: {
                                        showingMapOptions = true
                                    }) {
                                        HStack(alignment: .top) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.location)
                                                    .font(.caption)
                                                    .multilineTextAlignment(.leading)
                                                    .foregroundColor(.blue)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            Spacer()
                                   
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.top)
                        
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
                        
                        // Checklist - Full row tap functionality
                        if !item.checklist.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                
                                VStack(spacing: 8) {
                                    ForEach(Array(item.checklist.enumerated()), id: \.element.id) { index, checklistItem in
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
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(PlainButtonStyle())
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
        .actionSheet(isPresented: $showingMapOptions) {
            ActionSheet(
                title: Text("Navigate to Location"),
                message: Text(item.location),
                buttons: [
                    .default(Text("Open in Apple Maps")) {
                        openInAppleMaps()
                    },
                    .default(Text("Open in Google Maps")) {
                        openInGoogleMaps()
                    },
                    .cancel()
                ]
            )
        }
    }
    
    // MARK: - Updated Time View Creation Helper with Repeat Icon
    private func createTimeView() -> some View {
        HStack(spacing: 4) {
            // Time part
            if item.allDay {
                Text("All Day")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text("\(timeFormatter.string(from: item.startTime)) - \(timeFormatter.string(from: item.endTime))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Add repeat icon and frequency if not "never"
            if item.frequency != .never {
                Image(systemName: "repeat")
                    .foregroundColor(.gray.opacity(0.6))
                    .font(.caption)
                    .padding(.leading, 2)
            }
        }
    }
    
    // MARK: - Navigation Helper Methods
    
    private func openInAppleMaps() {
        let encodedLocation = item.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "http://maps.apple.com/?q=\(encodedLocation)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openInGoogleMaps() {
        let encodedLocation = item.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        

        if let googleMapsURL = URL(string: "comgooglemaps://?q=\(encodedLocation)"),
           UIApplication.shared.canOpenURL(googleMapsURL) {
            UIApplication.shared.open(googleMapsURL)
        } else {
      
            if let webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encodedLocation)") {
                UIApplication.shared.open(webURL)
            }
        }
    }
}

// MARK: - Schedule Edit View with Delete Functionality

// Updated ScheduleEditView with Category Support
// This replaces the existing ScheduleEditView in ScheduleView.swift

struct ScheduleEditView: View {
    @State private var item: ScheduleItem
    let selectedDate: Date
    let onSave: (ScheduleItem) -> Void
    let onDelete: ((DeleteOption) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var locationSearchResults: [IdentifiableMapItem] = []
    @State private var isSearchingLocation = false
    @State private var locationSearchTask: Task<Void, Never>? = nil
    @FocusState private var descriptionIsFocused: Bool
    
    // Delete confirmation states
    @State private var showingDeleteConfirmation = false
    @State private var showingRecurringDeleteOptions = false
    
    // String representation of the description for editing
    @State private var descriptionText: String = ""
    
    // Checklist management
    @State private var checklistItems: [ChecklistItem] = []
    @State private var newChecklistItem: String = ""
    @FocusState private var checklistInputFocused: Bool
    
    // Category management
    @State private var selectedCategory: Category?
    
    init(item: ScheduleItem, selectedDate: Date, onSave: @escaping (ScheduleItem) -> Void, onDelete: ((DeleteOption) -> Void)?) {
        self._item = State(initialValue: item)
        self.selectedDate = selectedDate
        self.onSave = onSave
        self.onDelete = onDelete
        self._descriptionText = State(initialValue: item.descriptionText)
        self._checklistItems = State(initialValue: item.checklist)
        self._selectedCategory = State(initialValue: item.category)
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
                Color("Background").opacity(0.2)
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
                    
                    // Category Section
                    Section(header: Text("Category")) {
                        CategoryPickerView(selectedCategory: $selectedCategory)
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
                        
                        // Show end repeat options when frequency is not "Never"
                        if item.frequency != .never {
                            HStack {
                                Text("End Repeat")
                                Spacer()
                                Picker("", selection: $item.endRepeatOption) {
                                    ForEach(EndRepeatOption.allCases) { option in
                                        Text(option.displayName).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            // Show date picker when "On Date" is selected
                            if item.endRepeatOption == .onDate {
                                HStack {
                                    Text("End Date")
                                    Spacer()
                                    DatePicker("", selection: $item.endRepeatDate, displayedComponents: .date)
                                        .labelsHidden()
                                }
                            }
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
                    
                    // Delete Section - Only show if onDelete closure is provided (not for new events)
                    if onDelete != nil {
                        Section {
                            Button("Delete Event") {
                                if item.frequency == .never {
                                    // Single event - show simple confirmation
                                    showingDeleteConfirmation = true
                                } else {
                                    // Recurring event - show options
                                    showingRecurringDeleteOptions = true
                                }
                            }
                            .foregroundColor(.red)
                        }
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
                        item.category = selectedCategory
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
            selectedCategory = item.category
        }
        .onDisappear {
            locationSearchTask?.cancel()
        }
        .onChange(of: item.frequency) { _, newFrequency in
            // Reset end repeat options when frequency changes to "Never"
            if newFrequency == .never {
                item.endRepeatOption = .never
            }
        }
        // Simple delete confirmation for single events
        .alert("Delete Event", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?(.thisEvent)
            }
        } message: {
            Text("Are you sure you want to delete this event? This action cannot be undone.")
        }
        // Recurring event delete options
        .confirmationDialog("Delete Recurring Event", isPresented: $showingRecurringDeleteOptions) {
            Button("Delete This Event Only") {
                onDelete?(.thisEvent)
            }
            Button("Delete All Events in Series", role: .destructive) {
                onDelete?(.allEvents)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This is a recurring event. Would you like to delete only this occurrence or all events in the series?")
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
