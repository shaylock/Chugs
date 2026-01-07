//
//  PermissionUtilities.swift
//  Tipot
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
    
    public static func allowedNotifications() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                print("Error requesting notification authorization: \(error)")
                return false
            }
        }
    }

    public func requestNotificationPermission(promptIfNeeded: Bool = false) async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(
                    options: [.alert, .sound, .badge]
                )
                if !granted, promptIfNeeded {
                    self.promptToOpenSettings()
                }
                return granted
            } catch {
                return false
            }
        case .denied:
            if promptIfNeeded {
                self.promptToOpenSettings()
            }
            return false
        case .authorized, .provisional, .ephemeral:
            return true
        @unknown default:
            return false
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
    
