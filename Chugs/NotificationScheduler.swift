//
//  NotificationScheduler.swift
//  Chugs
//
//  Created by Shay Blum on 12/09/2025.
//

import Foundation
import UserNotifications

struct NotificationScheduler {
    static func scheduleNext(in seconds: TimeInterval) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Time to Drink 💧"
        content.body = "Stay hydrated and healthy!"
        content.sound = .default
        content.categoryIdentifier = "DRINK_REMINDER_CATEGORY"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "drinkReminder", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification:", error.localizedDescription)
            } else {
                print("Scheduled next reminder in \(seconds / 60) minutes")
            }
        }
    }
}
