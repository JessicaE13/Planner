//
//  HabitModel.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct Habit: Identifiable, Codable {
    let id: UUID // Back to let - immutable as it should be
    var name: String
    var frequency: Frequency = .everyDay
    var completion: [String: Bool] // date string (yyyy-MM-dd) to completion status
    
    // Add start and end date properties
    var startDate: Date = Date()
    var endRepeatOption: EndRepeatOption = .never
    var endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    // Add custom frequency configuration
    var customFrequencyConfig: CustomFrequencyConfig?
    
    // Custom initializer for creating new habits
    init(name: String, frequency: Frequency = .everyDay, completion: [String: Bool] = [:], startDate: Date = Date(), endRepeatOption: EndRepeatOption = .never, endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(), customFrequencyConfig: CustomFrequencyConfig? = nil) {
        self.id = UUID()
        self.name = name
        self.frequency = frequency
        self.completion = completion
        self.startDate = startDate
        self.endRepeatOption = endRepeatOption
        self.endRepeatDate = endRepeatDate
        self.customFrequencyConfig = customFrequencyConfig
    }
    
    // Custom Codable implementation
    enum CodingKeys: String, CodingKey {
        case id, name, frequency, completion, startDate, endRepeatOption, endRepeatDate, customFrequencyConfig
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        frequency = try container.decode(Frequency.self, forKey: .frequency)
        completion = try container.decode([String: Bool].self, forKey: .completion)
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        endRepeatOption = try container.decodeIfPresent(EndRepeatOption.self, forKey: .endRepeatOption) ?? .never
        endRepeatDate = try container.decodeIfPresent(Date.self, forKey: .endRepeatDate) ?? Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        customFrequencyConfig = try container.decodeIfPresent(CustomFrequencyConfig.self, forKey: .customFrequencyConfig)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(completion, forKey: .completion)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endRepeatOption, forKey: .endRepeatOption)
        try container.encode(endRepeatDate, forKey: .endRepeatDate)
        try container.encodeIfPresent(customFrequencyConfig, forKey: .customFrequencyConfig)
    }
    
    func isCompleted(for date: Date) -> Bool {
        let key = Habit.dateKey(for: date)
        return completion[key] ?? false
    }
    
    mutating func toggle(for date: Date) {
        let key = Habit.dateKey(for: date)
        completion[key] = !(completion[key] ?? false)
    }
    
    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func shouldAppear(on date: Date) -> Bool {
        // If frequency is never, only show on the exact start date
        if frequency == .never {
            return Calendar.current.isDate(startDate, inSameDayAs: date)
        }
        
        // Check if the habit should trigger based on frequency from start date
        let shouldTrigger = frequency.shouldTrigger(on: date, from: startDate, customConfig: customFrequencyConfig)
        
        // If it shouldn't trigger based on frequency, don't show
        if !shouldTrigger {
            return false
        }
        
        // Check end repeat conditions
        if endRepeatOption == .onDate {
            return date <= endRepeatDate
        }
        
        // If endRepeatOption is .never, show indefinitely (as long as frequency matches)
        return true
    }
}
