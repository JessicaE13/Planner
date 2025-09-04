import Foundation
import SwiftUI

@MainActor
class PlannerDataManager: ObservableObject {
    static let shared = PlannerDataManager()
    
    @Published var routines: [Routine] = []
    @Published var habits: [Habit] = []
    
    private let cloudKitManager = CloudKitManager.shared
    private let userDefaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private let routinesKey = "SavedRoutines"
    private let habitsKey = "SavedHabits"
    private let lastSyncKey = "LastSyncDate"
    
    private init() {
        loadLocalData()
        observeCloudKitStatus()
    }
    
    // MARK: - Local Data Management
    
    private func loadLocalData() {
        // Load routines
        if let routinesData = userDefaults.data(forKey: routinesKey),
           let decodedRoutines = try? JSONDecoder().decode([Routine].self, from: routinesData) {
            routines = decodedRoutines
        }
        
        // Load habits
        if let habitsData = userDefaults.data(forKey: habitsKey),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: habitsData) {
            habits = decodedHabits
        }
    }
    
    private func saveLocalData() {
        // Save routines
        if let routinesData = try? JSONEncoder().encode(routines) {
            userDefaults.set(routinesData, forKey: routinesKey)
        }
        
        // Save habits
        if let habitsData = try? JSONEncoder().encode(habits) {
            userDefaults.set(habitsData, forKey: habitsKey)
        }
        
        userDefaults.synchronize()
    }
    
    // MARK: - CloudKit Integration
    
    private func observeCloudKitStatus() {
        // Observe CloudKit sync status changes
        Task {
            for await _ in NotificationCenter.default.notifications(named: .CKAccountChanged) {
                await performInitialSync()
            }
        }
    }
    
    func performInitialSync() async {
        do {
            let cloudData = try await cloudKitManager.fetchAllData()
            
            // Merge cloud data with local data
            await mergeData(cloudRoutines: cloudData.routines, cloudHabits: cloudData.habits)
            
            // Save merged data locally
            saveLocalData()
            
            // Sync any local-only data to cloud
            await syncLocalDataToCloud()
            
        } catch {
            print("Initial sync failed: \(error)")
        }
    }
    
    private func mergeData(cloudRoutines: [Routine], cloudHabits: [Habit]) async {
        // Merge routines (prefer cloud version if it exists, otherwise keep local)
        var mergedRoutines: [Routine] = []
        let cloudRoutineIDs = Set(cloudRoutines.map(\.id))
        
        // Add all cloud routines
        mergedRoutines.append(contentsOf: cloudRoutines)
        
        // Add local routines that don't exist in cloud
        for localRoutine in routines {
            if !cloudRoutineIDs.contains(localRoutine.id) {
                mergedRoutines.append(localRoutine)
            }
        }
        
        // Merge habits
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
        
        routines = mergedRoutines
        habits = mergedHabits
    }
    
    private func syncLocalDataToCloud() async {
        do {
            // Sync all local routines to cloud
            for routine in routines {
                try await cloudKitManager.saveRoutine(routine)
            }
            
            // Sync all local habits to cloud
            for habit in habits {
                try await cloudKitManager.saveHabit(habit)
            }
            
            // Update last sync date
            userDefaults.set(Date(), forKey: lastSyncKey)
        } catch {
            print("Failed to sync local data to cloud: \(error)")
        }
    }
    
    // MARK: - Routine Management
    
    func addRoutine(_ routine: Routine) {
        routines.append(routine)
        saveLocalData()
        
        // Sync to cloud if available
        Task {
            if cloudKitManager.isSignedInToiCloud {
                try? await cloudKitManager.saveRoutine(routine)
            }
        }
    }
    
    func updateRoutine(_ routine: Routine) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index] = routine
            saveLocalData()
            
            // Sync to cloud if available
            Task {
                if cloudKitManager.isSignedInToiCloud {
                    try? await cloudKitManager.saveRoutine(routine)
                }
            }
        }
    }
    
    func deleteRoutine(at index: Int) {
        guard index < routines.count else { return }
        let routine = routines[index]
        routines.remove(at: index)
        saveLocalData()
        
        // Delete from cloud if available
        Task {
            if cloudKitManager.isSignedInToiCloud {
                try? await cloudKitManager.deleteRoutine(withId: routine.id)
            }
        }
    }
    
    func deleteRoutine(withId id: UUID) {
        if let index = routines.firstIndex(where: { $0.id == id }) {
            deleteRoutine(at: index)
        }
    }
    
    // MARK: - Habit Management
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveLocalData()
        
        // Sync to cloud if available
        Task {
            if cloudKitManager.isSignedInToiCloud {
                try? await cloudKitManager.saveHabit(habit)
            }
        }
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveLocalData()
            
            // Sync to cloud if available
            Task {
                if cloudKitManager.isSignedInToiCloud {
                    try? await cloudKitManager.saveHabit(habit)
                }
            }
        }
    }
    
    func deleteHabit(at index: Int) {
        guard index < habits.count else { return }
        let habit = habits[index]
        habits.remove(at: index)
        saveLocalData()
        
        // Delete from cloud if available
        Task {
            if cloudKitManager.isSignedInToiCloud {
                try? await cloudKitManager.deleteHabit(withId: habit.id)
            }
        }
    }
    
    func deleteHabit(withId id: UUID) {
        if let index = habits.firstIndex(where: { $0.id == id }) {
            deleteHabit(at: index)
        }
    }
    
    func toggleHabit(at index: Int, for date: Date) {
        guard index < habits.count else { return }
        habits[index].toggle(for: date)
        saveLocalData()
        
        // Sync to cloud if available
        Task {
            if cloudKitManager.isSignedInToiCloud {
                try? await cloudKitManager.saveHabit(habits[index])
            }
        }
    }
    
    // MARK: - CloudKit Merge Methods (called by CloudKitManager)
    
    func mergeRoutines(_ cloudRoutines: [Routine]) async {
        await mergeData(cloudRoutines: cloudRoutines, cloudHabits: habits)
        saveLocalData()
    }
    
    func mergeHabits(_ cloudHabits: [Habit]) async {
        await mergeData(cloudRoutines: routines, cloudHabits: cloudHabits)
        saveLocalData()
    }
    
    func mergeScheduleItems(_ cloudScheduleItems: [ScheduleItem]) async {
        // For now, this is a placeholder since PlannerDataManager doesn't manage schedule items
        // This prevents the CloudKitManager compilation error
        print("Schedule items merge not yet implemented in PlannerDataManager")
    }
}
