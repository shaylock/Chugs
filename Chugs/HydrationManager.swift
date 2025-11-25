//
//  HydrationManager.swift
//  Chugs
//
//  Created by Shay Blum on 25/11/2025.
//

import Foundation
import HealthKit
import SwiftUI

final class HydrationManager: ObservableObject {
    static let shared = HydrationManager()

    private let healthStore = HKHealthStore()

    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("dailyProgress") private var dailyProgress: Double = 0.0
    @AppStorage("lastProgressDate") private var lastProgressDate: String = ""

    private init() { }

    // MARK: - Public API
    /// Adds a given amount (in liters) to daily progress and logs it to HealthKit.
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
        let quantity = HKQuantity(unit: HKUnit.liter(), doubleValue: amountLiters)
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: Date(), end: Date())

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
