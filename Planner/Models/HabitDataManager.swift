//
//  HabitDataManager.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

// MARK: - Habit Data Manager
class HabitDataManager: ObservableObject {
    @Published var habits: [Habit] = []
    
    static let shared = HabitDataManager()
    
    private init() {
        loadHabits()
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }
    
    func deleteHabit(at index: Int) {
        guard index < habits.count else { return }
        habits.remove(at: index)
        saveHabits()
    }
    
    func toggleHabit(at index: Int, for date: Date) {
        guard index < habits.count else { return }
        habits[index].toggle(for: date)
        saveHabits()
    }
    
    private func saveHabits() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(habits)
            UserDefaults.standard.set(data, forKey: "SavedHabits")
        } catch {
            print("Failed to save habits: \(error)")
        }
    }
    
    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: "SavedHabits") else {
            // Load default habits if no saved data exists
            loadDefaultHabits()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            habits = try decoder.decode([Habit].self, from: data)
            
            // Migrate existing habits that might have today's date as start date
            migrateExistingHabits()
        } catch {
            print("Failed to load habits: \(error)")
            loadDefaultHabits()
        }
    }
    
    private func migrateExistingHabits() {
        let today = Date()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? today
        var needsUpdate = false
        
        for index in habits.indices {
            // If the habit's start date is today (indicating it's an old habit), update it
            if Calendar.current.isDate(habits[index].startDate, inSameDayAs: today) {
                habits[index].startDate = weekAgo
                needsUpdate = true
            }
        }
        
        if needsUpdate {
            saveHabits()
        }
    }
    
    private func loadDefaultHabits() {
        // Set start date to a week ago so habits show up in past days
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        habits = [
            Habit(name: "Drink Water", frequency: .everyDay, startDate: weekAgo),
            Habit(name: "Exercise", frequency: .everyDay, startDate: weekAgo),
            Habit(name: "Read", frequency: .everyDay, startDate: weekAgo),
            Habit(name: "Meditate", frequency: .everyDay, startDate: weekAgo),
            Habit(name: "Journal", frequency: .everyDay, startDate: weekAgo)
        ]
        saveHabits()
    }
}