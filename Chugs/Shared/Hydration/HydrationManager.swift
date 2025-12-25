//
//  HydrationManager.swift
//  Chugs
//
//  Created by Shay Blum on 25/11/2025.
//

import Foundation
import HealthKit
import SwiftUI

struct DailyHydration: Identifiable {
    let id = UUID()
    let date: Date
    let totalLiters: Double
}

struct HourlyHydration: Identifiable {
    let id = UUID()
    let hour: Int
    let totalLiters: Double
}

// USED
struct HydrationEntry {
    let date: Date
    let volumeML: Double
}

extension Calendar {
    func weekendDays(using locale: Locale) -> Set<Int> {
        var result: Set<Int> = []
        let today = Date()

        if let interval = self.dateIntervalOfWeekend(containing: today) {
            let startWeekday = self.component(.weekday, from: interval.start)
            let endDate = interval.end.addingTimeInterval(-60)
            let endWeekday = self.component(.weekday, from: endDate)

            if startWeekday <= endWeekday {
                for day in startWeekday...endWeekday {
                    result.insert(day)
                }
            } else {
                for day in startWeekday...7 { result.insert(day) }
                for day in 1...endWeekday { result.insert(day) }
            }
        }

        return result
    }
}


final class HydrationManager: ObservableObject {
    private let logger = LoggerUtilities.makeLogger(for: HydrationManager.self)
    static let shared = HydrationManager()

    @AppStorage("hydrationHabits") private var hydrationHabitsData: Data = Data()
    @Published private(set) var hydrationHabits: HydrationHabits = HydrationHabits()
    
    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("storedDailyProgress") private var storedDailyProgress: Double = 0.0
    @AppStorage("lastProgressDate") private var lastProgressDate: String = ""
    @AppStorage("nextWeeklyUpdateAt") private var nextWeeklyUpdateAt: Double = 0

    @Published var dailyHistory: [DailyHydration] = []
    @Published var todayHourly: [HourlyHydration] = []
    @Published var todayTotalLiters: Double = 0.0

    @Published var last7DayCompletionPercent: Double = 0.0
    @Published var last7DayChangePercent: Double? = nil
    
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
    
    // UNUSED
    func hydrationHabitsSnapshot() -> HydrationHabits {
        hydrationHabits
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
    
    func runAppResumeLogic() {
        let now = Date()
        let next = storedNextUpdateDate()

//        if BuildUtilities.isDebugEnabled || now >= next {
        if now >= next || !hydrationHabits.isInitialized() {
            logger.info("App resume — performing weekly update")
            Task {
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
    
    // USED
    func addWater(amount liters: Double) {
        storedDailyProgress += liters
        saveToHealthKit(amountLiters: liters)
    }

    /// Write hydration sample to Apple Health
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
    
    /// Returns the hydration history for N full weeks PRIOR to the current one
    func getFullWeeksHistory(weeks: Int) async -> [HydrationEntry] {

        let calendar = Calendar.current
        let now = Date()

        // Determine first day of the current week (localized)
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)!.start

        // Starting point for "full week N"
        var startDate = calendar.date(byAdding: .weekOfYear, value: -weeks, to: weekStart)!
        let endDate = weekStart  // up to start of current week

        // Actually pull samples from HealthKit
        let samples = await fetchHydration(from: startDate, to: endDate)

        return samples
    }
    
    /// Query Apple Health (replace with real HKSampleQuery)
    private func fetchHydration(from start: Date, to end: Date) async -> [HydrationEntry] {
        // PSEUDO CODE — implement using HKSampleQuery
        /*
        let type = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let query = HKSampleQuery(...)
        */

        // Replace this stub once integrated
        return []
    }
}

// MARK: - HealthKit Read (History + Today details)
extension HydrationManager {
    // USED
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

    // USED - ??
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
    
    // USED
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
    
    // USED
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
    
    /// Fetches hydration samples from HealthKit for the last `daysBack` days,
    /// computes daily totals, today's hourly buckets, and 7-day trends.
    func fetchHydrationHistory(daysBack: Int = 14) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else { return }

        let now = Date()
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -daysBack, to: now) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: [])

        // Ensure we have read permission
        healthStore.requestAuthorization(toShare: [], read: [waterType]) { success, error in
            guard success else {
                if let error = error {
                    print("HealthKit auth error:", error.localizedDescription)
                }
                return
            }

            let query = HKSampleQuery(
                sampleType: waterType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { [weak self] _, samples, error in
                guard let self = self else { return }
                guard let samples = samples as? [HKQuantitySample], error == nil else {
                    if let error = error {
                        print("HealthKit read error:", error.localizedDescription)
                    }
                    return
                }

                DispatchQueue.main.async {
                    self.processSamples(samples, daysBack: daysBack)
                }
            }

            self.healthStore.execute(query)
        }
    }

    private func processSamples(_ samples: [HKQuantitySample], daysBack: Int) {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        // 1) Daily totals
        let dailyAgg = aggregateSamples(samples)
        self.dailyHistory = dailyAgg

        // 2) Today's hourly buckets (0–23)
        let todaySamples = samples.filter { $0.startDate >= todayStart }
        let hourly = aggregateTodayByHour(todaySamples)
        self.todayHourly = hourly
        self.todayTotalLiters = hourly.reduce(0) { $0 + $1.totalLiters }

        // 3) 7-day trend vs previous 7 days
        computeSevenDayTrends(from: dailyAgg)
    }

    /// Reduces all individual samples into daily totals
    private func aggregateSamples(_ samples: [HKQuantitySample]) -> [DailyHydration] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: samples) { sample -> Date in
            calendar.startOfDay(for: sample.startDate)
        }

        let daily = grouped.map { (date, samples) -> DailyHydration in
            let totalLiters = samples.reduce(0.0) { sum, sample in
                sum + sample.quantity.doubleValue(for: .liter())
            }
            return DailyHydration(date: date, totalLiters: totalLiters)
        }

        // Newest first
        return daily.sorted(by: { $0.date > $1.date })
    }

    /// Builds hourly buckets (0–23) for today's samples.
    private func aggregateTodayByHour(_ samples: [HKQuantitySample]) -> [HourlyHydration] {
        let calendar = Calendar.current

        var buckets: [Int: Double] = [:]

        for sample in samples {
            let hour = calendar.component(.hour, from: sample.startDate)
            let liters = sample.quantity.doubleValue(for: .liter())
            buckets[hour, default: 0.0] += liters
        }

        // Ensure we always return 0–23 for smoother charts
        let result: [HourlyHydration] = (0..<24).map { hour in
            let value = buckets[hour, default: 0.0]
            return HourlyHydration(hour: hour, totalLiters: value)
        }

        // Filter out all-zero days only if you want sparse charts, but we keep all for smooth axis.
        return result
    }

    /// Computes 7-day completion and trend vs previous 7 days.
    private func computeSevenDayTrends(from daily: [DailyHydration]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: today),
              let prevWeekStart = calendar.date(byAdding: .day, value: -13, to: today),
              let prevWeekEnd = calendar.date(byAdding: .day, value: -7, to: today)
        else { return }

        let last7 = daily.filter { $0.date >= weekStart && $0.date <= today }
        let prev7 = daily.filter { $0.date >= prevWeekStart && $0.date <= prevWeekEnd }

        let last7Total = last7.reduce(0.0) { $0 + $1.totalLiters }
        let prev7Total = prev7.reduce(0.0) { $0 + $1.totalLiters }

        let goalTotal = dailyGoal * 7.0
        if goalTotal > 0 {
            last7DayCompletionPercent = min(100.0, (last7Total / goalTotal) * 100.0)
        } else {
            last7DayCompletionPercent = 0.0
        }

        if prev7Total > 0 {
            last7DayChangePercent = ((last7Total - prev7Total) / prev7Total) * 100.0
        } else {
            last7DayChangePercent = nil
        }
    }
}
