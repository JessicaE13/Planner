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
    @State private var selectedItem: ScheduleItem?
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
                    let item = ScheduleItem(
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
                    let item = ScheduleItem(
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
                    let item = ScheduleItem(
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
                        selectedItem = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showEdit = true
                        }
                    },
                    onSave: { _ in }
                )
            }
        }
        .sheet(isPresented: $showEdit) {
            if let item = selectedItem {
                NavigationView {
                    ScheduleEditView(item: item) { updatedItem in
                        showEdit = false
                        selectedItem = nil
                    }
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
}

struct ScheduleDetailView: View {
    let item: ScheduleItem
    let onEdit: () -> Void
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
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
    @State private var currentLineFormat: LineFormat = .text
    
    enum LineFormat {
        case text
        case checklist
    }
    
    init(item: ScheduleItem, onSave: @escaping (ScheduleItem) -> Void) {
        self._item = State(initialValue: item)
        self.onSave = onSave
    }
    
    // MARK: - Helper Functions
    
    private func setCurrentLineFormat(_ format: LineFormat) {
        currentLineFormat = format
        
        DispatchQueue.main.async {
            self.descriptionIsFocused = true
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
                            setCurrentLineFormat(.text)
                        }) {
                            Image(systemName: "textformat")
                                .font(.system(size: 16))
                                .foregroundColor(currentLineFormat == .text ? .blue : .gray)
                                .frame(width: 32, height: 32)
                                .background(currentLineFormat == .text ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                                .cornerRadius(6)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            setCurrentLineFormat(.checklist)
                        }) {
                            Image(systemName: "checklist")
                                .font(.system(size: 16))
                                .foregroundColor(currentLineFormat == .checklist ? .blue : .gray)
                                .frame(width: 32, height: 32)
                                .background(currentLineFormat == .checklist ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                                .cornerRadius(6)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        Text("New lines will be: \(currentLineFormat == .text ? "Plain text" : "Checklist items")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 8)
                    
                    // Custom line-based editor
                    DescriptionLineEditor(
                        description: $item.description,
                        currentLineFormat: $currentLineFormat
                    )
                    .focused($descriptionIsFocused)
                    .frame(minHeight: 100, maxHeight: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(descriptionIsFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .onChange(of: descriptionIsFocused) { _, newValue in
                        isDescriptionFocused = newValue
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
                        setCurrentLineFormat(.text)
                    }) {
                        Image(systemName: "textformat")
                            .foregroundColor(currentLineFormat == .text ? .blue : .gray)
                    }
                    
                    Button(action: {
                        setCurrentLineFormat(.checklist)
                    }) {
                        Image(systemName: "checklist")
                            .foregroundColor(currentLineFormat == .checklist ? .blue : .gray)
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
        .onAppear {
            performLocationSearch()
            // Start in text mode by default
            currentLineFormat = .text
        }
        .onDisappear {
            locationSearchTask?.cancel()
        }
    }
}

// MARK: - Custom Line-Based Editor

struct DescriptionLine: Identifiable {
    let id = UUID()
    var text: String
    var isChecklist: Bool
    var isCompleted: Bool = false
}

struct DescriptionLineEditor: View {
    @Binding var description: String
    @Binding var currentLineFormat: ScheduleEditView.LineFormat
    @State private var lines: [DescriptionLine] = []
    @State private var newLineText: String = ""
    @State private var focusedLineIndex: Int? = nil
    @FocusState private var newLineFocused: Bool
    @FocusState private var lineFieldFocused: Int?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Existing lines
                ForEach(lines.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8) {
                        // Toggle circle for checklist items
                        if lines[index].isChecklist {
                            Button(action: {
                                lines[index].isCompleted.toggle()
                                updateDescription()
                            }) {
                                Image(systemName: lines[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(lines[index].isCompleted ? .blue : .gray)
                                    .font(.system(size: 18))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 2)
                        } else {
                            // Spacer for text lines to align with checklist items
                            Spacer()
                                .frame(width: 18)
                        }
                        
                        // Editable text
                        TextField("Line \(index + 1)", text: $lines[index].text, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .lineLimit(1...3)
                            .strikethrough(lines[index].isChecklist && lines[index].isCompleted)
                            .foregroundColor(lines[index].isChecklist && lines[index].isCompleted ? .secondary : .primary)
                            .focused($lineFieldFocused, equals: index)
                            .onChange(of: lines[index].text) { _, _ in
                                updateDescription()
                            }
                            .onTapGesture {
                                focusedLineIndex = index
                                lineFieldFocused = index
                            }
                        
                        // Delete button
                        Button(action: {
                            lines.remove(at: index)
                            updateDescription()
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red.opacity(0.7))
                                .font(.system(size: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, 2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(6)
                }
                
                // New line input
                HStack(alignment: .top, spacing: 8) {
                    // Toggle circle for checklist items
                    if currentLineFormat == .checklist {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                            .padding(.top, 2)
                    } else {
                        // Spacer for text lines
                        Spacer()
                            .frame(width: 18)
                    }
                    
                    TextField("Add new line...", text: $newLineText, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .focused($newLineFocused)
                        .onSubmit {
                            addNewLine()
                        }
                        .onTapGesture {
                            focusedLineIndex = nil // Clear focused line when editing new line
                            newLineFocused = true
                        }
                    
                    // Add button
                    Button(action: {
                        addNewLine()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 2)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(6)
            }
            .padding(8)
        }
        .onAppear {
            parseDescription()
        }
        .onChange(of: description) { _, newValue in
            // Only parse if the change came from outside this view
            if newValue != generateDescriptionString() {
                parseDescription()
            }
        }
        .onChange(of: currentLineFormat) { _, newFormat in
            // Convert the currently focused line when format changes
            if let focusedIndex = focusedLineIndex, focusedIndex < lines.count {
                let shouldBeChecklist = (newFormat == .checklist)
                if lines[focusedIndex].isChecklist != shouldBeChecklist {
                    lines[focusedIndex].isChecklist = shouldBeChecklist
                    if !shouldBeChecklist {
                        lines[focusedIndex].isCompleted = false // Reset completion when converting to text
                    }
                    updateDescription()
                }
            }
        }
        .onChange(of: lineFieldFocused) { _, newValue in
            if let focusedIndex = newValue {
                focusedLineIndex = focusedIndex
            }
        }
    }
    
    private func addNewLine() {
        guard !newLineText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newLine = DescriptionLine(
            text: newLineText.trimmingCharacters(in: .whitespacesAndNewlines),
            isChecklist: currentLineFormat == .checklist
        )
        
        lines.append(newLine)
        newLineText = ""
        updateDescription()
        
        // Keep focus on new line input
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            newLineFocused = true
        }
    }
    
    private func parseDescription() {
        // Parse the description string back into lines
        let textLines = description.components(separatedBy: "\n")
        lines = textLines.compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            
            // Check if it's a checklist item (starts with ☐ or ☑)
            if trimmed.hasPrefix("☐ ") {
                return DescriptionLine(
                    text: String(trimmed.dropFirst(2)),
                    isChecklist: true,
                    isCompleted: false
                )
            } else if trimmed.hasPrefix("☑ ") {
                return DescriptionLine(
                    text: String(trimmed.dropFirst(2)),
                    isChecklist: true,
                    isCompleted: true
                )
            } else {
                return DescriptionLine(
                    text: trimmed,
                    isChecklist: false
                )
            }
        }
    }
    
    private func updateDescription() {
        description = generateDescriptionString()
    }
    
    private func generateDescriptionString() -> String {
        return lines.map { line in
            if line.isChecklist {
                return (line.isCompleted ? "☑ " : "☐ ") + line.text
            } else {
                return line.text
            }
        }.joined(separator: "\n")
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
                location: "Sample location",
                startTime: Date(),
                endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
            ),
            onSave: { _ in }
        )
    }
}
