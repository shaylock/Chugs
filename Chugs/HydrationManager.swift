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

final class HydrationManager: ObservableObject {
    static let shared = HydrationManager()

    private let healthStore = HKHealthStore()

    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("dailyProgress") private var dailyProgress: Double = 0.0
    @AppStorage("lastProgressDate") private var lastProgressDate: String = ""

    @Published var dailyHistory: [DailyHydration] = []

    private init() { }

    // MARK: - Public API
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

    // MARK: - HealthKit write
    private func saveToHealthKit(amountLiters: Double) {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
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

// MARK: - HealthKit read (History)
extension HydrationManager {
    /// Fetches hydration samples from HealthKit for the last X days
    func fetchHydrationHistory(daysBack: Int = 14) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!

        let startDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [])

        let query = HKSampleQuery(
            sampleType: waterType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else { return }

            DispatchQueue.main.async {
                self.dailyHistory = self.aggregateSamples(samples)
            }
        }

        healthStore.execute(query)
    }

    /// Reduces all individual samples into daily totals
    private func aggregateSamples(_ samples: [HKQuantitySample]) -> [DailyHydration] {
        let grouped = Dictionary(grouping: samples) { sample -> Date in
            Calendar.current.startOfDay(for: sample.startDate)
        }

        let daily = grouped.map { (date, samples) -> DailyHydration in
            let totalLiters = samples.reduce(0.0) { sum, sample in
                sum + sample.quantity.doubleValue(for: .liter())
            }
            return DailyHydration(date: date, totalLiters: totalLiters)
        }

        return daily.sorted(by: { $0.date > $1.date })
    }
}
