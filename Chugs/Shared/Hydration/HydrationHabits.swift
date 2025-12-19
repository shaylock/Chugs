//
//  HydrationHabits.swift
//  Chugs
//
//  Created by Shay Blum on 19/12/2025.
//

import SwiftUI

struct HydrationAverageBucket {
    var averageRatio: Double
    var samplesCount: Int
}

struct HydrationHabits {
    private let logger = LoggerUtilities.makeLogger(for: HydrationHabits.self)

    // [day][bucket]
    private var data: [[HydrationAverageBucket]]

    init() {
        self.data = Array(
            repeating: Array(
                repeating: HydrationAverageBucket(averageRatio: 0, samplesCount: 0),
                count: 8
            ),
            count: 7
        )
    }

    // MARK: - Fetch ratio

    func fetchRatio(for date: Date) -> Double {
        let calendar = Calendar.current

        let dayIndex = calendar.component(.weekday, from: date) - 1 // Sunday = 0
        let hour = calendar.component(.hour, from: date)
        let bucketIndex = hour / 3

        return data[dayIndex][bucketIndex].averageRatio
    }

    // MARK: - Update ratio with proper averaging

    mutating func updateRatio(
        dayIndex: Int,
        bucketIndex: Int,
        newRatio: Double
    ) {
        var bucket = data[dayIndex][bucketIndex]

        let total = bucket.averageRatio * Double(bucket.samplesCount)
        bucket.samplesCount += 1
        bucket.averageRatio = (total + newRatio) / Double(bucket.samplesCount)

        data[dayIndex][bucketIndex] = bucket
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
        let header = ["Day"] + buckets
        lines.append(header.joined(separator: "\t"))

        // Rows
        for dayIndex in 0..<7 {
            var row: [String] = [days[dayIndex]]

            for bucketIndex in 0..<8 {
                let ratio = data[dayIndex][bucketIndex].averageRatio
                row.append(String(format: "%.2f", ratio))
            }

            lines.append(row.joined(separator: "\t"))
        }

        return lines.joined(separator: "\n")
    }
}

