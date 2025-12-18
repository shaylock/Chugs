//
//  PermissionUtilities.swift
//  Chugs
//
//  Created by Shay Blum on 15/11/2025.
//

import HealthKit
import SwiftUI

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

class NotificationPermission {
    static let shared = NotificationPermission()
    
    public func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if !granted {
                        self.promptToOpenSettings()
                    }
                }
            case .denied:
                self.promptToOpenSettings()
            case .authorized, .provisional, .ephemeral:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func promptToOpenSettings() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else { return }
            
            let alert = UIAlertController(
                title: NSLocalizedString("notification.alert.disabled.title", comment: ""),
                message: NSLocalizedString("notification.alert.disabled.message", comment: ""),
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("notification.button.cancel", comment: ""),
                style: .cancel
            ))
            
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("notification.button.openSettings", comment: ""),
                style: .default
            ) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            
            rootVC.present(alert, animated: true)
        }
    }
}
    
