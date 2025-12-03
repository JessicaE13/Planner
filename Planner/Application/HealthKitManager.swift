import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    @Published var todayStepCount: Int = 0

    private init() {}

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let toRead: Set<HKObjectType> = [stepType]

        try await healthStore.requestAuthorization(toShare: [], read: toRead)
    }

    func fetchTodaySteps() async throws {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        // Start of day for the current calendar
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        var interval = DateComponents()
        interval.day = 1

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { [weak self] _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let count = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                let steps = Int(count)

                DispatchQueue.main.async {
                    self?.todayStepCount = steps
                }
                continuation.resume(returning: ())
            }

            self.healthStore.execute(query)
        }
    }
}
