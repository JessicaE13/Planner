import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    @Published var todayStepCount: Int = 0
    @Published var todayDistanceMeters: Double = 0
    @Published var todayActiveEnergy: Double = 0
    @Published var todayFlightsClimbed: Int = 0
    @Published var todayExerciseMinutes: Int = 0
    @Published var todayAverageHeartRate: Int = 0
    @Published var todayStandHours: Int = 0

    private init() {}

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let standType = HKObjectType.categoryType(forIdentifier: .appleStandHour)!
        let toRead: Set<HKObjectType> = [stepType, distanceType, activeEnergyType, flightsType, exerciseType, heartRateType, standType]

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

    func fetchTodayDistanceWalkingRunning() async throws {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: distanceType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { [weak self] _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let meters = result?.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
                DispatchQueue.main.async {
                    self?.todayDistanceMeters = meters
                }
                continuation.resume(returning: ())
            }

            self.healthStore.execute(query)
        }
    }

    func fetchTodayActiveEnergy() async throws {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: energyType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { [weak self] _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let kcal = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                DispatchQueue.main.async {
                    self?.todayActiveEnergy = kcal
                }
                continuation.resume(returning: ())
            }

            self.healthStore.execute(query)
        }
    }

    func fetchTodayFlightsClimbed() async throws {
        let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: flightsType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { [weak self] _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let flights = Int(result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
                DispatchQueue.main.async {
                    self?.todayFlightsClimbed = flights
                }
                continuation.resume(returning: ())
            }

            self.healthStore.execute(query)
        }
    }

    func fetchTodayExerciseMinutes() async throws {
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: exerciseType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { [weak self] _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let minutes = Int(result?.sumQuantity()?.doubleValue(for: HKUnit.minute()) ?? 0)
                DispatchQueue.main.async {
                    self?.todayExerciseMinutes = minutes
                }
                continuation.resume(returning: ())
            }

            self.healthStore.execute(query)
        }
    }

    func fetchTodayAverageHeartRate() async throws {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let unit = HKUnit.count().unitDivided(by: HKUnit.minute())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: heartRateType,
                                          quantitySamplePredicate: predicate,
                                          options: .discreteAverage) { [weak self] _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let avg = result?.averageQuantity()?.doubleValue(for: unit) ?? 0
                let bpm = Int((avg).rounded())
                DispatchQueue.main.async {
                    self?.todayAverageHeartRate = bpm
                }
                continuation.resume(returning: ())
            }

            self.healthStore.execute(query)
        }
    }

    func fetchTodayStandHours() async throws {
        let standType = HKObjectType.categoryType(forIdentifier: .appleStandHour)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: standType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let categorySamples = samples as? [HKCategorySample] ?? []
                let stoodCount = categorySamples.filter { $0.value == HKCategoryValueAppleStandHour.stood.rawValue }.count

                DispatchQueue.main.async {
                    self?.todayStandHours = stoodCount
                }
                continuation.resume(returning: ())
            }

            self.healthStore.execute(query)
        }
    }

    func fetchTodayMetrics() async throws {
        async let steps: Void = fetchTodaySteps()
        async let distance: Void = fetchTodayDistanceWalkingRunning()
        async let energy: Void = fetchTodayActiveEnergy()
        async let flights: Void = fetchTodayFlightsClimbed()
        async let exercise: Void = fetchTodayExerciseMinutes()
        async let hr: Void = fetchTodayAverageHeartRate()
        async let stand: Void = fetchTodayStandHours()
        _ = try await (steps, distance, energy, flights, exercise, hr, stand)
    }
}
