import Foundation
import CloudKit
import SwiftUI

@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    private let container = CKContainer.default()
    private let privateDatabase: CKDatabase
    
    @Published var isSignedInToiCloud = false
    @Published var syncStatus: SyncStatus = .idle
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case failed(Error)
    }
    
    enum CloudKitError: Error, LocalizedError {
        case notSignedIn
        case networkUnavailable
        case quotaExceeded
        case recordNotFound
        case unknownError(String)
        
        var errorDescription: String? {
            switch self {
            case .notSignedIn:
                return "Please sign in to iCloud to sync your data."
            case .networkUnavailable:
                return "Network connection is unavailable."
            case .quotaExceeded:
                return "iCloud storage quota exceeded."
            case .recordNotFound:
                return "Record not found in iCloud."
            case .unknownError(let message):
                return "CloudKit error: \(message)"
            }
        }
    }
    
    struct CloudData {
        let routines: [Routine]
        let habits: [Habit]
        let scheduleItems: [ScheduleItem]
    }
    
    private init() {
        privateDatabase = container.privateCloudDatabase
        
        Task {
            await checkiCloudStatus()
            await requestNotificationPermissions()
        }
    }
    
    // MARK: - iCloud Account Status
    
    func checkiCloudStatus() async {
        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                isSignedInToiCloud = status == .available
            }
        } catch {
            print("Failed to check iCloud status: \(error)")
            await MainActor.run {
                isSignedInToiCloud = false
            }
        }
    }
    
    private func requestNotificationPermissions() async {
        // Note: requestApplicationPermission(.userDiscoverability) was deprecated in iOS 17.0
        // and is no longer supported. CloudKit sharing now uses different mechanisms.
        print("CloudKit permissions no longer require explicit user discoverability requests in iOS 17+")
    }
    
    // MARK: - Routine Operations
    
    func saveRoutine(_ routine: Routine) async throws {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }
        
        let record = try routineToRecord(routine)
        
        do {
            _ = try await privateDatabase.save(record)
        } catch {
            throw mapCloudKitError(error)
        }
    }
    
    func fetchRoutines() async throws -> [Routine] {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Routine", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
        
        do {
            let result = try await privateDatabase.records(matching: query)
            var routines: [Routine] = []
            
            for (_, recordResult) in result.matchResults {
                switch recordResult {
                case .success(let record):
                    if let routine = try recordToRoutine(record) {
                        routines.append(routine)
                    }
                case .failure(let error):
                    print("Failed to fetch routine record: \(error)")
                }
            }
            
            return routines
        } catch {
            throw mapCloudKitError(error)
        }
    }
    
    func deleteRoutine(withId id: UUID) async throws {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }
        
        let recordID = CKRecord.ID(recordName: id.uuidString)
        
        do {
            _ = try await privateDatabase.deleteRecord(withID: recordID)
        } catch {
            throw mapCloudKitError(error)
        }
    }
    
    // MARK: - Habit Operations
    
    func saveHabit(_ habit: Habit) async throws {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }
        
        let record = try habitToRecord(habit)
        
        do {
            _ = try await privateDatabase.save(record)
        } catch {
            throw mapCloudKitError(error)
        }
    }
    
    func fetchHabits() async throws -> [Habit] {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Habit", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        do {
            let result = try await privateDatabase.records(matching: query)
            var habits: [Habit] = []
            
            for (_, recordResult) in result.matchResults {
                switch recordResult {
                case .success(let record):
                    if let habit = try recordToHabit(record) {
                        habits.append(habit)
                    }
                case .failure(let error):
                    print("Failed to fetch habit record: \(error)")
                }
            }
            
            return habits
        } catch {
            throw mapCloudKitError(error)
        }
    }
    
    func deleteHabit(withId id: UUID) async throws {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }
        
        let recordID = CKRecord.ID(recordName: id.uuidString)
        
        do {
            _ = try await privateDatabase.deleteRecord(withID: recordID)
        } catch {
            throw mapCloudKitError(error)
        }
    }
    
    // MARK: - Schedule Item Operations
    
    func saveScheduleItem(_ scheduleItem: ScheduleItem) async throws {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }
        
        let record = try scheduleItemToRecord(scheduleItem)
        
        do {
            _ = try await privateDatabase.save(record)
        } catch {
            throw mapCloudKitError(error)
        }
    }
    
    func fetchScheduleItems() async throws -> [ScheduleItem] {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "ScheduleItem", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        
        do {
            let result = try await privateDatabase.records(matching: query)
            var scheduleItems: [ScheduleItem] = []
            
            for (_, recordResult) in result.matchResults {
                switch recordResult {
                case .success(let record):
                    if let scheduleItem = try recordToScheduleItem(record) {
                        scheduleItems.append(scheduleItem)
                    }
                case .failure(let error):
                    print("Failed to fetch schedule item record: \(error)")
                }
            }
            
            return scheduleItems
        } catch {
            throw mapCloudKitError(error)
        }
    }
    
    func deleteScheduleItem(withId id: UUID) async throws {
        guard isSignedInToiCloud else {
            throw CloudKitError.notSignedIn
        }
        
        let recordID = CKRecord.ID(recordName: id.uuidString)
        
        do {
            _ = try await privateDatabase.deleteRecord(withID: recordID)
        } catch {
            throw mapCloudKitError(error)
        }
    }

    // MARK: - Bulk Operations
    
    func fetchAllData() async throws -> CloudData {
        async let routines = fetchRoutines()
        async let habits = fetchHabits()
        async let scheduleItems = fetchScheduleItems()
        
        return CloudData(
            routines: try await routines,
            habits: try await habits,
            scheduleItems: try await scheduleItems
        )
    }
    
    func syncAll() async {
        await MainActor.run {
            syncStatus = .syncing
        }
        
        do {
            let cloudData = try await fetchAllData()
            
            // Notify PlannerDataManager to merge data
            await PlannerDataManager.shared.mergeRoutines(cloudData.routines)
            await PlannerDataManager.shared.mergeHabits(cloudData.habits)
            await PlannerDataManager.shared.mergeScheduleItems(cloudData.scheduleItems)
            
            await MainActor.run {
                syncStatus = .success
            }
        } catch {
            await MainActor.run {
                syncStatus = .failed(error)
            }
        }
    }
    
    // MARK: - Record Conversion
    
    private func routineToRecord(_ routine: Routine) throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: routine.id.uuidString)
        let record = CKRecord(recordType: "Routine", recordID: recordID)
        
        // Encode the routine as JSON data
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let routineData = try encoder.encode(routine)
        
        record["data"] = routineData
        record["name"] = routine.name
        record["createdDate"] = routine.createdDate
        record["lastModified"] = Date()
        
        return record
    }
    
    private func recordToRoutine(_ record: CKRecord) throws -> Routine? {
        guard let routineData = record["data"] as? Data else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Routine.self, from: routineData)
    }
    
    private func habitToRecord(_ habit: Habit) throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: habit.id.uuidString)
        let record = CKRecord(recordType: "Habit", recordID: recordID)
        
        // Encode the habit as JSON data
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let habitData = try encoder.encode(habit)
        
        record["data"] = habitData
        record["name"] = habit.name
        record["startDate"] = habit.startDate
        record["lastModified"] = Date()
        
        return record
    }
    
    private func recordToHabit(_ record: CKRecord) throws -> Habit? {
        guard let habitData = record["data"] as? Data else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Habit.self, from: habitData)
    }
    
    private func scheduleItemToRecord(_ scheduleItem: ScheduleItem) throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: scheduleItem.id.uuidString)
        let record = CKRecord(recordType: "ScheduleItem", recordID: recordID)
        
        // Encode the schedule item as JSON data
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let scheduleItemData = try encoder.encode(scheduleItem)
        
        record["data"] = scheduleItemData
        record["title"] = scheduleItem.title
        record["startTime"] = scheduleItem.startTime
        record["endTime"] = scheduleItem.endTime
        record["lastModified"] = Date()
        
        return record
    }
    
    private func recordToScheduleItem(_ record: CKRecord) throws -> ScheduleItem? {
        guard let scheduleItemData = record["data"] as? Data else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(ScheduleItem.self, from: scheduleItemData)
    }
    
    // MARK: - Error Handling
    
    private func mapCloudKitError(_ error: Error) -> CloudKitError {
        guard let ckError = error as? CKError else {
            return .unknownError(error.localizedDescription)
        }
        
        switch ckError.code {
        case .notAuthenticated:
            return .notSignedIn
        case .networkUnavailable, .networkFailure:
            return .networkUnavailable
        case .quotaExceeded:
            return .quotaExceeded
        case .unknownItem:
            return .recordNotFound
        default:
            return .unknownError(ckError.localizedDescription)
        }
    }
}
