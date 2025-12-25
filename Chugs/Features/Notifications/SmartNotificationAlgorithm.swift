//
//  SmartNotificationAlgorithm.swift
//  Chugs
//
//  Created by Shay Blum on 29/11/2025.
//

import Foundation
import SwiftUI

fileprivate let bucketCount = 8     // 3-hour buckets

/// Represents a normalized HS value per bucket
struct HydrationBucket: Codable {
    var value: Double  // Already normalized 0–1
}

final class SmartNotificationAlgorithm: ObservableObject {

    // MARK: - AppStorage
    @AppStorage("weekdayBuckets") private var weekdayBucketData: Data = Data()
    @AppStorage("weekendBuckets") private var weekendBucketData: Data = Data()

    @Published var weekdayBuckets: [HydrationBucket] = Array(repeating: HydrationBucket(value: 0), count: bucketCount)
    @Published var weekendBuckets: [HydrationBucket] = Array(repeating: HydrationBucket(value: 0), count: bucketCount)

    private let hydrationManager: HydrationManager

    init(hydrationManager: HydrationManager) {
        self.hydrationManager = hydrationManager
        loadBucketsFromStorage()
    }
    
    // UNUSED
    func getReminderFactor() -> Double {
        // get habit for current time and day
        // calculate urgency factor based on today's progress and goal
        return 1.0
    }

    // MARK: - Public Function
    /// Calculates and stores HS buckets (run once a week)
    // UNUSED
    func calculateHydrationBuckets() async {

        // Fetch 4 full weeks excluding the current week
        let history = await hydrationManager.getFullWeeksHistory(weeks: 4)

        guard !history.isEmpty else { return }

        // Temporary containers:
        // weekday: [[day ratios for each bucket]]
        // weekend: [[day ratios for each bucket]]
        var weekdayDailyRatios: [[Double]] = []
        var weekendDailyRatios: [[Double]] = []

        let calendar = Calendar.current
        let locale = Locale.current
        let weekendDays = calendar.weekendDays(using: locale)

        // Group results by day
        let groupedByDay = Dictionary(grouping: history) { entry in
            calendar.startOfDay(for: entry.date)
        }

        for (dayStart, dayEntries) in groupedByDay {

            // Determine day type (weekday/weekend) based on localization
            let isWeekend = weekendDays.contains(calendar.component(.weekday, from: dayStart))

            // Calculate daily total
            let total = dayEntries.reduce(0.0) { $0 + $1.volumeML }
            guard total > 0 else { continue }

            // Bucket totals
            var bucketTotals = Array(repeating: 0.0, count: bucketCount)

            for entry in dayEntries {
                let bucketIndex = Self.bucketIndex(for: entry.date)
                bucketTotals[bucketIndex] += entry.volumeML
            }

            // Convert bucket totals → daily ratios
            let ratios = bucketTotals.map { $0 / total }

            if isWeekend {
                weekendDailyRatios.append(ratios)
            } else {
                weekdayDailyRatios.append(ratios)
            }
        }

        // Produce averages per bucket
        let weekdayAvg = Self.averageRatios(dailyRatios: weekdayDailyRatios)
        let weekendAvg = Self.averageRatios(dailyRatios: weekendDailyRatios)

        // Normalize inside each day-type (so HS = bucketRatio / maxRatio)
        let weekdayHS = Self.normalized(weekdayAvg)
        let weekendHS = Self.normalized(weekendAvg)

        // Save into arrays
        weekdayBuckets = weekdayHS.map { HydrationBucket(value: $0) }
        weekendBuckets = weekendHS.map { HydrationBucket(value: $0) }

        saveBucketsToStorage()
    }

    // MARK: - Access HS for any time
    // UNUSED
    func getHsForTime(date: Date) -> Double {
        let calendar = Calendar.current
        let locale = Locale.current
        let weekday = calendar.component(.weekday, from: date)

        let weekendDays = calendar.weekendDays(using: locale)
        let isWeekend = weekendDays.contains(weekday)

        let bucketIndex = Self.bucketIndex(for: date)

        return isWeekend
            ? weekendBuckets[bucketIndex].value
            : weekdayBuckets[bucketIndex].value
    }

    // MARK: - Helpers
    private static func bucketIndex(for date: Date) -> Int {
        let hour = Calendar.current.component(.hour, from: date)
        return min(bucketCount - 1, hour / 3)
    }

    private static func averageRatios(dailyRatios: [[Double]]) -> [Double] {
        guard !dailyRatios.isEmpty else {
            return Array(repeating: 0.0, count: bucketCount)
        }

        var sums = Array(repeating: 0.0, count: bucketCount)

        for day in dailyRatios {
            for i in 0..<bucketCount {
                sums[i] += day[i]
            }
        }

        return sums.map { $0 / Double(dailyRatios.count) }
    }

    private static func normalized(_ ratios: [Double]) -> [Double] {
        guard let maxVal = ratios.max(), maxVal > 0 else {
            return Array(repeating: 0.0, count: bucketCount)
        }

        return ratios.map { $0 / maxVal }
    }

    // MARK: - Storage
    private func loadBucketsFromStorage() {
        if let decoded = try? JSONDecoder().decode([HydrationBucket].self, from: weekdayBucketData),
           decoded.count == bucketCount {
            weekdayBuckets = decoded
        }
        if let decoded = try? JSONDecoder().decode([HydrationBucket].self, from: weekendBucketData),
           decoded.count == bucketCount {
            weekendBuckets = decoded
        }
    }

    private func saveBucketsToStorage() {
        if let data = try? JSONEncoder().encode(weekdayBuckets) {
            weekdayBucketData = data
        }
        if let data = try? JSONEncoder().encode(weekendBuckets) {
            weekendBucketData = data
        }
    }
}
