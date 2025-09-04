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
        do {
            if let data = UserDefaults.standard.data(forKey: "SavedHabits") {
                let decoder = JSONDecoder()
                habits = try decoder.decode([Habit].self, from: data)
            }
        } catch {
            print("Failed to load habits: \(error)")
        }
    }
    
    // MARK: - CloudKit Integration Methods
    
    func mergeHabits(_ cloudHabits: [Habit]) async {
        // This method is called by CloudKitManager to merge cloud data
        // Merge logic: prefer cloud version if it exists, otherwise keep local
        await MainActor.run {
            var mergedHabits: [Habit] = []
            let cloudHabitIDs = Set(cloudHabits.map(\.id))
            
            // Add all cloud habits
            mergedHabits.append(contentsOf: cloudHabits)
            
            // Add local habits that don't exist in cloud
            for localHabit in habits {
                if !cloudHabitIDs.contains(localHabit.id) {
                    mergedHabits.append(localHabit)
                }
            }
            
            habits = mergedHabits
            saveHabits()
        }
    }
}
