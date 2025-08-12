//
//  Frequency.swift
//  Planner
//
//  Created by Jessica Estes on 8/12/25.
//

import Foundation

enum Frequency: String, CaseIterable, Identifiable {
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
        let components = calendar.dateComponents([.day, .weekOfYear, .month, .year], from: startDate, to: date)
        
        switch self {
        case .everyDay:
            return true
        case .everyWeek:
            return (components.weekOfYear ?? 0) >= 1
        case .everyTwoWeeks:
            return (components.weekOfYear ?? 0) >= 2
        case .everyMonth:
            return (components.month ?? 0) >= 1
        case .everyYear:
            return (components.year ?? 0) >= 1
        case .custom:
            // Custom logic would need to be implemented based on specific requirements
            return true
        }
    }
}