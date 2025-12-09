import SwiftUI
import MapKit

// MARK: - IdentifiableMapItem for location search
struct IdentifiableMapItem: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
}

// MARK: - Navigation Destination Enum
enum ScheduleDestination: Hashable, Equatable {
    case detail(ScheduleItem)
    case edit(ScheduleItem)
    case create
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .detail(let item):
            hasher.combine("detail")
            hasher.combine(item.id)
        case .edit(let item):
            hasher.combine("edit")
            hasher.combine(item.id)
        case .create:
            hasher.combine("create")
        }
    }
    
    static func == (lhs: ScheduleDestination, rhs: ScheduleDestination) -> Bool {
        switch (lhs, rhs) {
        case (.detail(let lhsItem), .detail(let rhsItem)):
            return lhsItem.id == rhsItem.id
        case (.edit(let lhsItem), .edit(let rhsItem)):
            return lhsItem.id == rhsItem.id
        case (.create, .create):
            return true
        default:
            return false
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
    @StateObject private var dataManager = UnifiedDataManager.shared
    @State private var showingNewItem = false
    @State private var showingDetail: ScheduleItem?
    @State private var showingEdit: ScheduleItem?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    var body: some View {
        ZStack {

            VStack {
//                HStack {
//                    Text("Schedule")
//                        .sectionHeaderStyle()
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        showingNewItem = true
//                    }) {
//                        Image(systemName: "plus")
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                            .contentShape(Rectangle())
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//                .padding(.vertical, 16)
                
                VStack(spacing: 12) {
                    let allScheduleItems = getActualScheduleItems(selectedDate).sorted { item1, item2 in
                        let time1 = getActualTimeForDate(item1, on: selectedDate)
                        let time2 = getActualTimeForDate(item2, on: selectedDate)
                        return time1 < time2
                    }
                    
                    if !allScheduleItems.isEmpty {
                        ForEach(allScheduleItems, id: \.id) { item in
                            ScheduleRowView(item: item, selectedDate: selectedDate) {
                                showingDetail = item
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding()
            .sheet(isPresented: $showingNewItem) {
                NewScheduleItemView(
                    selectedDate: selectedDate,
                    onSave: { newItem in
                        dataManager.addItem(newItem)
                        showingNewItem = false
                    }
                )
            }
            .sheet(item: $showingDetail) { item in
                NavigationView {
                    ScheduleDetailView(
                        item: item,
                        selectedDate: selectedDate,
                        onSave: { updatedItem in
                            dataManager.updateItem(updatedItem)
                        }
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showingDetail = nil
                            }) {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                }
                .presentationDetents([
                    .fraction(0.5), // start at ~50% height
                    .large
                ])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
                .presentationSizing(.fitted)
            }
            .fullScreenCover(item: $showingEdit) { item in
                NavigationView {
                    EditScheduleItemView(
                        item: item,
                        selectedDate: selectedDate,
                        onSave: { updatedItem in
                            dataManager.updateItem(updatedItem)
                        },
                        onDelete: { deleteOption in
                            handleDelete(item: item, option: deleteOption)
                        }
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showingEdit = nil
                            }) {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getActualTimeForDate(_ item: ScheduleItem, on date: Date) -> Date {
        let calendar = Calendar.current
        
        if item.frequency == .never || item.itemType == .todo {
            return item.startTime
        }
        
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: item.startTime)
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second
        
        return calendar.date(from: combinedComponents) ?? item.startTime
    }
    
    private func handleDelete(item: ScheduleItem, option: DeleteOption) {
        switch option {
        case .thisEvent:
            dataManager.excludeDateFromRecurring(item: item, excludeDate: selectedDate)
        case .allEvents:
            dataManager.deleteItem(item)
        }
    }
    
    private func getActualScheduleItems(_ date: Date) -> [ScheduleItem] {
        return dataManager.items.filter { item in
            return item.shouldAppear(on: date)
        }
    }
}

// MARK: - Schedule Row View Component
struct ScheduleRowView: View {
    let item: ScheduleItem
    let selectedDate: Date
    let onTap: () -> Void
    @StateObject private var dataManager = UnifiedDataManager.shared
    
    var body: some View {
        HStack {
            ZStack {
                Capsule()
                    .fill(Color(item.color))
                    .frame(width: 50, height: 75)
                Image(systemName: item.icon)
                    .font(.title2)
                    .foregroundStyle(Color(.secondarySystemGroupedBackground))
            }
            .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 2) {
                if item.itemType == .scheduled {
                    HStack(spacing: 4) {
                        if item.allDay {
                            Text("All-day")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            HStack(spacing: 0) {
                                timeText(item.startTime)
                                Text(" → ")
                                timeText(item.endTime)
                                Text(" | \(formatDuration(from: item.startTime, to: item.endTime))")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        if item.frequency != .never {
                            Image(systemName: "repeat")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Text(item.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.vertical, 2)
                    .strikethrough(item.isCompleted(on: selectedDate))
                    .foregroundColor(item.isCompleted(on: selectedDate) ? .secondary : .primary)

                if !item.checklist.isEmpty {
                    let completedCount = item.checklist.filter { $0.isCompleted }.count
                    let totalCount = item.checklist.count
                    HStack(spacing: 4) {
                        Image(systemName: "checklist")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("Checklist \(completedCount)/\(totalCount)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if item.uniqueKey.hasPrefix("todo-") && item.itemType == .scheduled {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.blue.opacity(0.6))
                    .font(.caption)
            }
            
            Spacer()

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    dataManager.toggleItemCompletion(item: item, on: selectedDate)
                }
            }) {
                Image(systemName: item.isCompleted(on: selectedDate) ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(Color(item.color))
            }
            .buttonStyle(PlainButtonStyle())
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

    private func timeRangeWithDuration(start: Date, end: Date) -> String {
        let startText = formatTime(start)
        let endText = formatTime(end)
        let durationText = formatDuration(from: start, to: end)
        return "\(startText) → \(endText) | \(durationText)"
    }

    private func formatDuration(from start: Date, to end: Date) -> String {
        let interval = max(0, end.timeIntervalSince(start))
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        // Prefer hours and minutes
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = [.dropAll]
        if let formatted = formatter.string(from: interval) {
            return formatted
        }
        // Fallback manual formatting
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 && mins > 0 { return "\(hours)h \(mins)m" }
        if hours > 0 { return "\(hours)h" }
        return "\(mins)m"
    }
    
    private func timeText(_ date: Date) -> some View {
        let formatterHM = DateFormatter()
        formatterHM.dateFormat = "h:mm"
        let formatterPeriod = DateFormatter()
        formatterPeriod.dateFormat = "a"
        let hm = formatterHM.string(from: date)
        let period = formatterPeriod.string(from: date)
        // Compose: big h:mm and smaller AM/PM
        return HStack(spacing: 0) {
            Text(hm)
            Text(period)
                .font(.system(size: 9))
                .fontWeight(.light)
                .baselineOffset(-2)
        }
    }
}

// MARK: - New Schedule Item View (for creating new events)

struct NewScheduleItemView: View {
    private enum ExpandedEditorSection: Equatable { case none, schedule, description, checklist }
    @State private var expandedSection: ExpandedEditorSection = .none
    
    let selectedDate: Date
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var item: ScheduleItem
    @State private var locationSearchResults: [IdentifiableMapItem] = []
    @State private var isSearchingLocation = false
    @State private var locationSearchTask: Task<Void, Never>? = nil
    @FocusState private var descriptionIsFocused: Bool
    @FocusState private var titleIsFocused: Bool
    
    // Custom frequency states
    @State private var showingCustomFrequencyPicker = false
    @State private var customFrequencyConfig = CustomFrequencyConfig()
    
    // String representation of the description for editing
    @State private var descriptionText: String = ""
    
    // Checklist management
    @State private var checklistItems: [ChecklistItem] = []
    @State private var newChecklistItem: String = ""
    @FocusState private var checklistInputFocused: Bool
    
    // Icon selection
    @State private var showingIconPicker = false
    @State private var hasManuallySelectedIcon = false
    private let iconDataSource = IconDataSource.shared

    // MARK: - Icon Suggestion Helpers
    private func mapKeywordToIcon(in text: String) -> String? {
        let mapping: [String: String] = [
            // Reading/Work
            "book": "book.fill",
            "books": "books.vertical.fill",
            "reading": "book.fill",
            "read": "book.fill",
            "meeting": "calendar.badge.checkmark",
            
            // Drinks
            "coffee": "cup.and.saucer.fill",
            "tea": "mug.fill",
            
            // Meals
            "breakfast": "fork.knife",
            "brunch": "fork.knife",
            "lunch": "fork.knife",
            "dinner": "fork.knife",
            "supper": "fork.knife",
            "meal": "fork.knife",
            "eat": "fork.knife",
            "food": "fork.knife",

            // Time of day
            "morning": "sunrise.fill",
            "sunrise": "sunrise.fill",
            
            // Fitness
            "run": "figure.run",
            "running": "figure.run",
            "walk": "figure.walk",
            "walking": "figure.walk",
            "gym": "dumbbell.fill",
            "weights": "dumbbell.fill",
            "yoga": "figure.yoga",
            "swim": "figure.pool.swim",
            "swimming": "figure.pool.swim",

            // Travel
            "flight": "airplane",
            "plane": "airplane",
            "train": "train.side.front.car",
            "bus": "bus.fill",
            "car": "car.fill",

            // Events & celebrations
            "birthday": "birthday.cake.fill",
            "party": "party.popper.fill",

            // Shopping & chores
            "shopping": "bag.fill",
            "groceries": "cart.fill",
            "grocery": "cart.fill",
            "study": "books.vertical.fill",
            "class": "graduationcap.fill",
            "school": "graduationcap.fill",
            "doctor": "stethoscope",
            "dentist": "mouth.fill",
            "meds": "pills.fill",
            "medicine": "pills.fill",
            "water": "waterbottle.fill",
            "haircut": "scissors",
            "laundry": "washer.fill",
            "clean": "bubbles.and.sparkles.fill",
            "cleaning": "bubbles.and.sparkles.fill"
        ]
        let lower = text.lowercased()
        for (keyword, icon) in mapping {
            if lower.contains(keyword) {
                return icon
            }
        }
        return nil
    }

    private func updateIconBasedOnTitle(_ title: String) {
        guard !hasManuallySelectedIcon else { return }
        let trimmed = title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmed.isEmpty {
            item.icon = "calendar"
            return
        }

        // First, try curated keyword mapping
        if let mapped = mapKeywordToIcon(in: trimmed) {
            item.icon = mapped
            return
        }

        // Fallback: token-based matching against available icons
        let tokens = trimmed
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        guard !tokens.isEmpty else { return }

        let allIcons = iconDataSource.getAllIcons()
        let scoredMatches: [(IconItem, Int)] = allIcons.map { icon in
            let searchable = (icon.displayName + " " + icon.name).lowercased()
            let score = tokens.reduce(0) { $0 + (searchable.contains($1) ? 1 : 0) }
            return (icon, score)
        }.filter { $0.1 > 0 }

        if let best = scoredMatches.sorted(by: { lhs, rhs in
            if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
            return lhs.0.displayName.count < rhs.0.displayName.count
        }).first {
            item.icon = best.0.name
        }
        // No scored matches — default to calendar
        else {
            item.icon = "calendar"
        }
    }
    
    // MARK: - Location Search
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
    
    private var dateSummaryFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df
    }
    private var timeSummaryFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        return df
    }
    
    private func dateRangeSummaryView(start: Date, end: Date) -> some View {
        let startDateText = dateSummaryFormatter.string(from: start)
        let hmFormatter = DateFormatter(); hmFormatter.dateFormat = "h:mm"
        let apFormatter = DateFormatter(); apFormatter.dateFormat = "a"
        let startHM = hmFormatter.string(from: start)
        let startAP = apFormatter.string(from: start)
        let endHM = hmFormatter.string(from: end)
        let endAP = apFormatter.string(from: end)
        return HStack(spacing: 4) {
            Text("\(startDateText) \(startHM)")
            Text(startAP).font(.caption2).fontWeight(.light).baselineOffset(-2)
            Text("→ \(endHM)")
            Text(endAP).font(.caption2).fontWeight(.light).baselineOffset(-2)
        }
        .foregroundColor(.primary)
    }
    
    init(selectedDate: Date, onSave: @escaping (ScheduleItem) -> Void) {
        self.selectedDate = selectedDate
        self.onSave = onSave
        
        // Create a new schedule item with default values using next upcoming hour
        let calendar = Calendar.current
        let now = Date()
        
        // Determine the reference time - use current time if selected date is today, otherwise use selected date
        let referenceTime = calendar.isDate(selectedDate, inSameDayAs: now) ? now : selectedDate
        
        let defaultStartTime = Self.nextUpcomingHour(from: referenceTime)
        let defaultEndTime = calendar.date(byAdding: .hour, value: 1, to: defaultStartTime) ?? defaultStartTime
        
        self._item = State(initialValue: ScheduleItem.createScheduled(
            title: "",
            startTime: defaultStartTime,
            endTime: defaultEndTime,
            icon: "calendar",
            color: "Color1",
            frequency: .never,
            descriptionText: "",
            location: "",
            allDay: false,
            checklist: [],
            category: nil,
            endRepeatOption: .never,
            endRepeatDate: calendar.date(byAdding: .month, value: 1, to: defaultStartTime) ?? defaultStartTime
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundPopup")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Form {
                        Section {
                            HStack {
                                Button(action: {
                                    showingIconPicker = true
                                }) {
                                    Image(systemName: item.icon)
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                        .padding(.trailing, 8)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                TextField("Title", text: $item.title)
                                    .onChange(of: item.title) { _, newValue in
                                        updateIconBasedOnTitle(newValue)
                                    }
                                    .multilineTextAlignment(.leading)
                                    .focused($titleIsFocused)
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
                            
                            TextField("URL", text: $item.url)
                                .multilineTextAlignment(.leading)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.URL)
                        }
                        
                        Section {
                            HStack {
                                Text("Color")
                                Spacer()
                                HStack(spacing: 8) {
                                    ForEach(["Color1","Color2","Color3","Color4","Color5","Color6","Color7"], id: \.self) { color in
                                        Button(action: {
                                            item.color = color
                                        }) {
                                            Circle()
                                                .fill(Color(color))
                                                .frame(width: 24, height: 24)
                                                .overlay(Circle().stroke(item.color == color ? Color.primary : Color.clear, lineWidth: 2))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        
                        if expandedSection != .schedule {
                            Section {
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        expandedSection = .schedule
                                    }
                                }) {
                                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.primary)
                                        if item.allDay {
                                            Text("\(dateSummaryFormatter.string(from: item.startTime)) — All-day")
                                                .foregroundColor(.primary)
                                        } else {
                                            dateRangeSummaryView(start: item.startTime, end: item.endTime)
                                        }
                                        Spacer()
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        if (item.itemType == .scheduled || (item.itemType == .todo && item.hasDate)) && expandedSection == .schedule {
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
                                            .onChange(of: item.startTime) { _, newStartTime in
                                                // Automatically update end time to be one hour after start time
                                                let calendar = Calendar.current
                                                item.endTime = calendar.date(byAdding: .hour, value: 1, to: newStartTime) ?? newStartTime
                                            }
                                    }
                                }
                                
                                // For todos, show "Due" instead of "End" and only show end time for scheduled items
                                if item.itemType == .scheduled {
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
                                }
                                
                                // Repeat Section - now available for both types
                                HStack {
                                    Text("Repeat")
                                    Spacer()
                                    Menu {
                                        ForEach(Frequency.allCases) { frequency in
                                            Button(frequency.displayName) {
                                                item.frequency = frequency
                                                if frequency == .custom {
                                                    showingCustomFrequencyPicker = true
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            if item.frequency == .custom {
                                                Text(customFrequencyConfig.displayDescription())
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)
                                            } else {
                                                Text(item.frequency.displayName)
                                                    .foregroundColor(.primary)
                                            }
                                            Image(systemName: "chevron.up.chevron.down")
                                                .foregroundColor(.secondary)
                                                .font(.caption2)
                                        }
                                    }
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
                        }
                        
                        Section() {
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
                                
                                if descriptionText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
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
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    expandedSection = .description
                                }
                            }
                        }
                        
                        Section {
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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                expandedSection = .checklist
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .padding(.top, 8)
            }
            .navigationTitle("New")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        item.descriptionText = descriptionText
                        item.checklist = checklistItems
                        
                        // Save custom frequency config if custom is selected
                        if item.frequency == .custom {
                            item.customFrequencyConfig = customFrequencyConfig
                        } else {
                            item.customFrequencyConfig = nil
                        }
                        
                        onSave(item)
                        dismiss()
                    }
                    .disabled(item.title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)
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
            // no selectedCategory or manageCategories
            
            // Load existing custom frequency config
            if let existingConfig = item.customFrequencyConfig {
                customFrequencyConfig = existingConfig
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { titleIsFocused = true }
        }
        .onDisappear {
            locationSearchTask?.cancel()
        }
        .onChange(of: item.frequency) { _, newFrequency in
            // Reset end repeat options when frequency changes to "Never"
            if newFrequency == .never {
                item.endRepeatOption = .never
            }
            
            // Show custom frequency picker when custom is selected
            if newFrequency == .custom {
                showingCustomFrequencyPicker = true
            }
        }
        .sheet(isPresented: $showingCustomFrequencyPicker) {
            CustomFrequencyPickerView(
                customConfig: $customFrequencyConfig,
                endRepeatOption: $item.endRepeatOption,
                endRepeatDate: $item.endRepeatDate
            )
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $item.icon)
                .onDisappear {
                    hasManuallySelectedIcon = true
                }
        }
    }
    
    // MARK: - Checklist Helper Methods
    
    private func addChecklistItem() {
        guard !newChecklistItem.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else { return }
        
        let newItem = ChecklistItem(text: newChecklistItem.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        checklistItems.append(newItem)
        newChecklistItem = ""
        checklistInputFocused = false
    }
    
    private func deleteChecklistItems(offsets: IndexSet) {
        checklistItems.remove(atOffsets: offsets)
    }
}

// MARK: - Edit Schedule Item View (for editing existing events)

struct EditScheduleItemView: View {
    let item: ScheduleItem
    let selectedDate: Date
    let onSave: (ScheduleItem) -> Void
    let onDelete: (DeleteOption) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var editableItem: ScheduleItem
    @State private var locationSearchResults: [IdentifiableMapItem] = []
    @State private var isSearchingLocation = false
    @State private var locationSearchTask: Task<Void, Never>? = nil
    @FocusState private var descriptionIsFocused: Bool
    
    // Custom frequency states
    @State private var showingCustomFrequencyPicker = false
    @State private var customFrequencyConfig = CustomFrequencyConfig()
    
    // String representation of the description for editing
    @State private var descriptionText: String = ""
    
    // Checklist management
    @State private var checklistItems: [ChecklistItem] = []
    @State private var newChecklistItem: String = ""
    @FocusState private var checklistInputFocused: Bool
    @Environment(\.editMode) private var editMode // Add edit mode environment

    private enum ExpandedEditorSection: Equatable { case none, schedule }
    @State private var expandedSection: ExpandedEditorSection = .none
    
    // Icon selection
    @State private var showingIconPicker = false
    
    // Delete confirmation states
    @State private var showingDeleteConfirmation = false
    @State private var showingRecurringDeleteOptions = false
    
    init(item: ScheduleItem, selectedDate: Date, onSave: @escaping (ScheduleItem) -> Void, onDelete: @escaping (DeleteOption) -> Void) {
        self.item = item
        self.selectedDate = selectedDate
        self.onSave = onSave
        self.onDelete = onDelete
        self._editableItem = State(initialValue: item)
    }
    
    private func performLocationSearch() {
        locationSearchTask?.cancel()
        
        guard !editableItem.location.isEmpty else {
            locationSearchResults = []
            return
        }
        
        locationSearchTask = Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = editableItem.location
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
    
    private func formattedAddress(from mapItem: MKMapItem) -> String {
        if #available(iOS 26.0, *) {
            // Use newer MapKit APIs when available. To avoid SDK differences, conservatively
            // fall back to the item's name on iOS 26+ without touching deprecated properties.
            return (mapItem.name ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            let placemark = mapItem.placemark

            let street = [placemark.subThoroughfare, placemark.thoroughfare]
                .compactMap { $0 }
                .joined(separator: " ")
            let cityStatePostal = [placemark.locality, placemark.administrativeArea, placemark.postalCode]
                .compactMap { $0 }
                .joined(separator: ", ")
            let country = placemark.country ?? ""
            let name = placemark.name ?? ""

            var parts: [String] = []
            if !street.isEmpty { parts.append(street) }
            if !cityStatePostal.isEmpty { parts.append(cityStatePostal) }
            if !country.isEmpty { parts.append(country) }

            if parts.isEmpty {
                let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                return trimmedName
            }

            return parts.joined(separator: "\n")
        }
    }

    private var dateSummaryFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df
    }
    private var timeSummaryFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        return df
    }
    
    private func dateRangeSummaryView(start: Date, end: Date) -> some View {
        let startDateText = dateSummaryFormatter.string(from: start)
        let hmFormatter = DateFormatter(); hmFormatter.dateFormat = "h:mm"
        let apFormatter = DateFormatter(); apFormatter.dateFormat = "a"
        let startHM = hmFormatter.string(from: start)
        let startAP = apFormatter.string(from: start)
        let endHM = hmFormatter.string(from: end)
        let endAP = apFormatter.string(from: end)
        return HStack(spacing: 4) {
            Text("\(startDateText) \(startHM)")
            Text(startAP).font(.caption2).fontWeight(.light).baselineOffset(-2)
            Text("→ \(endHM)")
            Text(endAP).font(.caption2).fontWeight(.light).baselineOffset(-2)
        }
        .foregroundColor(.primary)
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundPopup")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Form {
                    Section {
                        HStack {
                            Button(action: {
                                showingIconPicker = true
                            }) {
                                Image(systemName: editableItem.icon)
                                    .font(.title3)
                                    .foregroundColor(.primary)
                                    .padding(.trailing, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            TextField("Title", text: $editableItem.title)
                                .multilineTextAlignment(.leading)
                        }
                        
                        TextField("Location", text: $editableItem.location, onEditingChanged: { editing in
                            isSearchingLocation = editing
                            if editing { performLocationSearch() }
                        })
                        .multilineTextAlignment(.leading)
                        .onChange(of: editableItem.location) { _, _ in
                            performLocationSearch()
                        }
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        TextField("URL", text: $editableItem.url)
                            .multilineTextAlignment(.leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)
                        
                        if isSearchingLocation && !locationSearchResults.isEmpty {
                            ForEach(Array(locationSearchResults.prefix(3).enumerated()), id: \.offset) { index, itemResult in
                                Button(action: {
                                    let name = itemResult.mapItem.name ?? "Selected Location"
                                    let address = formattedAddress(from: itemResult.mapItem)
                                    editableItem.location = name + (address.isEmpty ? "" : "\n" + address)
                                    isSearchingLocation = false
                                    locationSearchResults = []
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(itemResult.mapItem.name ?? "Unknown")
                                            .foregroundColor(.primary)
                                        Text(formattedAddress(from: itemResult.mapItem))
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
                            Text("Color")
                            Spacer()
                            HStack(spacing: 8) {
                                ForEach(["Color1","Color2","Color3","Color4","Color5","Color6","Color7"], id: \.self) { color in
                                    Button(action: {
                                        editableItem.color = color
                                    }) {
                                        Circle()
                                            .fill(Color(color))
                                            .frame(width: 24, height: 24)
                                            .overlay(Circle().stroke(editableItem.color == color ? Color.primary : Color.clear, lineWidth: 2))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    
                    // Todo-specific options
                    if editableItem.itemType == .todo {
                        Section {
                            // Date assignment toggle
                            HStack {
                                Text("Assign Date")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { editableItem.hasDate },
                                    set: { newValue in
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            if newValue {
                                                // Assign current selected date
                                                editableItem.setDate(selectedDate, allDay: editableItem.allDay)
                                            } else {
                                                // Remove date assignment
                                                editableItem.setDate(nil)
                                            }
                                        }
                                    }
                                ))
                            }
                            
                            // Date and time options (only show if date is assigned)
                            if editableItem.hasDate {
                                HStack {
                                    Text("Due Date")
                                    Spacer()
                                    DatePicker("", selection: Binding(
                                        get: { editableItem.startTime },
                                        set: { newDate in
                                            editableItem.setDate(newDate, allDay: editableItem.allDay)
                                        }
                                    ), displayedComponents: .date)
                                    .labelsHidden()
                                }
                                
                                // Show time picker only if not all-day
                                if !editableItem.allDay {
                                    HStack {
                                        Text("Due Time")
                                        Spacer()
                                        DatePicker("", selection: Binding(
                                            get: { editableItem.startTime },
                                            set: { newDate in
                                                editableItem.setDate(newDate, allDay: false)
                                            }
                                        ), displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                    }
                                }
                            }
                        }
                    }
                    
                    // Collapsed summary row when not expanded
                    if expandedSection != .schedule {
                        Section {
                            Button(action: {
                                withAnimation(.easeInOut) { expandedSection = .schedule }
                            }) {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Image(systemName: "calendar").foregroundColor(.primary)
                                    if editableItem.allDay {
                                        Text("\(dateSummaryFormatter.string(from: editableItem.startTime)) — All-day")
                                            .foregroundColor(.primary)
                                    } else {
                                        dateRangeSummaryView(start: editableItem.startTime, end: editableItem.endTime)
                                    }
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Expanded schedule editor
                    if (editableItem.itemType == .scheduled || (editableItem.itemType == .todo && editableItem.hasDate)) && expandedSection == .schedule {
                        Section {
                            HStack {
                                Text("All-day")
                                Spacer()
                                Toggle("", isOn: $editableItem.allDay)
                            }
                            HStack {
                                Text("Start")
                                Spacer()
                                DatePicker("", selection: $editableItem.startTime, displayedComponents: .date)
                                    .labelsHidden()
                                if !editableItem.allDay {
                                    DatePicker("", selection: $editableItem.startTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .onChange(of: editableItem.startTime) { _, newStartTime in
                                            let calendar = Calendar.current
                                            editableItem.endTime = calendar.date(byAdding: .hour, value: 1, to: newStartTime) ?? newStartTime
                                        }
                                }
                            }
                            if editableItem.itemType == .scheduled {
                                HStack {
                                    Text("End")
                                    Spacer()
                                    DatePicker("", selection: $editableItem.endTime, displayedComponents: .date)
                                        .labelsHidden()
                                    if !editableItem.allDay {
                                        DatePicker("", selection: $editableItem.endTime, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                    }
                                }
                            }
                            HStack {
                                Text("Repeat")
                                Spacer()
                                Menu {
                                    ForEach(Frequency.allCases) { frequency in
                                        Button(frequency.displayName) {
                                            editableItem.frequency = frequency
                                            if frequency == .custom { showingCustomFrequencyPicker = true }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        if editableItem.frequency == .custom {
                                            Text(customFrequencyConfig.displayDescription())
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                        } else {
                                            Text(editableItem.frequency.displayName)
                                                .foregroundColor(.primary)
                                        }
                                        Image(systemName: "chevron.up.chevron.down")
                                            .foregroundColor(.secondary)
                                            .font(.caption2)
                                    }
                                }
                            }
                            if editableItem.frequency != .never {
                                HStack {
                                    Text("End Repeat")
                                    Spacer()
                                    Picker("", selection: $editableItem.endRepeatOption) {
                                        ForEach(EndRepeatOption.allCases) { option in
                                            Text(option.displayName).tag(option)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                }
                                if editableItem.endRepeatOption == .onDate {
                                    HStack {
                                        Text("End Date")
                                        Spacer()
                                        DatePicker("", selection: $editableItem.endRepeatDate, displayedComponents: .date)
                                            .labelsHidden()
                                    }
                                }
                            }
                        }
                    }
                    
                    Section() {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $descriptionText)
                                .frame(minHeight: 100)
                                .focused($descriptionIsFocused)
                                .onTapGesture {
                                    descriptionIsFocused = true
                                }
                                .onChange(of: descriptionText) { _, newValue in
                                    editableItem.descriptionText = newValue
                                }
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                            
                            if descriptionText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
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
                    
                    Section {
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
                        .onMove(perform: moveChecklistItems) // Enable reordering
                        
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
                    
                    // Delete Section
                    Section {
                        Button("Delete Event") {
                            if editableItem.frequency == .never {
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
                .scrollContentBackground(.hidden)
                .contentShape(Rectangle())
                .onTapGesture {
                    if expandedSection != .none {
                        withAnimation(.easeInOut) { expandedSection = .none }
                    }
                }
            }
            .padding(.top, 8)
            .navigationTitle(editableItem.itemType == .todo ? "Edit Task" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        editableItem.descriptionText = descriptionText
                        editableItem.checklist = checklistItems
                        
                        if editableItem.frequency == .custom {
                            editableItem.customFrequencyConfig = customFrequencyConfig
                        } else {
                            editableItem.customFrequencyConfig = nil
                        }
                        
                        onSave(editableItem)
                        dismiss()
                    }
                }
            }
            .onAppear {
                performLocationSearch()
                descriptionText = editableItem.descriptionText
                checklistItems = editableItem.checklist
                // no selectedCategory or manageCategories
                
                if let existingConfig = editableItem.customFrequencyConfig {
                    customFrequencyConfig = existingConfig
                }
            }
            .onDisappear {
                locationSearchTask?.cancel()
            }
            .onChange(of: editableItem.frequency) { _, newFrequency in
                // Reset end repeat options when frequency changes to "Never"
                if newFrequency == .never {
                    editableItem.endRepeatOption = .never
                }
                
                // Show custom frequency picker when custom is selected
                if newFrequency == .custom {
                    showingCustomFrequencyPicker = true
                }
            }
            .sheet(isPresented: $showingCustomFrequencyPicker) {
                CustomFrequencyPickerView(
                    customConfig: $customFrequencyConfig,
                    endRepeatOption: $editableItem.endRepeatOption,
                    endRepeatDate: $editableItem.endRepeatDate
                )
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $editableItem.icon)
            }
            // Simple delete confirmation for single events
            .alert("Delete Event", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete(.thisEvent)
                }
            } message: {
                Text("Are you sure you want to delete this event? This action cannot be undone.")
            }
            // Recurring event delete options
            .confirmationDialog("Delete Recurring Event", isPresented: $showingRecurringDeleteOptions) {
                Button("Delete This Event Only") {
                    onDelete(.thisEvent)
                }
                Button("Delete All Events in Series", role: .destructive) {
                    onDelete(.allEvents)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This is a recurring event. Would you like to delete only this occurrence or all events in the series?")
            }
        }
        
    }
    
    // MARK: - Checklist Helper Methods
    
    private func addChecklistItem() {
        guard !newChecklistItem.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else { return }
        
        let newItem = ChecklistItem(text: newChecklistItem.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        checklistItems.append(newItem)
        newChecklistItem = ""
        checklistInputFocused = false
    }
    
    private func deleteChecklistItems(offsets: IndexSet) {
        checklistItems.remove(atOffsets: offsets)
    }
    
    private func moveChecklistItems(from source: IndexSet, to destination: Int) {
        checklistItems.move(fromOffsets: source, toOffset: destination)
    }
    
}

