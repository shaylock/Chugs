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
    
    // MARK: - Set up action buttons
    private func makeChugsCategory() -> UNNotificationCategory {
        let gulp1 = UNNotificationAction(identifier: "CHUG_1", title: NSLocalizedString("notification.button.1gulp", comment: ""), options: [])
        let gulp2 = UNNotificationAction(identifier: "CHUG_2", title: NSLocalizedString("notification.button.2gulps", comment: ""), options: [])
        let gulp3 = UNNotificationAction(identifier: "CHUG_3", title: NSLocalizedString("notification.button.3gulps", comment: ""), options: [])
        let gulp4 = UNNotificationAction(identifier: "CHUG_4", title: NSLocalizedString("notification.button.4gulps", comment: ""), options: [])
        let more = UNNotificationAction(identifier: "CHUG_MORE", title: NSLocalizedString("notification.button.more", comment: ""), options: [.foreground])
        let notNow = UNNotificationAction(identifier: "NOT_NOW", title: NSLocalizedString("notification.button.notnow", comment: ""), options: [])

        return UNNotificationCategory(
            identifier: "CHUGS_CATEGORY",
            actions: [gulp1, gulp2, gulp3, gulp4, more, notNow],
            intentIdentifiers: [],
            options: []
        )
    }

    func ensureChugsCategoryExists() {
        let category = makeChugsCategory()
        let center = UNUserNotificationCenter.current()
        center.getNotificationCategories { existingCategories in
            if !existingCategories.contains(where: { $0.identifier == category.identifier }) {
                var merged = existingCategories
                merged.insert(category)
                center.setNotificationCategories(merged)
            }
        }
    }
}
