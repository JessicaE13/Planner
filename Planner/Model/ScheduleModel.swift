import SwiftUI
import Foundation

// MARK: - End Repeat Options
enum EndRepeatOption: String, CaseIterable, Identifiable, Codable {
    case never = "Never"
    case onDate = "On Date"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Schedule Data Manager
class ScheduleDataManager: ObservableObject {
    @Published var scheduleItems: [ScheduleItem] = []
    
    static let shared = ScheduleDataManager()
    
    private init() {
        loadData()
    }
    
    // MARK: - Core Data Operations
    
    func addOrUpdateItem(_ item: ScheduleItem) {
        if let index = scheduleItems.firstIndex(where: { $0.id == item.id }) {
            scheduleItems[index] = item
        } else {
            scheduleItems.append(item)
        }
        saveData()
    }
    
    func getItem(by id: UUID) -> ScheduleItem? {
        return scheduleItems.first { $0.id == id }
    }
    
    func getOrCreateItem(
        uniqueKey: String,
        title: String,
        time: Date,
        icon: String,
        color: String,
        frequency: Frequency,
        startTime: Date
    ) -> ScheduleItem {
        // Check if we already have this item by unique key (using a more specific match)
        if let existingItem = scheduleItems.first(where: { item in
            return item.uniqueKey == uniqueKey
        }) {
            return existingItem
        }
        
        // Create new item with default checklist
        let defaultChecklist = getDefaultChecklist(for: title)
        let newItem = ScheduleItem(
            title: title,
            time: time,
            icon: icon,
            color: color,
            frequency: frequency,
            startTime: startTime,
            endTime: Calendar.current.date(byAdding: .hour, value: 1, to: startTime) ?? startTime,
            checklist: defaultChecklist,
            uniqueKey: uniqueKey
        )
        
        scheduleItems.append(newItem)
        saveData()
        return newItem
    }
    
    func deleteItem(_ item: ScheduleItem) {
        scheduleItems.removeAll { $0.id == item.id }
        saveData()
    }
    
    // MARK: - Default Checklists
    
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
    
    // MARK: - Persistence
    
    private func saveData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(scheduleItems)
            UserDefaults.standard.set(data, forKey: "ScheduleItems")
        } catch {
            print("Failed to save schedule items: \(error)")
        }
    }
    
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: "ScheduleItems") else { return }
        
        do {
            let decoder = JSONDecoder()
            scheduleItems = try decoder.decode([ScheduleItem].self, from: data)
        } catch {
            print("Failed to load schedule items: \(error)")
            scheduleItems = []
        }
    }
}

// MARK: - Updated Models for Codable Support

struct ChecklistItem: Identifiable, Hashable, Codable {
    let id = UUID()
    var text: String
    var isCompleted: Bool = false
}

struct ScheduleItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var time: Date
    var icon: String
    var color: String
    var frequency: Frequency = .never
    var descriptionText: String = "" // Changed from AttributedString for Codable
    var location: String = ""
    var allDay: Bool = false
    var category: String = ""
    var type: String = "Schedule"
    var isCompleted: Bool = false
    var startTime: Date = Date()
    var endTime: Date = Date()
    var checklist: [ChecklistItem] = []
    var uniqueKey: String = "" // Added unique key for better identification
    
    // New properties for end repeat functionality
    var endRepeatOption: EndRepeatOption = .never
    var endRepeatDate: Date = Date()
    
    // Computed property for AttributedString compatibility
    var description: AttributedString {
        get { AttributedString(descriptionText) }
        set { descriptionText = String(newValue.characters) }
    }
    
    // Initialize with uniqueKey and end repeat options
    init(title: String, time: Date, icon: String, color: String, frequency: Frequency = .never, startTime: Date, endTime: Date, checklist: [ChecklistItem] = [], uniqueKey: String = "", endRepeatOption: EndRepeatOption = .never, endRepeatDate: Date = Date()) {
        self.title = title
        self.time = time
        self.icon = icon
        self.color = color
        self.frequency = frequency
        self.startTime = startTime
        self.endTime = endTime
        self.checklist = checklist
        self.uniqueKey = uniqueKey
        self.endRepeatOption = endRepeatOption
        self.endRepeatDate = endRepeatDate
    }
    
    // Helper method to check if this event should appear on a given date
    func shouldAppear(on date: Date) -> Bool {
        // If frequency is never, only show on the exact date
        if frequency == .never {
            return Calendar.current.isDate(startTime, inSameDayAs: date)
        }
        
        // Check if the event should trigger based on frequency
        let shouldTrigger = frequency.shouldTrigger(on: date, from: startTime)
        
        // If it shouldn't trigger based on frequency, don't show
        if !shouldTrigger {
            return false
        }
        
        // Check end repeat conditions
        if endRepeatOption == .onDate {
            return date <= endRepeatDate
        }
        
        // If endRepeatOption is .never, show indefinitely
        return true
    }
}
