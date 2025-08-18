import SwiftUI
import Foundation

// MARK: - Item Type Enum
enum ItemType: String, CaseIterable, Codable {
    case todo = "todo"
    case scheduled = "scheduled"
    
    var displayName: String {
        switch self {
        case .todo: return "To Do"
        case .scheduled: return "Scheduled"
        }
    }
}

// MARK: - End Repeat Options
enum EndRepeatOption: String, CaseIterable, Identifiable, Codable {
    case never = "Never"
    case onDate = "On Date"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        return self.rawValue
    }
}



// MARK: - Checklist Item
struct ChecklistItem: Identifiable, Hashable, Codable {
    let id: UUID
    var text: String
    var isCompleted: Bool = false
    
    // Custom initializer
    init(text: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.text = text
        self.isCompleted = isCompleted
    }
    
    // Custom Codable implementation
    enum CodingKeys: String, CodingKey {
        case id, text, isCompleted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(isCompleted, forKey: .isCompleted)
    }
}

// MARK: - Updated ScheduleItem struct to handle both To-Do and Scheduled items
struct ScheduleItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var time: Date
    var icon: String
    var color: String
    var frequency: Frequency = .never
    var customFrequencyConfig: CustomFrequencyConfig? = nil
    var descriptionText: String = ""
    var location: String = ""
    var allDay: Bool = false
    var itemType: ItemType = .scheduled // New property to distinguish item types
    var isCompleted: Bool = false
    var startTime: Date = Date()
    var endTime: Date = Date()
    var checklist: [ChecklistItem] = []
    var uniqueKey: String = ""
    var category: Category?
    var endRepeatOption: EndRepeatOption = .never
    var endRepeatDate: Date = Date()
    var excludedDates: Set<Date> = []
    var hasDate: Bool = false // New property to track if todo has a date assigned
    
    // Legacy properties for compatibility
    var type: String {
        get { itemType.rawValue }
        set { itemType = ItemType(rawValue: newValue) ?? .scheduled }
    }
    
    // Computed properties for easier identification
    var isToDo: Bool {
        return itemType == .todo
    }
    
    var isScheduled: Bool {
        return itemType == .scheduled
    }
    
    // For to-do items, we check if they have a meaningful date/time assigned
    var hasScheduledTime: Bool {
        return itemType == .scheduled && frequency != .never
    }
    
    // New computed property to check if todo item should appear on schedule
    var isDatedToDo: Bool {
        return itemType == .todo && hasDate
    }
    
    // Computed property for AttributedString compatibility
    var description: AttributedString {
        get { AttributedString(descriptionText) }
        set { descriptionText = String(newValue.characters) }
    }
    
    // Convenience initializer for To-Do items
    static func createToDo(
        title: String,
        descriptionText: String = "",
        category: Category? = nil,
        checklist: [ChecklistItem] = [],
        hasDate: Bool = false,
        dueDate: Date? = nil
    ) -> ScheduleItem {
        let finalDate = dueDate ?? Date()
        return ScheduleItem(
            title: title,
            time: finalDate,
            icon: "checklist",
            color: category?.color ?? "Color1",
            frequency: .never,
            customFrequencyConfig: nil,
            descriptionText: descriptionText,
            location: "",
            allDay: true, // Todo items with dates are typically all-day
            itemType: .todo,
            isCompleted: false,
            startTime: finalDate,
            endTime: finalDate,
            checklist: checklist,
            uniqueKey: "todo-\(UUID().uuidString)",
            category: category,
            endRepeatOption: .never,
            endRepeatDate: finalDate,
            hasDate: hasDate
        )
    }
    
    // Convenience initializer for Scheduled items
    static func createScheduled(
        title: String,
        startTime: Date,
        endTime: Date? = nil,
        icon: String = "calendar",
        color: String = "Color1",
        frequency: Frequency = .never,
        customFrequencyConfig: CustomFrequencyConfig? = nil,
        descriptionText: String = "",
        location: String = "",
        allDay: Bool = false,
        checklist: [ChecklistItem] = [],
        category: Category? = nil,
        endRepeatOption: EndRepeatOption = .never,
        endRepeatDate: Date? = nil
    ) -> ScheduleItem {
        let finalEndTime = endTime ?? Calendar.current.date(byAdding: .hour, value: 1, to: startTime) ?? startTime
        let finalEndRepeatDate = endRepeatDate ?? Calendar.current.date(byAdding: .month, value: 1, to: startTime) ?? startTime
        
        return ScheduleItem(
            title: title,
            time: startTime,
            icon: icon,
            color: color,
            frequency: frequency,
            customFrequencyConfig: customFrequencyConfig,
            descriptionText: descriptionText,
            location: location,
            allDay: allDay,
            itemType: .scheduled,
            isCompleted: false,
            startTime: startTime,
            endTime: finalEndTime,
            checklist: checklist,
            uniqueKey: "scheduled-\(UUID().uuidString)",
            category: category,
            endRepeatOption: endRepeatOption,
            endRepeatDate: finalEndRepeatDate
        )
    }
    
    // Method to convert a to-do item to a scheduled item
    mutating func convertToScheduled(
        startTime: Date,
        endTime: Date? = nil,
        location: String = "",
        allDay: Bool = false,
        frequency: Frequency = .never,
        customFrequencyConfig: CustomFrequencyConfig? = nil,
        endRepeatOption: EndRepeatOption = .never,
        endRepeatDate: Date? = nil
    ) {
        let finalEndTime = endTime ?? Calendar.current.date(byAdding: .hour, value: 1, to: startTime) ?? startTime
        let finalEndRepeatDate = endRepeatDate ?? Calendar.current.date(byAdding: .month, value: 1, to: startTime) ?? startTime
        
        self.itemType = .scheduled
        self.time = startTime
        self.startTime = startTime
        self.endTime = finalEndTime
        self.location = location
        self.allDay = allDay
        self.frequency = frequency
        self.customFrequencyConfig = customFrequencyConfig
        self.endRepeatOption = endRepeatOption
        self.endRepeatDate = finalEndRepeatDate
        self.uniqueKey = "scheduled-\(self.id.uuidString)"
        self.hasDate = true // Scheduled items always have dates
        
        // Update icon to something more schedule-appropriate if it's still the default to-do icon
        if self.icon == "checklist" {
            self.icon = "calendar"
        }
    }
    
    // Method to convert a scheduled item back to a to-do item
    mutating func convertToToDo() {
        self.itemType = .todo
        self.frequency = .never
        self.customFrequencyConfig = nil
        self.location = ""
        self.allDay = true // Todo items are typically all-day
        self.endRepeatOption = .never
        self.uniqueKey = "todo-\(self.id.uuidString)"
        self.icon = "checklist"
        // Keep hasDate as true if it was scheduled, false if it was never dated
        
        // Keep the date information for todos - they might want to keep the date
        // self.hasDate remains as is
    }
    
    // Method to add/remove date from todo item
    mutating func setDate(_ date: Date?, allDay: Bool = true) {
        if let date = date {
            self.hasDate = true
            self.time = date
            self.startTime = date
            self.endTime = date
            self.allDay = allDay
        } else {
            self.hasDate = false
            // Reset to current time but mark as not having a date
            let now = Date()
            self.time = now
            self.startTime = now
            self.endTime = now
        }
    }
    
    // Initialize with all parameters (for Codable and internal use)
    init(
        title: String,
        time: Date,
        icon: String,
        color: String,
        frequency: Frequency = .never,
        customFrequencyConfig: CustomFrequencyConfig? = nil,
        descriptionText: String = "",
        location: String = "",
        allDay: Bool = false,
        itemType: ItemType = .scheduled,
        isCompleted: Bool = false,
        startTime: Date = Date(),
        endTime: Date = Date(),
        checklist: [ChecklistItem] = [],
        uniqueKey: String = "",
        category: Category? = nil,
        endRepeatOption: EndRepeatOption = .never,
        endRepeatDate: Date = Date(),
        hasDate: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.time = time
        self.icon = icon
        self.color = color
        self.frequency = frequency
        self.customFrequencyConfig = customFrequencyConfig
        self.descriptionText = descriptionText
        self.location = location
        self.allDay = allDay
        self.itemType = itemType
        self.isCompleted = isCompleted
        self.startTime = startTime
        self.endTime = endTime
        self.checklist = checklist
        self.uniqueKey = uniqueKey.isEmpty ? "\(itemType.rawValue)-\(UUID().uuidString)" : uniqueKey
        self.category = category
        self.endRepeatOption = endRepeatOption
        self.endRepeatDate = endRepeatDate
        self.hasDate = hasDate
    }
    
    // Codable implementation
    enum CodingKeys: String, CodingKey {
        case id, title, time, icon, color, frequency, customFrequencyConfig, descriptionText, location, allDay, itemType, type, isCompleted, startTime, endTime, checklist, uniqueKey, category, endRepeatOption, endRepeatDate, excludedDates, hasDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        time = try container.decode(Date.self, forKey: .time)
        icon = try container.decode(String.self, forKey: .icon)
        color = try container.decode(String.self, forKey: .color)
        frequency = try container.decode(Frequency.self, forKey: .frequency)
        customFrequencyConfig = try container.decodeIfPresent(CustomFrequencyConfig.self, forKey: .customFrequencyConfig)
        descriptionText = try container.decode(String.self, forKey: .descriptionText)
        location = try container.decode(String.self, forKey: .location)
        allDay = try container.decode(Bool.self, forKey: .allDay)
        
        // Handle both new itemType and legacy type properties
        if let itemTypeValue = try container.decodeIfPresent(ItemType.self, forKey: .itemType) {
            itemType = itemTypeValue
        } else if let typeValue = try container.decodeIfPresent(String.self, forKey: .type) {
            itemType = ItemType(rawValue: typeValue) ?? .scheduled
        } else {
            itemType = .scheduled // Default for backward compatibility
        }
        
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        checklist = try container.decode([ChecklistItem].self, forKey: .checklist)
        uniqueKey = try container.decode(String.self, forKey: .uniqueKey)
        category = try container.decodeIfPresent(Category.self, forKey: .category)
        endRepeatOption = try container.decode(EndRepeatOption.self, forKey: .endRepeatOption)
        endRepeatDate = try container.decode(Date.self, forKey: .endRepeatDate)
        excludedDates = try container.decodeIfPresent(Set<Date>.self, forKey: .excludedDates) ?? []
        hasDate = try container.decodeIfPresent(Bool.self, forKey: .hasDate) ?? (itemType == .scheduled) // Default based on type
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(time, forKey: .time)
        try container.encode(icon, forKey: .icon)
        try container.encode(color, forKey: .color)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(customFrequencyConfig, forKey: .customFrequencyConfig)
        try container.encode(descriptionText, forKey: .descriptionText)
        try container.encode(location, forKey: .location)
        try container.encode(allDay, forKey: .allDay)
        try container.encode(itemType, forKey: .itemType)
        try container.encode(itemType.rawValue, forKey: .type) // Keep legacy support
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(checklist, forKey: .checklist)
        try container.encode(uniqueKey, forKey: .uniqueKey)
        try container.encode(category, forKey: .category)
        try container.encode(endRepeatOption, forKey: .endRepeatOption)
        try container.encode(endRepeatDate, forKey: .endRepeatDate)
        try container.encode(excludedDates, forKey: .excludedDates)
        try container.encode(hasDate, forKey: .hasDate)
    }
    
    // Updated shouldAppear method - now includes dated todo items
    func shouldAppear(on date: Date) -> Bool {
        let calendar = Calendar.current
        let dateKey = calendar.startOfDay(for: date)
        
        // Check if this specific date is excluded
        if excludedDates.contains(dateKey) {
            return false
        }
        
        // For scheduled items, use the existing logic
        if itemType == .scheduled {
            // If frequency is never, only show on the exact date
            if frequency == .never {
                return calendar.isDate(startTime, inSameDayAs: date)
            }
            
            // Check if the event should trigger based on frequency (including custom config)
            let shouldTrigger = frequency.shouldTrigger(on: date, from: startTime, customConfig: customFrequencyConfig)
            
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
        
        // For todo items, only show if they have a date and it matches
        if itemType == .todo && hasDate {
            return calendar.isDate(startTime, inSameDayAs: date)
        }
        
        return false
    }
}

// MARK: - Helper Struct for Moving To-Do to Schedule
struct ScheduledInfo {
    let startTime: Date
    let endTime: Date?
    let location: String
    let allDay: Bool
    let frequency: Frequency
    let customFrequencyConfig: CustomFrequencyConfig?
    let endRepeatOption: EndRepeatOption
    let endRepeatDate: Date?
    let icon: String?
    
    init(
        startTime: Date,
        endTime: Date? = nil,
        location: String = "",
        allDay: Bool = false,
        frequency: Frequency = .never,
        customFrequencyConfig: CustomFrequencyConfig? = nil,
        endRepeatOption: EndRepeatOption = .never,
        endRepeatDate: Date? = nil,
        icon: String? = nil
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.allDay = allDay
        self.frequency = frequency
        self.customFrequencyConfig = customFrequencyConfig
        self.endRepeatOption = endRepeatOption
        self.endRepeatDate = endRepeatDate
        self.icon = icon
    }
}

// MARK: - Unified Data Manager for both Schedule and To-Do items
class UnifiedDataManager: ObservableObject {
    @Published var items: [ScheduleItem] = []
    
    static let shared = UnifiedDataManager()
    
    private init() {
        loadData()
        migrateExistingData()
    }
    
    // MARK: - Core Data Operations
    
    func addItem(_ item: ScheduleItem) {
        items.append(item)
        saveData()
    }
    
    func updateItem(_ item: ScheduleItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveData()
        }
    }
    
    func deleteItem(_ item: ScheduleItem) {
        items.removeAll { $0.id == item.id }
        saveData()
    }
    
    func deleteItem(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
        saveData()
    }
    
    func deleteItem(withId id: UUID) {
        items.removeAll { $0.id == id }
        saveData()
    }
    
    func getItem(by id: UUID) -> ScheduleItem? {
        return items.first { $0.id == id }
    }
    
    // MARK: - To-Do Specific Operations
    
    var toDoItems: [ScheduleItem] {
        return items.filter { $0.itemType == .todo }
    }
    
    func addToDoItem(
        title: String,
        descriptionText: String = "",
        category: Category? = nil,
        checklist: [ChecklistItem] = []
    ) {
        let item = ScheduleItem.createToDo(
            title: title,
            descriptionText: descriptionText,
            category: category,
            checklist: checklist
        )
        addItem(item)
    }
    
    func toggleToDoItem(at index: Int) {
        let toDoItems = self.toDoItems
        guard index < toDoItems.count else { return }
        
        let itemToToggle = toDoItems[index]
        if let actualIndex = items.firstIndex(where: { $0.id == itemToToggle.id }) {
            items[actualIndex].isCompleted.toggle()
            saveData()
        }
    }
    
    func clearCompletedToDoItems() {
        items.removeAll { $0.itemType == .todo && $0.isCompleted }
        saveData()
    }
    
    func moveToDoToSchedule(_ toDoItem: ScheduleItem, scheduledInfo: ScheduledInfo) {
        guard let index = items.firstIndex(where: { $0.id == toDoItem.id }) else { return }
        
        // Update the item to be scheduled
        items[index].convertToScheduled(
            startTime: scheduledInfo.startTime,
            endTime: scheduledInfo.endTime,
            location: scheduledInfo.location,
            allDay: scheduledInfo.allDay,
            frequency: scheduledInfo.frequency,
            customFrequencyConfig: scheduledInfo.customFrequencyConfig,
            endRepeatOption: scheduledInfo.endRepeatOption,
            endRepeatDate: scheduledInfo.endRepeatDate
        )
        
        // Update icon if provided
        if let icon = scheduledInfo.icon {
            items[index].icon = icon
        }
        
        saveData()
    }
    
    // MARK: - Schedule Specific Operations
    
    var scheduleItems: [ScheduleItem] {
        return items.filter { $0.itemType == .scheduled }
    }
    
    func getScheduleItemsForDate(_ date: Date) -> [ScheduleItem] {
        return scheduleItems.filter { item in
            item.shouldAppear(on: date)
        }
    }
    
    func addScheduleItem(
        title: String,
        startTime: Date,
        endTime: Date? = nil,
        icon: String = "calendar",
        color: String = "Color1",
        frequency: Frequency = .never,
        customFrequencyConfig: CustomFrequencyConfig? = nil,
        descriptionText: String = "",
        location: String = "",
        allDay: Bool = false,
        checklist: [ChecklistItem] = [],
        category: Category? = nil,
        endRepeatOption: EndRepeatOption = .never,
        endRepeatDate: Date? = nil
    ) {
        let item = ScheduleItem.createScheduled(
            title: title,
            startTime: startTime,
            endTime: endTime,
            icon: icon,
            color: color,
            frequency: frequency,
            customFrequencyConfig: customFrequencyConfig,
            descriptionText: descriptionText,
            location: location,
            allDay: allDay,
            checklist: checklist,
            category: category,
            endRepeatOption: endRepeatOption,
            endRepeatDate: endRepeatDate
        )
        addItem(item)
    }
    
    func getOrCreateScheduleItem(
        uniqueKey: String,
        title: String,
        time: Date,
        icon: String,
        color: String,
        frequency: Frequency,
        startTime: Date
    ) -> ScheduleItem {
        // Check if we already have this item by unique key
        if let existingItem = scheduleItems.first(where: { item in
            return item.uniqueKey == uniqueKey
        }) {
            return existingItem
        }
        
        // Create new scheduled item with default checklist
        let defaultChecklist = getDefaultChecklist(for: title)
        let newItem = ScheduleItem.createScheduled(
            title: title,
            startTime: startTime,
            endTime: Calendar.current.date(byAdding: .hour, value: 1, to: startTime) ?? startTime,
            icon: icon,
            color: color,
            frequency: frequency,
            checklist: defaultChecklist
        )
        
        addItem(newItem)
        return newItem
    }
    
    // Legacy method for backward compatibility
    func addOrUpdateItem(_ item: ScheduleItem) {
        updateItem(item)
    }
    
    // MARK: - Recurring Event Operations
    
    func excludeDateFromRecurring(item: ScheduleItem, excludeDate: Date) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            let calendar = Calendar.current
            let dateKey = calendar.startOfDay(for: excludeDate)
            items[index].excludedDates.insert(dateKey)
            saveData()
        }
    }
    
    // MARK: - Category Filtering
    
    func getToDoItems(for category: Category?) -> [ScheduleItem] {
        let todos = toDoItems
        if let category = category {
            return todos.filter { $0.category?.id == category.id }
        }
        return todos
    }
    
    func getScheduleItems(for category: Category?) -> [ScheduleItem] {
        let scheduled = scheduleItems
        if let category = category {
            return scheduled.filter { $0.category?.id == category.id }
        }
        return scheduled
    }
    
    // MARK: - Migration and Data Management
    
    private func migrateExistingData() {
        // Migrate any existing data from the old separate data managers
        migrateFromOldToDoManager()
        migrateFromOldScheduleManager()
    }
    
    private func migrateFromOldToDoManager() {
        // Check if there's old to-do data
        if let data = UserDefaults.standard.data(forKey: "ToDoScheduleItems") {
            do {
                let decoder = JSONDecoder()
                let oldToDoItems = try decoder.decode([ScheduleItem].self, from: data)
                
                // Convert old items to to-do items if they aren't already marked correctly
                for var oldItem in oldToDoItems {
                    // Check if this item is likely a to-do (frequency is never and has basic structure)
                    if oldItem.frequency == .never && oldItem.itemType != .scheduled {
                        oldItem.itemType = .todo
                        oldItem.uniqueKey = "todo-\(oldItem.id.uuidString)"
                        oldItem.icon = "checklist"
                        
                        // Only add if we don't already have this item
                        if !items.contains(where: { $0.id == oldItem.id }) {
                            items.append(oldItem)
                        }
                    }
                }
                
                // Remove the old data
                UserDefaults.standard.removeObject(forKey: "ToDoScheduleItems")
                saveData()
            } catch {
                print("Failed to migrate old to-do data: \(error)")
            }
        }
    }
    
    private func migrateFromOldScheduleManager() {
        // Check if there's old schedule data
        if let data = UserDefaults.standard.data(forKey: "ScheduleItems") {
            do {
                let decoder = JSONDecoder()
                let oldScheduleItems = try decoder.decode([ScheduleItem].self, from: data)
                
                for var oldItem in oldScheduleItems {
                    // Ensure old schedule items are marked correctly
                    if oldItem.itemType != .todo {
                        oldItem.itemType = .scheduled
                        if oldItem.uniqueKey.isEmpty {
                            oldItem.uniqueKey = "scheduled-\(oldItem.id.uuidString)"
                        }
                        
                        // Only add if we don't already have this item
                        if !items.contains(where: { $0.id == oldItem.id }) {
                            items.append(oldItem)
                        }
                    }
                }
                
                saveData()
            } catch {
                print("Failed to migrate old schedule data: \(error)")
            }
        }
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
            let data = try encoder.encode(items)
            UserDefaults.standard.set(data, forKey: "UnifiedItems")
        } catch {
            print("Failed to save unified items: \(error)")
        }
    }
    
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: "UnifiedItems") else { return }
        
        do {
            let decoder = JSONDecoder()
            items = try decoder.decode([ScheduleItem].self, from: data)
        } catch {
            print("Failed to load unified items: \(error)")
            items = []
        }
    }
}

// MARK: - Legacy Support - Keep ScheduleDataManager as an alias
typealias ScheduleDataManager = UnifiedDataManager
