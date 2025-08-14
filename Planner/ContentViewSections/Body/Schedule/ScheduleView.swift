//
//  ScheduleView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI


struct ScheduleItem: Identifiable {
    let id = UUID()
    var title: String
    var time: Date
    var icon: String
    var color: String
    var isRepeating: Bool
    var frequency: Frequency = .everyWeek
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
            if let binding = bindingForPresentedItem() {
                ScheduleDetailView(item: binding)
            }
        }
        .sheet(isPresented: $showEdit) {
            if let binding = bindingForPresentedItem() {
                ScheduleEditView(item: binding) { updatedItem in
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
    @Binding var editingItem: ScheduleItem?
    @State private var showEditView = false
    @Environment(\.dismiss) private var dismiss
    
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
                    showEditView = true
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
            .navigationDestination(isPresented: $showEditView) {
                ScheduleEditView(item: item) { editedItem in
                    editingItem = editedItem
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
    
    init(item: ScheduleItem, onSave: @escaping (ScheduleItem) -> Void) {
        self._item = State(initialValue: item)
        self.onSave = onSave
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
                        Toggle("", isOn: $item.isRepeating)
                    }
                    HStack {
                        Text("Start")
                        Spacer()
                        DatePicker("", selection: $item.startTime, displayedComponents: .date)
                            .labelsHidden()
                        DatePicker("", selection: $item.startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }

                    HStack {
                        Text("End")
                        Spacer()
                        DatePicker("", selection: $item.endTime, displayedComponents: .date)
                            .labelsHidden()
                        DatePicker("", selection: $item.endTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
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
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
        }
        .onAppear {
            performLocationSearch()
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
}



// MARK: - Schedule Edit View


#Preview {
    ZStack {
        BackgroundView()
        ScheduleView(selectedDate: Date())
    }
}
