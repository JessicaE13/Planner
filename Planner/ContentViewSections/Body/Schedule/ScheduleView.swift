//
//  ScheduleView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI


struct ScheduleItem: Identifiable, Codable {
    var id: UUID = UUID()
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
    @State private var presentedItem: ScheduleItem?
    @State private var editingItem: ScheduleItem?
    @State private var scheduleItems: [ScheduleItem] = []
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        _scheduleItems = State(initialValue: ScheduleView.loadScheduleItems())
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Schedule")
                    .sectionHeaderStyle()
                
                Spacer()
                
                Button(action: {
                    let newItem = ScheduleItem(title: "New Event", time: Date(), icon: "calendar", color: "Color1", isRepeating: false)
                    editingItem = newItem
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .contentShape(Rectangle())
                }
            }
            .padding(.bottom, 16)
            
            VStack {
                ForEach(scheduleItems) { item in
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(item.color))
                                .frame(width: 50, height: 75)
                            Image(systemName: item.icon)
                        }
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.body)
                            Text(item.location)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if item.isRepeating {
                            Image(systemName: "repeat")
                                .foregroundColor(Color.gray.opacity(0.6))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingItem = item
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .sheet(item: $presentedItem) { item in
            ScheduleDetailView(item: item, editingItem: $editingItem)
        }
        .sheet(item: $editingItem) { item in
            ScheduleEditView(item: item) { updatedItem in
                if let idx = scheduleItems.firstIndex(where: { $0.id == updatedItem.id }) {
                    scheduleItems[idx] = updatedItem
                } else {
                    scheduleItems.append(updatedItem)
                }
                saveScheduleItems()
                editingItem = nil
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
    
    private static func loadScheduleItems() -> [ScheduleItem] {
        if let data = UserDefaults.standard.data(forKey: "scheduleItems") {
            let decoder = JSONDecoder()
            if let items = try? decoder.decode([ScheduleItem].self, from: data) {
                return items
            }
        }
        return []
    }
    private func saveScheduleItems() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(scheduleItems) {
            UserDefaults.standard.set(data, forKey: "scheduleItems")
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
