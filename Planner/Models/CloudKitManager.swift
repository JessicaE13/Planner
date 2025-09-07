import Foundation
import CloudKit
import SwiftUI

@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    private let container = CKContainer.default()
    private let privateDatabase: CKDatabase
    
    @Published var isSignedInToiCloud = false
    @Published var iCloudAccountEmail: String?
    @Published var syncStatus: SyncStatus = .idle
    @Published var isSyncing = false
    @Published var syncError: String?
    
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
            
            // Get user record if signed in
            if status == .available {
                await fetchUserRecord()
            } else {
                await MainActor.run {
                    iCloudAccountEmail = nil
                }
            }
        } catch {
            print("Failed to check iCloud status: \(error)")
            await MainActor.run {
                isSignedInToiCloud = false
                iCloudAccountEmail = nil
            }
        }
    }
    
    private func requestNotificationPermissions() async {
        // Note: requestApplicationPermission(.userDiscoverability) was deprecated in iOS 17.0
        // and is no longer supported. CloudKit sharing now uses different mechanisms.
        print("CloudKit permissions no longer require explicit user discoverability requests in iOS 17+")
    }
    
    private func fetchUserRecord() async {
        do {
            let userRecord = try await container.userRecordID()
            await MainActor.run {
                // The recordName usually contains the user identifier
                // For privacy, we'll show a masked version
                let recordName = userRecord.recordName
                if recordName.contains("_") {
                    let components = recordName.components(separatedBy: "_")
                    if components.count > 1 {
                        let userID = components[1]
                        let maskedID = String(userID.prefix(4)) + "****"
                        iCloudAccountEmail = "iCloud User: \(maskedID)"
                    } else {
                        iCloudAccountEmail = "iCloud User: ****"
                    }
                } else {
                    iCloudAccountEmail = "iCloud User: Connected"
                }
            }
        } catch {
            print("Failed to fetch user record: \(error)")
            await MainActor.run {
                iCloudAccountEmail = "iCloud User: Connected"
            }
        }
    }
    
    func openSystemiCloudSettings() {
        print("🔧 openSystemiCloudSettings called")
        
        #if targetEnvironment(macCatalyst)
        print("🖥️ Running on Mac Catalyst")
        // Running as Mac Catalyst app (iPad app on Mac)
        openMacCatalystSettings()
        #elseif os(iOS)
        print("📱 Running on iOS")
        // Check if we're actually running on Mac via Mac Catalyst
        if ProcessInfo.processInfo.isMacCatalystApp {
            print("🖥️ Detected Mac Catalyst environment via ProcessInfo")
            openMacCatalystSettings()
        } else {
            // Check if we're running in iOS Simulator on Mac
            #if targetEnvironment(simulator)
            // In iOS Simulator, the iOS URL schemes don't work, so we need an alternative
            print("iCloud settings cannot be opened in iOS Simulator. Please configure iCloud in System Preferences on your Mac.")
            // We could potentially show an alert here instead
            #else
            // Real iOS device
            if let settingsUrl = URL(string: "App-prefs:root=CASTLE") {
                UIApplication.shared.open(settingsUrl)
            } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
            #endif
        }
        #elseif os(macOS)
        print("💻 Running on native macOS")
        // Native macOS app
        if let url = URL(string: "x-apple.systempreferences:com.apple.preferences.AppleIDPrefPane") {
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.launchApplication("System Preferences")
        }
        #endif
    }
    
    private func openMacCatalystSettings() {
        // Use UIApplication for Mac Catalyst - try modern System Settings first
        if let url = URL(string: "x-apple.systemsettings:com.apple.preferences.AppleIDSettings") {
            print("📱 Trying to open System Settings with URL: \(url)")
            UIApplication.shared.open(url) { success in
                print("✅ System Settings URL result: \(success)")
                if !success {
                    // Try fallback
                    if let fallbackUrl = URL(string: "x-apple.systempreferences:com.apple.preferences.AppleIDPrefPane") {
                        print("📱 Trying fallback System Preferences URL: \(fallbackUrl)")
                        UIApplication.shared.open(fallbackUrl) { fallbackSuccess in
                            print("✅ Fallback URL result: \(fallbackSuccess)")
                            if !fallbackSuccess {
                                // Final fallback - open app settings
                                print("📱 Trying final fallback: app settings")
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }
                        }
                    }
                }
            }
        } else {
            print("❌ Failed to create System Settings URL")
        }
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
        } catch let ckError as CKError {
            // Handle the case where no records exist yet (common on first sync)
            if ckError.code == .unknownItem || ckError.code == .invalidArguments {
                print("No routines found in CloudKit, returning empty array")
                return []
            }
            throw mapCloudKitError(ckError)
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
        } catch let ckError as CKError {
            // Handle the case where no records exist yet (common on first sync)
            if ckError.code == .unknownItem || ckError.code == .invalidArguments {
                print("No habits found in CloudKit, returning empty array")
                return []
            }
            throw mapCloudKitError(ckError)
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
        } catch let ckError as CKError {
            // Handle the case where no records exist yet (common on first sync)
            if ckError.code == .unknownItem || ckError.code == .invalidArguments {
                print("No schedule items found in CloudKit, returning empty array")
                return []
            }
            throw mapCloudKitError(ckError)
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
