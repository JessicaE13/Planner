//
//  Frequency.swift
//  Planner
//
//  Created by Jessica Estes on 8/12/25.
//

import Foundation

// MARK: - Custom Frequency Types
enum CustomFrequencyType: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Custom Frequency Configuration
struct CustomFrequencyConfig: Codable, Equatable {
    var type: CustomFrequencyType = .daily
    var interval: Int = 1 // Every X days/weeks/months/years
    
    // For weekly: which days of the week (1=Sunday, 7=Saturday)
    var selectedWeekdays: Set<Int> = []
    
    // For monthly: which days of the month (1-31)
    var selectedMonthDays: Set<Int> = []
    
    // For yearly: which months (1-12)
    var selectedMonths: Set<Int> = []
    
    init(type: CustomFrequencyType = .daily, interval: Int = 1) {
        self.type = type
        self.interval = interval
        
        // Set default selections based on type
        switch type {
        case .daily:
            break // No additional selections needed
        case .weekly:
            selectedWeekdays = [Calendar.current.component(.weekday, from: Date())] // Current day
        case .monthly:
            selectedMonthDays = [Calendar.current.component(.day, from: Date())] // Current day
        case .yearly:
            selectedMonths = [Calendar.current.component(.month, from: Date())] // Current month
        }
    }
    
    func displayDescription() -> String {
        switch type {
        case .daily:
            return interval == 1 ? "Every day" : "Every \(interval) days"
        case .weekly:
            let dayNames = selectedWeekdays.sorted().compactMap { dayNumber in
                Calendar.current.shortWeekdaySymbols[dayNumber - 1]
            }
            let weekText = interval == 1 ? "Every week" : "Every \(interval) weeks"
            return "\(weekText) on \(dayNames.joined(separator: ", "))"
        case .monthly:
            let days = selectedMonthDays.sorted().map { "\($0)" }
            let monthText = interval == 1 ? "Every month" : "Every \(interval) months"
            return "\(monthText) on day(s) \(days.joined(separator: ", "))"
        case .yearly:
            let monthNames = selectedMonths.sorted().compactMap { monthNumber in
                Calendar.current.monthSymbols[monthNumber - 1]
            }
            let yearText = interval == 1 ? "Every year" : "Every \(interval) years"
            return "\(yearText) in \(monthNames.joined(separator: ", "))"
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

enum Frequency: String, CaseIterable, Identifiable, Codable {
    case never = "Never"
    case everyDay = "Every Day"
    case everyWeek = "Every Week"
    case everyTwoWeeks = "Every 2 Weeks"
    case everyMonth = "Every Month"
    case everyYear = "Every Year"
    case custom = "Custom"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        return self.rawValue
    }
    
    // Helper method to check if a date should trigger this frequency
    func shouldTrigger(on date: Date, from startDate: Date, customConfig: CustomFrequencyConfig? = nil) -> Bool {
        let calendar = Calendar.current
        
        let startOfDay = calendar.startOfDay(for: date)
        let startOfStartDate = calendar.startOfDay(for: startDate)
        
        if startOfDay < startOfStartDate {
            return false
        }
        
        switch self {
        case .never:
            return calendar.isDate(date, inSameDayAs: startDate)
            
        case .everyDay:
            return true
            
        case .everyWeek:
            let startWeekday = calendar.component(.weekday, from: startDate)
            let currentWeekday = calendar.component(.weekday, from: date)
            return startWeekday == currentWeekday
            
        case .everyTwoWeeks:
            let startWeekday = calendar.component(.weekday, from: startDate)
            let currentWeekday = calendar.component(.weekday, from: date)
            if startWeekday != currentWeekday {
                return false
            }
            let weeksDifference = calendar.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear ?? 0
            return weeksDifference % 2 == 0
            
        case .everyMonth:
            let startDay = calendar.component(.day, from: startDate)
            let currentDay = calendar.component(.day, from: date)
            return startDay == currentDay
            
        case .everyYear:
            let startComponents = calendar.dateComponents([.month, .day], from: startDate)
            let currentComponents = calendar.dateComponents([.month, .day], from: date)
            return startComponents.month == currentComponents.month && startComponents.day == currentComponents.day
            
        case .custom:
            guard let config = customConfig else { return false }
            return shouldTriggerCustom(on: date, from: startDate, config: config)
        }
    }
    
    private func shouldTriggerCustom(on date: Date, from startDate: Date, config: CustomFrequencyConfig) -> Bool {
        let calendar = Calendar.current
        
        switch config.type {
        case .daily:
            let daysDifference = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
            return daysDifference >= 0 && daysDifference % config.interval == 0
            
        case .weekly:
            let currentWeekday = calendar.component(.weekday, from: date)
            guard config.selectedWeekdays.contains(currentWeekday) else { return false }
            
            let weeksDifference = calendar.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear ?? 0
            return weeksDifference >= 0 && weeksDifference % config.interval == 0
            
        case .monthly:
            let currentDay = calendar.component(.day, from: date)
            guard config.selectedMonthDays.contains(currentDay) else { return false }
            
            let monthsDifference = calendar.dateComponents([.month], from: startDate, to: date).month ?? 0
            return monthsDifference >= 0 && monthsDifference % config.interval == 0
            
        case .yearly:
            let currentMonth = calendar.component(.month, from: date)
            guard config.selectedMonths.contains(currentMonth) else { return false }
            
            let yearsDifference = calendar.dateComponents([.year], from: startDate, to: date).year ?? 0
            return yearsDifference >= 0 && yearsDifference % config.interval == 0
        }
    }
}
