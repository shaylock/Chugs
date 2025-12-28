//
//  HydrationManager.swift
//  Chugs
//
//  Created by Shay Blum on 25/11/2025.
//

import Foundation
import HealthKit
import SwiftUI

struct HydrationEntry {
    let date: Date
    let volumeML: Double
}

final class HydrationManager: ObservableObject {
    private let logger = LoggerUtilities.makeLogger(for: HydrationManager.self)
    static let shared = HydrationManager()

    @AppStorage("hydrationHabits") private var hydrationHabitsData: Data = Data()
    @Published private(set) var hydrationHabits: HydrationHabits = HydrationHabits()
    
    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage(
        "storedDailyProgress",
        store: AppGroup.defaults
    )
    private var storedDailyProgress: Double = 0.0
    @AppStorage("lastProgressDate") private var lastProgressDate: String = ""
    @AppStorage("nextWeeklyUpdateAt") private var nextWeeklyUpdateAt: Double = 0
    
    private let healthStore = HKHealthStore()
    private let habitsEncoder = JSONEncoder()
    private let habitsDecoder = JSONDecoder()
    
    // Expose goal to UI
    var goalLiters: Double { dailyGoal }

    private init() {
        loadHydrationHabits()
    }
    
    private func storedNextUpdateDate() -> Date {
        if nextWeeklyUpdateAt > 0 {
            return Date(timeIntervalSince1970: nextWeeklyUpdateAt)
        } else {
            // Initialize schedule (don’t run immediately)
            let initial = TimeUtilities.upcomingSundayMidnight(from: Date())
            nextWeeklyUpdateAt = initial.timeIntervalSince1970
            return initial
        }
    }

    private func loadHydrationHabits() {
        guard !hydrationHabitsData.isEmpty else {
            hydrationHabits = HydrationHabits()
            return
        }

        if let decoded = try? habitsDecoder.decode(
            HydrationHabits.self,
            from: hydrationHabitsData
        ) {
            hydrationHabits = decoded
        } else {
            hydrationHabits = HydrationHabits()
        }
    }

    private func saveHydrationHabits(_ habits: HydrationHabits) {
        if let data = try? habitsEncoder.encode(habits) {
            hydrationHabitsData = data
        }
    }
    
    func runAppResumeLogic() async {
        let now = Date()
        let next = storedNextUpdateDate()

//        if BuildUtilities.isDebugEnabled || now >= next {
        if now >= next || !hydrationHabits.isInitialized() {
            logger.info("App resume — performing weekly update")
            do {
                let healthStore = HKHealthStore()

                let habits = try await collectHydrationHabits(
                    healthStore: healthStore
                )

                await MainActor.run {
                    self.hydrationHabits = habits
                    self.saveHydrationHabits(habits)
                }
            } catch {
                logger.error("Error collecting hydration habits: \(error.localizedDescription)")
            }
            // Schedule the next one for the upcoming Sunday at 00:00
            let newNext = TimeUtilities.upcomingSundayMidnight(from: now)
            nextWeeklyUpdateAt = newNext.timeIntervalSince1970
        }
        if (hydrationHabits.isInitialized()) {
            logger.info("Hydration Habits (4-week average):")
            logger.info("\(self.hydrationHabits)")
        }
    }
}

// MARK: - Public Write API
extension HydrationManager {
    func addWater(amount liters: Double) {
        storedDailyProgress += liters
        saveToHealthKit(amountLiters: liters)
    }

    private func saveToHealthKit(amountLiters: Double) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else { return }

        let quantity = HKQuantity(unit: .liter(), doubleValue: amountLiters)
        let now = Date()
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: now, end: now)

        healthStore.requestAuthorization(toShare: [waterType], read: [waterType]) { success, error in
            guard success else { return }

            self.healthStore.save(sample) { success, error in
                if let error = error {
                    print("HealthKit save error:", error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - HealthKit Read (History + Today details)
extension HydrationManager {
    func fetchHydrationData(
        healthStore: HKHealthStore,
        startDate: Date,
        endDate: Date
    ) async throws -> [HydrationEntry] {

        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            return []
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: true
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: waterType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let entries: [HydrationEntry] = (samples as? [HKQuantitySample])?.map {
                    HydrationEntry(
                        date: $0.startDate,
                        volumeML: $0.quantity.doubleValue(for: .literUnit(with: .milli))
                    )
                } ?? []

                continuation.resume(returning: entries)
            }

            healthStore.execute(query)
        }
    }

    func collectHydrationHabits(
        healthStore: HKHealthStore
    ) async throws -> HydrationHabits {

        let entries = try await getFullWeeksHistory(
            healthStore: healthStore,
            weeks: 4
        )

        var habits = HydrationHabits()
        let calendar = Calendar.current

        // Group entries by calendar day
        let groupedByDay = Dictionary(grouping: entries) {
            calendar.startOfDay(for: $0.date)
        }

        for (dayDate, dayEntries) in groupedByDay {

            // 1. Total water for the day
            let dailyTotal = dayEntries.reduce(0) { $0 + $1.volumeML }
            guard dailyTotal > 0 else { continue }

            // 2. Day index (Sunday = 0)
            let dayIndex = calendar.component(.weekday, from: dayDate) - 1

            // 3. Bucket sums
            var bucketTotals = Array(repeating: 0.0, count: 8)

            for entry in dayEntries {
                let hour = calendar.component(.hour, from: entry.date)
                let bucketIndex = hour / 3
                bucketTotals[bucketIndex] += entry.volumeML
            }

            // 4. Compute ratios and update habits
            for bucketIndex in 0..<8 {
                let bucketVolume = bucketTotals[bucketIndex]

                let ratio = bucketVolume / dailyTotal

                habits.updateRatio(
                    dayIndex: dayIndex,
                    bucketIndex: bucketIndex,
                    newRatio: ratio
                )
            }
        }

        return habits
    }

    func fetchHydrationTotal(from start: Date, to end: Date) async -> Double {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else { return 0 }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: waterType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                
                if let error = error {
                    print("HealthKit sample fetch error:", error.localizedDescription)
                    continuation.resume(returning: 0)
                    return
                }

                let total = (samples as? [HKQuantitySample])?
                    .reduce(0.0) { sum, sample in
                        sum + sample.quantity.doubleValue(for: .liter())
                    } ?? 0

                continuation.resume(returning: total)
            }

            self.healthStore.execute(query)
        }
    }
    
    func fetchDailyProgress() {
        Task {
            guard HealthStore.shared.hasReadAccess() else { return }

            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let now = Date()

            let total = await fetchHydrationTotal(from: startOfDay, to: now)

            await MainActor.run {
                self.storedDailyProgress = total
                logger.debug("Fetched daily progress from HealthKit: \(total) liters")
            }
        }
    }
    
    func getFullWeeksHistory(
        healthStore: HKHealthStore,
        weeks: Int
    ) async throws -> [HydrationEntry] {

        guard weeks > 0 else { return [] }

        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Sunday
        calendar.timeZone = .current

        let now = Date()

        // Start of current week (Sunday 00:00)
        let startOfCurrentWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        )!

        // End of last full week (Saturday 23:59:59)
        let endDate = calendar.date(
            byAdding: .second,
            value: -1,
            to: startOfCurrentWeek
        )!

        // Start of earliest full week requested
        let startDate = calendar.date(
            byAdding: .weekOfYear,
            value: -weeks,
            to: startOfCurrentWeek
        )!

        return try await fetchHydrationData(
            healthStore: healthStore,
            startDate: startDate,
            endDate: endDate
        )
    }
}
