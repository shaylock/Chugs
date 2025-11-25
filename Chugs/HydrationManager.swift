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
    let hour: Int      // 0–23
    let totalLiters: Double
}

final class HydrationManager: ObservableObject {
    static let shared = HydrationManager()

    private let healthStore = HKHealthStore()

    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("dailyProgress") private var dailyProgress: Double = 0.0
    @AppStorage("lastProgressDate") private var lastProgressDate: String = ""

    // MARK: - Published for UI
    @Published var dailyHistory: [DailyHydration] = []         // last N days
    @Published var todayHourly: [HourlyHydration] = []         // 0–23 hours
    @Published var todayTotalLiters: Double = 0.0

    @Published var last7DayCompletionPercent: Double = 0.0     // 0–100
    @Published var last7DayChangePercent: Double? = nil        // vs previous 7 days

    private init() { }

    // Expose goal for views (needed to calculate per-day completion)
    var goalLiters: Double { dailyGoal }

    // MARK: - Public API (Write)
    func addWater(amount liters: Double) {
        resetIfNewDay()
        dailyProgress += liters
        saveToHealthKit(amountLiters: liters)
    }

    // MARK: - Day reset logic
    func resetIfNewDay() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if lastProgressDate != today {
            dailyProgress = 0.0
            lastProgressDate = today
        }
    }

    // MARK: - HealthKit Write
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
