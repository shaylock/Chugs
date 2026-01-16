//
//  NotificationUtilities.swift
//  Tipot
//
//  Created by Shay Blum on 17/10/2025.
//

import SwiftUI

final class NotificationUtilities {
    @AppStorage("NotificationUtilities.lastSingleNotificationIdentifier")
    private static var lastSingleNotificationIdentifier: String?
    private static let logger = LoggerUtilities.makeLogger(for: NotificationUtilities.self)
    
    public static func removeLastSingleNotification() async {
        let center = UNUserNotificationCenter.current()
        guard let identifier = lastSingleNotificationIdentifier else {
            logger.debug("No last single notification identifier found.")
            return
        }
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        lastSingleNotificationIdentifier = nil
        logger.debug("🗑️ Removed last single notification with identifier: \(identifier)")
    }
    
    public static func removeAllNotifications() async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        lastSingleNotificationIdentifier = nil
        logger.debug("🗑️ Removed all pending notifications.")
    }
    
    public static func timeToNextNotification() async -> Double? {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let now = Date()

        let nextDate = requests.compactMap { request -> Date? in
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                return trigger.nextTriggerDate()
            }
            if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                return Date(timeIntervalSinceNow: trigger.timeInterval)
            }
            return nil
        }
        .filter { $0 > now }
        .min()

        guard let fireDate = nextDate else { return nil }
        return fireDate.timeIntervalSince(now) / 60.0   // minutes
    }

    
    public static func scheduleSingleNotificationIn(minutes: Double) async {
        guard minutes > 0 else {
            logger.warning("scheduleSingleNotificationIn called with non-positive minutes: \(minutes)")
            return
        }

        let center = UNUserNotificationCenter.current()
        let timeInterval = minutes * 60

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("intervalScheduler.notification.title", comment: "")
        content.body  = NSLocalizedString("intervalScheduler.notification.body", comment: "")
        content.categoryIdentifier = "CHUGS_TRACK"
        content.sound = UNNotificationSound(
            named: UNNotificationSoundName("water_poured.caf")
        )

        let identifier = "singleDrinkReminder_\(UUID().uuidString)"
        lastSingleNotificationIdentifier = identifier
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            logger.debug("✅ Scheduled single notification in \(timeInterval) seconds.")
        } catch {
            logger.error("Error scheduling single notification: \(error.localizedDescription)")
        }
    }
    
    public static func scheduleDailyNotifications(interval: Int, startMinutes: Int, endMinutes: Int) async {
        await removeAllNotifications()

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
            content.categoryIdentifier = "CHUGS_TRACK"
            content.sound = .default

            let identifier = "drinkReminder_\(hour)_\(minute)_\(second)"
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                logger.error("Error scheduling notification: \(error.localizedDescription)")
            }
            notificationsScheduled += 1
        }

        logger.debug("✅ Scheduled \(notificationsScheduled) notifications.")
    }
}
