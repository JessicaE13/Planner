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
    @Published var todaySleepDuration: TimeInterval = 0

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
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let toRead: Set<HKObjectType> = [stepType, distanceType, activeEnergyType, flightsType, exerciseType, heartRateType, standType, sleepType]

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

    func fetchSteps(for date: Date) async throws {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let now = Date()
        let end = min(nextDay, now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: end, options: .strictStartDate)

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

    func fetchDistanceWalkingRunning(for date: Date) async throws {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let now = Date()
        let end = min(nextDay, now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: end, options: .strictStartDate)

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

    func fetchActiveEnergy(for date: Date) async throws {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let now = Date()
        let end = min(nextDay, now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: end, options: .strictStartDate)

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

    func fetchFlightsClimbed(for date: Date) async throws {
        let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let now = Date()
        let end = min(nextDay, now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: end, options: .strictStartDate)

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

    func fetchExerciseMinutes(for date: Date) async throws {
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let now = Date()
        let end = min(nextDay, now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: end, options: .strictStartDate)

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

    func fetchAverageHeartRate(for date: Date) async throws {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let now = Date()
        let end = min(nextDay, now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: end, options: .strictStartDate)
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

    func fetchStandHours(for date: Date) async throws {
        let standType = HKObjectType.categoryType(forIdentifier: .appleStandHour)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let now = Date()
        let end = min(nextDay, now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: end, options: .strictStartDate)

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

    func fetchSleepDuration(for date: Date) async throws {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let now = Date()
        let end = min(nextDay, now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: end, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let categorySamples = samples as? [HKCategorySample] ?? []
                var total: TimeInterval = 0

                for sample in categorySamples {
                    var isAsleep = false
                    if #available(iOS 16.0, *) {
                        if let value = HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                            switch value {
                            case .asleep, .asleepCore, .asleepDeep, .asleepREM:
                                isAsleep = true
                            default:
                                break
                            }
                        }
                    } else {
                        if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                            isAsleep = true
                        }
                    }

                    if isAsleep {
                        let clampedStart = max(sample.startDate, startOfDay)
                        let clampedEnd = min(sample.endDate, end)
                        if clampedEnd > clampedStart {
                            total += clampedEnd.timeIntervalSince(clampedStart)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self?.todaySleepDuration = total
                }
                continuation.resume(returning: ())
            }

            self.healthStore.execute(query)
        }
    }

    func fetchMetrics(for date: Date) async throws {
        async let steps: Void = fetchSteps(for: date)
        async let distance: Void = fetchDistanceWalkingRunning(for: date)
        async let energy: Void = fetchActiveEnergy(for: date)
        async let flights: Void = fetchFlightsClimbed(for: date)
        async let exercise: Void = fetchExerciseMinutes(for: date)
        async let hr: Void = fetchAverageHeartRate(for: date)
        async let stand: Void = fetchStandHours(for: date)
        async let sleep: Void = fetchSleepDuration(for: date)
        _ = try await (steps, distance, energy, flights, exercise, hr, stand, sleep)
    }
    
    func fetchTodayMetrics() async throws {
        try await fetchMetrics(for: Date())
    }
}
