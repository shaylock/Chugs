//
//  NotificationUtilities.swift
//  Chugs
//
//  Created by Shay Blum on 17/10/2025.
//

import SwiftUI

final class NotificationUtilities {
    private static let logger = LoggerUtilities.makeLogger(for: NotificationUtilities.self)
    
    public static func checkPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            // Request authorization if not already granted
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                print("Error requesting notification authorization: \(error)")
                return false
            }
        }
    }
    
    public static func scheduleDailyNotifications(interval: Int, startMinutes: Int, endMinutes: Int) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let intervalSeconds: Int = interval * 60
        let startSeconds: Int = startMinutes * 60
        let endSeconds: Int = endMinutes * 60
        
        let effectiveStartSeconds = startSeconds

        var notificationsScheduled = 0
        let maxNotificationCount = 64

        for currentSeconds in stride(from: effectiveStartSeconds, through: endSeconds, by: intervalSeconds) {
            if notificationsScheduled >= maxNotificationCount {
                logger.warning("Reached 64 notifications. Stopping scheduling.")
                break
            }

            let hour: Int = currentSeconds / 3600
            let minute: Int = (currentSeconds % 3600) / 60
            let second: Int = currentSeconds % 60
            logger.debug("Scheduling notification for \(hour):\(minute):\(second)")

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.second = second

            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("intervalScheduler.notification.title", comment: "")
            content.body  = NSLocalizedString("intervalScheduler.notification.body", comment: "")
            content.categoryIdentifier = "CHUGS_CATEGORY"
            content.sound = .default

            let identifier = "drinkReminder_\(hour)_\(minute)_\(second)"
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            do {
                try await center.add(request)
            } catch {
                logger.error("Error scheduling notification: \(error.localizedDescription)")
            }
            notificationsScheduled += 1
        }

        logger.debug("✅ Scheduled \(notificationsScheduled) notifications.")
    }
}
