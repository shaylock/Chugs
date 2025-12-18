//
//  PermissionUtilities.swift
//  Chugs
//
//  Created by Shay Blum on 15/11/2025.
//

import HealthKit

class HealthStore {
    static let shared = HealthStore()
    let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }

        // The water data type (in liters)
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            completion(false, nil)
            return
        }

        let typesToShare: Set = [waterType]
        let typesToRead: Set = [waterType]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: completion)
    }
}

extension HealthStore {
    func hasReadAccess() -> Bool {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            return false
        }
        return healthStore.authorizationStatus(for: waterType) != .sharingDenied
    }
}
