//
//  Frequency.swift
//  Planner
//
//  Created by Jessica Estes on 8/12/25.
//

import Foundation

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
    func shouldTrigger(on date: Date, from startDate: Date) -> Bool {
        let calendar = Calendar.current
        
        // Don't show events before the start date
        if date < calendar.startOfDay(for: startDate) {
            return false
        }
        
        switch self {
        case .never:
            return calendar.isDate(date, inSameDayAs: startDate)
            
        case .everyDay:
            return true
            
        case .everyWeek:
            // Check if it's the same day of the week as the start date
            let startWeekday = calendar.component(.weekday, from: startDate)
            let currentWeekday = calendar.component(.weekday, from: date)
            return startWeekday == currentWeekday
            
        case .everyTwoWeeks:
            // Check if it's the same day of the week and the correct week interval
            let startWeekday = calendar.component(.weekday, from: startDate)
            let currentWeekday = calendar.component(.weekday, from: date)
            if startWeekday != currentWeekday {
                return false
            }
            let weeksDifference = calendar.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear ?? 0
            return weeksDifference % 2 == 0
            
        case .everyMonth:
            // Check if it's the same day of the month as the start date
            let startDay = calendar.component(.day, from: startDate)
            let currentDay = calendar.component(.day, from: date)
            return startDay == currentDay
            
        case .everyYear:
            // Check if it's the same day and month as the start date
            let startComponents = calendar.dateComponents([.month, .day], from: startDate)
            let currentComponents = calendar.dateComponents([.month, .day], from: date)
            return startComponents.month == currentComponents.month && startComponents.day == currentComponents.day
            
        case .custom:
            // Custom logic would need to be implemented based on specific requirements
            return true
        }
    }
}
