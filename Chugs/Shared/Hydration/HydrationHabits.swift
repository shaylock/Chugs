//
//  HydrationHabits.swift
//  Tipot
//
//  Created by Shay Blum on 19/12/2025.
//

import SwiftUI

struct HydrationAverageBucket: Codable {
    var averageRatio: Double
    var samplesCount: Int
}

struct HydrationHabits: Codable {
    // [day][bucket]
    private var data: [[HydrationAverageBucket]]
    private var sums: [Double]
    private var initialized: Bool = false

    init() {
        self.data = Array(
            repeating: Array(
                repeating: HydrationAverageBucket(averageRatio: 0, samplesCount: 0),
                count: 8
            ),
            count: 7
        )
        self.sums = Array(repeating: 0.0, count: 7)
    }
    
    func isInitialized() -> Bool {
        return initialized
    }

    func fetchRatio(for date: Date) -> Double {
        guard initialized else {
            return 0.0
        }
        let calendar = Calendar.current
        let dayIndex = calendar.component(.weekday, from: date) - 1 // Sunday = 0
        let hour = calendar.component(.hour, from: date)
        let bucketIndex = hour / 3
        return data[dayIndex][bucketIndex].averageRatio
    }
    
    func fetchActivity(for date: Date) -> Double {
        guard initialized else {
            return 0.0
        }
        let calendar = Calendar.current
        let dayIndex = calendar.component(.weekday, from: date) - 1 // Sunday = 0
        guard sums[dayIndex] > 0 else {
            return 0.0
        }
        // todo: adjust activity calculation based on quantity of health records
        return 0.6
    }

    mutating func updateRatio(
        dayIndex: Int,
        bucketIndex: Int,
        newRatio: Double
    ) {
        initialized = true
        var bucket = data[dayIndex][bucketIndex]
        sums[dayIndex] -= bucket.averageRatio

        let total = bucket.averageRatio * Double(bucket.samplesCount)
        bucket.samplesCount += 1
        bucket.averageRatio = (total + newRatio) / Double(bucket.samplesCount)

        data[dayIndex][bucketIndex] = bucket
        sums[dayIndex] += bucket.averageRatio
    }
}

extension HydrationHabits: CustomStringConvertible {
    var description: String {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let buckets = [
            "00-03", "03-06", "06-09", "09-12",
            "12-15", "15-18", "18-21", "21-24"
        ]

        var lines: [String] = []

        // Header
        let header = ["Day"] + buckets + ["Sum"]
        lines.append(header.joined(separator: "\t"))

        // Rows
        for dayIndex in 0..<7 {
            var row: [String] = [days[dayIndex]]

            for bucketIndex in 0..<8 {
                let ratio = data[dayIndex][bucketIndex].averageRatio
                row.append(String(format: "%.2f", ratio))
            }
            row.append(String(format: "%.2f", sums[dayIndex]))

            lines.append(row.joined(separator: "\t"))
        }

        return lines.joined(separator: "\n")
    }
}

