//
//  NotificationManager.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//

//import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    
//    private let userDefaults = UserDefaults.standard
    
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
