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
    
    // MARK: - Set up action buttons
    private func makeChugsCategory() -> UNNotificationCategory {
        let track = UNNotificationAction(identifier: "TRACK", title: NSLocalizedString("track.button.chug", comment: ""), options: [])

        return UNNotificationCategory(
            identifier: "CHUGS_TRACK",
            actions: [track],
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
