//
//  ScheduleView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI
import MapKit


struct ScheduleItem: Identifiable {
    let id = UUID()
    var title: String
    var time: Date
    var icon: String
    var color: String
    var isRepeating: Bool
    var frequency: Frequency = .never
    var description: String = ""
    var location: String = ""
    var allDay: Bool = false
    var category: String = ""
    var type: String = "Schedule"
    var isCompleted: Bool = false
    var startTime: Date = Date()
    var endTime: Date = Date()
}

struct ScheduleView: View {
    var selectedDate: Date
    @State private var presentedItem: ScheduleItem? = nil
    @State private var showDetail: Bool = false
    @State private var showEdit: Bool = false
    
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
                    presentedItem = ScheduleItem(
                        title: getScheduleTitle(for: selectedDate),
                        time: getScheduleTimeAsDate(for: selectedDate),
                        icon: getScheduleIcon(for: selectedDate),
                        color: "Color1",
                        isRepeating: true,
                        startTime: getScheduleStartTime(for: selectedDate)
                    )
                    showDetail = true
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
                    presentedItem = ScheduleItem(
                        title: "Morning Walk",
                        time: getFixedTime(hour: 12, minute: 0),
                        icon: "figure.walk",
                        color: "Color2",
                        isRepeating: false,
                        startTime: getFixedTime(hour: 12, minute: 0)
                    )
                    showDetail = true
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
                    presentedItem = ScheduleItem(
                        title: "Team Meeting",
                        time: getFixedTime(hour: 12, minute: 0),
                        icon: "person.3.fill",
                        color: "Color3",
                        isRepeating: true,
                        startTime: getFixedTime(hour: 12, minute: 0)
                    )
                    showDetail = true
                }
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .sheet(isPresented: $showDetail) {
            if let item = presentedItem {
                ScheduleDetailView(
                    item: item,
                    onEdit: { showEdit = true },
                    onSave: { editedItem in
                        presentedItem = editedItem
                        showEdit = false
                    }
                )
            }
        }
        .sheet(isPresented: $showEdit) {
            if let item = presentedItem {
                ScheduleEditView(item: item) { updatedItem in
                    presentedItem = updatedItem
                    showEdit = false
                }
            }
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
    
    // Helper to convert time string to Date for schedule items
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
    
    private func bindingForPresentedItem() -> Binding<ScheduleItem>? {
        guard let _ = presentedItem else { return nil }
        return Binding(
            get: { presentedItem! },
            set: { presentedItem = $0 }
        )
    }
}

struct ScheduleDetailView: View {
    let item: ScheduleItem
    let onEdit: () -> Void
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showEditView = false
    
    var body: some View {
        NavigationStack {
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
                
                // Event Details
                VStack(spacing: 16) {
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text(DateFormatter.localizedString(from: item.time, dateStyle: .none, timeStyle: .short))
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    
                    if item.isRepeating {
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundColor(.gray)
                            Text("Repeating")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // Edit Button
                Button(action: {
                    onEdit()
                    dismiss()
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
            }
            .padding()
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
    @State private var textSelection: TextSelection? = nil
    @State private var isChecklistMode = false // Track which mode is active
    @State private var currentParagraphIndex = 0 // Track which paragraph we're in
    
    init(item: ScheduleItem, onSave: @escaping (ScheduleItem) -> Void) {
        self._item = State(initialValue: item)
        self.onSave = onSave
    }
    
    // MARK: - Toggle Functions
    private func toggleToTextMode() {
        isChecklistMode = false
        removeCheckboxFromCurrentParagraph()
        
        DispatchQueue.main.async {
            self.descriptionIsFocused = true
        }
    }
    
    private func toggleToChecklistMode() {
        isChecklistMode = true
        addCheckboxToCurrentParagraph()
        
        DispatchQueue.main.async {
            self.descriptionIsFocused = true
        }
    }
    
    private func addCheckboxToCurrentParagraph() {
        let paragraphs = item.description.components(separatedBy: "\n")
        
        if paragraphs.isEmpty || item.description.isEmpty {
            item.description = "☐ "
            return
        }
        
        var modifiedParagraphs = paragraphs
        let lastParagraphIndex = paragraphs.count - 1
        let currentParagraph = paragraphs[lastParagraphIndex]
        
        // Only add checkbox if paragraph doesn't already have one
        if !currentParagraph.hasPrefix("☐ ") && !currentParagraph.hasPrefix("☑ ") {
            modifiedParagraphs[lastParagraphIndex] = "☐ " + currentParagraph
            item.description = modifiedParagraphs.joined(separator: "\n")
        }
    }
    
    private func removeCheckboxFromCurrentParagraph() {
        let paragraphs = item.description.components(separatedBy: "\n")
        guard !paragraphs.isEmpty else { return }
        
        var modifiedParagraphs = paragraphs
        let lastParagraphIndex = paragraphs.count - 1
        let currentParagraph = paragraphs[lastParagraphIndex]
        
        var modifiedParagraph = currentParagraph
        
        // Remove checkbox if present
        if modifiedParagraph.hasPrefix("☐ ") {
            modifiedParagraph = String(modifiedParagraph.dropFirst(2))
        } else if modifiedParagraph.hasPrefix("☑ ") {
            modifiedParagraph = String(modifiedParagraph.dropFirst(2))
        }
        
        modifiedParagraphs[lastParagraphIndex] = modifiedParagraph
        item.description = modifiedParagraphs.joined(separator: "\n")
    }
    
    private func handleTextChange(oldValue: String, newValue: String) {
        // Check if user pressed Enter (added a newline) while in checklist mode
        if isChecklistMode && newValue.count > oldValue.count {
            let difference = String(newValue.suffix(newValue.count - oldValue.count))
            
            // If user just added a newline, automatically add a checklist item
            if difference == "\n" {
                // Small delay to ensure the newline is processed first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.item.description += "☐ "
                }
            }
        }
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
                print("DEBUG: Found \(mapped.count) map items: \(mapped.map { $0.mapItem.name ?? "Unknown" })")
                locationSearchResults = mapped
            } else {
                print("DEBUG: No map items found")
                locationSearchResults = []
            }
        }
    }
    
    var body: some View {
        NavigationView {
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
                        
                        // Only show time picker if not all-day
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

                Section {
                    // Enhanced Description field with toolbar
                    VStack(alignment: .leading, spacing: 0) {
                        // Always visible toolbar for text formatting
                        HStack {
                            Button(action: {
                                toggleToTextMode()
                            }) {
                                Image(systemName: "textformat")
                                    .font(.system(size: 16))
                                    .foregroundColor(isChecklistMode ? .gray : .blue)
                                    .frame(width: 32, height: 32)
                                    .background(isChecklistMode ? Color.gray.opacity(0.1) : Color.blue.opacity(0.15))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                toggleToChecklistMode()
                            }) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 16))
                                    .foregroundColor(isChecklistMode ? .blue : .gray)
                                    .frame(width: 32, height: 32)
                                    .background(isChecklistMode ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        
                        // Text Editor for description with selection tracking
                        TextEditor(text: $item.description)
                            .focused($descriptionIsFocused)
                            .frame(minHeight: 100, maxHeight: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(descriptionIsFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .onChange(of: descriptionIsFocused) { _, newValue in
                                isDescriptionFocused = newValue
                            }
                            .onChange(of: item.description) { oldValue, newValue in
                                handleTextChange(oldValue: oldValue, newValue: newValue)
                            }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Button(action: {
                            toggleToTextMode()
                        }) {
                            Image(systemName: "textformat")
                                .foregroundColor(isChecklistMode ? .gray : .blue)
                        }
                        
                        Button(action: {
                            toggleToChecklistMode()
                        }) {
                            Image(systemName: "checklist")
                                .foregroundColor(isChecklistMode ? .blue : .gray)
                        }
                        
                        Spacer()
                        
                        Button("Done") {
                            descriptionIsFocused = false
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(item)
                        dismiss()
                    }
                }
            }
            .onTapGesture {
                // Only dismiss keyboard when tapping outside the description area
                // This helps maintain focus when using toolbar buttons
            }
        }
        .onAppear {
            performLocationSearch()
            // Start in text mode by default
            isChecklistMode = false
        }
    }
    
    private func insertTextAtCursor(_ text: String) {
        // Switch to text mode and remove checkbox from current line
        isChecklistMode = false
        removeCheckboxFromCurrentLine()
        
        // Keep the TextEditor focused when inserting text
        DispatchQueue.main.async {
            self.descriptionIsFocused = true
        }
    }
    
    private func removeCheckboxFromCurrentLine() {
        let lines = item.description.components(separatedBy: "\n")
        
        // Find the current line (we'll assume it's the last line since user is typing)
        guard !lines.isEmpty else { return }
        
        var modifiedLines = lines
        let lastLineIndex = lines.count - 1
        let currentLine = lines[lastLineIndex]
        
        // Simple string replacement to remove checkbox patterns
        var modifiedLine = currentLine
        
        // Remove empty checkbox
        if modifiedLine.hasPrefix("☐ ") {
            modifiedLine = String(modifiedLine.dropFirst(2))
        }
        // Remove checked checkbox
        else if modifiedLine.hasPrefix("☑ ") {
            modifiedLine = String(modifiedLine.dropFirst(2))
        }
        
        modifiedLines[lastLineIndex] = modifiedLine
        item.description = modifiedLines.joined(separator: "\n")
    }
    
    private func insertChecklistAtCursor() {
        // Switch to checklist mode
        isChecklistMode = true
        
        let lines = item.description.components(separatedBy: "\n")
        guard !lines.isEmpty else {
            // If empty, just add a checkbox
            item.description = "☐ "
            return
        }
        
        var modifiedLines = lines
        let lastLineIndex = lines.count - 1
        let currentLine = lines[lastLineIndex]
        
        // If current line doesn't already have a checkbox, add one
        if !currentLine.hasPrefix("☐ ") && !currentLine.hasPrefix("☑ ") {
            modifiedLines[lastLineIndex] = "☐ " + currentLine
            item.description = modifiedLines.joined(separator: "\n")
        }
        
        // Maintain focus on the TextEditor
        DispatchQueue.main.async {
            self.descriptionIsFocused = true
        }
    }
    
    private func addChecklistItem() {
        let cursorPosition = item.description.isEmpty ? 0 : item.description.count
        let newChecklistItem = item.description.isEmpty ? "☐ " : "\n☐ "
        
        // Insert checklist item at cursor position
        let startIndex = item.description.index(item.description.startIndex, offsetBy: min(cursorPosition, item.description.count))
        item.description.insert(contentsOf: newChecklistItem, at: startIndex)
    }
}


// MARK: - Previews

#Preview("Schedule View") {
    ZStack {
        BackgroundView()
        ScheduleView(selectedDate: Date())
    }
}

#Preview("Schedule Detail View") {
    ZStack {
        BackgroundView()
        ScheduleDetailView(
            item: ScheduleItem(
                title: "Sample Event",
                time: Date(),
                icon: "calendar",
                color: "blue",
                isRepeating: true,
                frequency: .everyWeek,
                description: "Sample description",
                location: "Sample location",
                startTime: Date(),
                endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
            ),
            onEdit: { },
            onSave: { _ in }
        )
    }
}

#Preview("Schedule Edit View") {
    ZStack {
        BackgroundView()
        ScheduleEditView(
            item: ScheduleItem(
                title: "Sample Event",
                time: Date(),
                icon: "calendar",
                color: "blue",
                isRepeating: true,
                frequency: .everyWeek,
                description: "",
                location: "Sample location",
                startTime: Date(),
                endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
            ),
            onSave: { _ in }
        )
    }
}
