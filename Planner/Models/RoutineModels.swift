import SwiftUI

struct RoutineItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var frequency: Frequency = .everyDay
    var customFrequencyConfig: CustomFrequencyConfig? = nil
    var endRepeatOption: EndRepeatOption = .never
    var endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    init(name: String, frequency: Frequency = .everyDay, customFrequencyConfig: CustomFrequencyConfig? = nil, endRepeatOption: EndRepeatOption = .never, endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()) {
        self.name = name
        self.frequency = frequency
        self.customFrequencyConfig = customFrequencyConfig
        self.endRepeatOption = endRepeatOption
        self.endRepeatDate = endRepeatDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, frequency, customFrequencyConfig, endRepeatOption, endRepeatDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        frequency = try container.decodeIfPresent(Frequency.self, forKey: .frequency) ?? .everyDay
        customFrequencyConfig = try container.decodeIfPresent(CustomFrequencyConfig.self, forKey: .customFrequencyConfig)
        endRepeatOption = try container.decodeIfPresent(EndRepeatOption.self, forKey: .endRepeatOption) ?? .never
        endRepeatDate = try container.decodeIfPresent(Date.self, forKey: .endRepeatDate) ?? Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(customFrequencyConfig, forKey: .customFrequencyConfig)
        try container.encode(endRepeatOption, forKey: .endRepeatOption)
        try container.encode(endRepeatDate, forKey: .endRepeatDate)
    }
    
    func shouldAppear(on date: Date, routineStartDate: Date) -> Bool {
        if frequency == .never {
            return Calendar.current.isDate(routineStartDate, inSameDayAs: date)
        }
        let shouldTrigger = frequency.shouldTrigger(on: date, from: routineStartDate, customConfig: customFrequencyConfig)
        if !shouldTrigger {
            return false
        }
        if endRepeatOption == .onDate {
            return date <= endRepeatDate
        }
        return true
    }
}

struct Routine: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var icon: String
    var routineItems: [RoutineItem] = []
    var items: [String] = []
    var iconName: String {
        return icon
    }
    var colorName: String = "Color1"
    var color: Color {
        return Color(colorName)
    }
    
    var completedItemsByDate: [String: Set<String>] = [:]
    
    var frequency: Frequency = .everyDay
    var customFrequencyConfig: CustomFrequencyConfig? = nil
    var endRepeatOption: EndRepeatOption = .never
    var endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    var startDate: Date = Date()
    var createdDate: Date = Date()
    
    init(name: String, icon: String, routineItems: [RoutineItem] = [], items: [String] = [], colorName: String = "Color1", frequency: Frequency = .everyDay, customFrequencyConfig: CustomFrequencyConfig? = nil, endRepeatOption: EndRepeatOption = .never, endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(), startDate: Date = Date()) {
        self.name = name
        self.icon = icon
        self.routineItems = routineItems
        self.items = items
        self.colorName = colorName
        self.frequency = frequency
        self.customFrequencyConfig = customFrequencyConfig
        self.endRepeatOption = endRepeatOption
        self.endRepeatDate = endRepeatDate
        self.startDate = startDate
        self.createdDate = Date()
        
        if routineItems.isEmpty && !items.isEmpty {
            self.routineItems = items.map { RoutineItem(name: $0, frequency: .everyDay) }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, routineItems, items, completedItemsByDate, frequency, customFrequencyConfig, endRepeatOption, endRepeatDate, startDate, colorName, createdDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        routineItems = try container.decodeIfPresent([RoutineItem].self, forKey: .routineItems) ?? []
        items = try container.decodeIfPresent([String].self, forKey: .items) ?? []
        completedItemsByDate = try container.decodeIfPresent([String: Set<String>].self, forKey: .completedItemsByDate) ?? [:]
        frequency = try container.decodeIfPresent(Frequency.self, forKey: .frequency) ?? .everyDay
        customFrequencyConfig = try container.decodeIfPresent(CustomFrequencyConfig.self, forKey: .customFrequencyConfig)
        endRepeatOption = try container.decodeIfPresent(EndRepeatOption.self, forKey: .endRepeatOption) ?? .never
        endRepeatDate = try container.decodeIfPresent(Date.self, forKey: .endRepeatDate) ?? Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        colorName = try container.decodeIfPresent(String.self, forKey: .colorName) ?? "Color1"
        createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
        if routineItems.isEmpty && !items.isEmpty {
            routineItems = items.map { RoutineItem(name: $0, frequency: .everyDay) }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(routineItems, forKey: .routineItems)
        try container.encode(items, forKey: .items)
        try container.encode(completedItemsByDate, forKey: .completedItemsByDate)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(customFrequencyConfig, forKey: .customFrequencyConfig)
        try container.encode(endRepeatOption, forKey: .endRepeatOption)
        try container.encode(endRepeatDate, forKey: .endRepeatDate)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(colorName, forKey: .colorName)
        try container.encode(createdDate, forKey: .createdDate)
    }
    
    // Thread-safe DateFormatter using static lazy initialization
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private func dateKey(for date: Date) -> String {
        return Self.dateFormatter.string(from: date)
    }
    
    func completedItems(for date: Date) -> Set<String> {
        let key = dateKey(for: date)
        return completedItemsByDate[key] ?? []
    }
    
    func visibleItems(for date: Date) -> [RoutineItem] {
        return routineItems.filter { item in
            item.shouldAppear(on: date, routineStartDate: startDate)
        }
    }
    
    func progress(for date: Date) -> Double {
        let visibleItems = self.visibleItems(for: date)
        guard !visibleItems.isEmpty else { return 0 }
        let completed = completedItems(for: date)
        let visibleItemNames = Set(visibleItems.map { $0.name })
        let completedVisibleItems = completed.intersection(visibleItemNames)
        return Double(completedVisibleItems.count) / Double(visibleItems.count)
    }
    
    mutating func toggleItem(_ itemName: String, for date: Date) {
        let key = dateKey(for: date)
        var completedForDate = completedItemsByDate[key] ?? []
        if completedForDate.contains(itemName) {
            completedForDate.remove(itemName)
        } else {
            completedForDate.insert(itemName)
        }
        completedItemsByDate[key] = completedForDate
    }
    
    func isItemCompleted(_ itemName: String, for date: Date) -> Bool {
        let completed = completedItems(for: date)
        return completed.contains(itemName)
    }
    
    func shouldAppear(on date: Date) -> Bool {
        let shouldTrigger = frequency.shouldTrigger(on: date, from: startDate, customConfig: customFrequencyConfig)
        if !shouldTrigger {
            return false
        }
        if endRepeatOption == .onDate {
            return date <= endRepeatDate
        }
        return true
    }
}
