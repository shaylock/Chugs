//
//  NotificationManager.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//

import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    public func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // Request permission if not asked before
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if !granted {
                        self.promptToOpenSettings()
                    }
                }
            case .denied:
                // Already denied, prompt to open settings
                self.promptToOpenSettings()
            case .authorized, .provisional, .ephemeral:
                // Permission granted, nothing to do
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
                title: "Notifications Disabled",
                message: "To receive chug reminders, please enable notifications in Settings.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            
            rootVC.present(alert, animated: true)
        }
    }
    
    // MARK: - Set up action buttons
    private func makeChugsCategory() -> UNNotificationCategory {
        let gulp1 = UNNotificationAction(identifier: "CHUG_1", title: "1 gulp", options: [])
        let gulp2 = UNNotificationAction(identifier: "CHUG_2", title: "2 gulps", options: [])
        let gulp3 = UNNotificationAction(identifier: "CHUG_3", title: "3 gulps", options: [])
        let gulp4 = UNNotificationAction(identifier: "CHUG_4", title: "4 gulps", options: [])
        let more = UNNotificationAction(identifier: "CHUG_MORE", title: "More…", options: [.foreground])
        let notNow = UNNotificationAction(identifier: "NOT_NOW", title: "Not now", options: [])

        return UNNotificationCategory(
            identifier: "CHUGS_CATEGORY",
            actions: [gulp1, gulp2, gulp3, gulp4, more, notNow],
            intentIdentifiers: [],
            options: []
        )
    }

    /// Ensures the CHUGS_CATEGORY exists by merging it with any existing categories.
    /// Safe to call every launch (won't remove categories registered by other code).
    func ensureChugsCategoryExists() {
        let category = makeChugsCategory()
        let center = UNUserNotificationCenter.current()
        center.getNotificationCategories { existingCategories in
            // If the category does not exist, merge and set; otherwise do nothing.
            if !existingCategories.contains(where: { $0.identifier == category.identifier }) {
                var merged = existingCategories
                merged.insert(category)
                center.setNotificationCategories(merged)
            }
        }
    }
}
