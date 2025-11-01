//
//  IntervalNotificationScheduler.swift
//  Chugs
//
//  Created by Shay Blum on 08/10/2025.
//

import SwiftUI
import UserNotifications

struct IntervalNotificationScheduler {
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60   // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60      // 22:00
    @AppStorage("interval") private var interval: Int = 30               // Minutes
    private let logger = LoggerUtilities.makeLogger(for: Self.self)
    static var shared: IntervalNotificationScheduler = .init()
       
//    // ⚙️ Testing Mode
//        print("🔧 Scheduling TEST notifications every 10 seconds...")

    func scheduleDailyNotifications() async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // Clear old notifications first
        let intervalSeconds: Int = BuildUtilities.isDebugBuild ? interval : interval * 60
        let startSeconds: Int = startMinutes * 60
        let endSeconds: Int = endMinutes * 60
        
        // Determine current time in seconds since midnight
        let now = Date()
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        let currentSeconds = (currentComponents.hour ?? 0) * 3600 +
                             (currentComponents.minute ?? 0) * 60 +
                             (currentComponents.second ?? 0)
        let effectiveStartSeconds = min(max(startSeconds, currentSeconds), endSeconds)
        
        var notificationsScheduled = 0
        let maxNotificationCount = BuildUtilities.isDebugBuild ? 10 : 64

        for currentSeconds in stride(from: effectiveStartSeconds, through: endSeconds, by: intervalSeconds) {
            if notificationsScheduled >= maxNotificationCount {
                logger.warning("Reached 64 notifications. Stopping scheduling.")
                break
            }
            
            // Compute hour, minute, second explicitly from seconds
            let hour: Int = currentSeconds / 3600
            let minute: Int = (currentSeconds % 3600) / 60
            let second: Int = currentSeconds % 60
            logger.debug("Scheduling notification for \(hour):\(minute):\(second)")

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.second = second

            // Create content
            let content = UNMutableNotificationContent()
            content.title = "Time for a drink!"
            content.body = "Stay hydrated 🥤"
            content.categoryIdentifier = "CHUGS_CATEGORY"
            content.sound = .default

            // Create request
            let identifier = "drinkReminder_\(hour)_\(minute)_\(second)"
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            // Schedule notification
            do {
                try await center.add(request)
            } catch {
                logger.error("Error scheduling notification: \(error.localizedDescription)")
            }
            notificationsScheduled += 1
        }

        logger.debug("✅ Scheduled \(notificationsScheduled) notifications.")
    }

//    private func createNextNotificationDateComponents() -> DateComponents {
//        let now = Date()
//        let calendar = Calendar.current
//        let nowMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
//        
//        var nextMinutes: Int
//        let nextSeconds: Int = BuildUtilities.isDebugEnabled ? interval : 0
//        
//        if nowMinutes >= endMinutes {
//            // After end time: schedule for start time tomorrow
//            nextMinutes = startMinutes
//        } else if nowMinutes < startMinutes {
//            // Before start time: schedule for start time today
//            nextMinutes = startMinutes
//        } else {
//            // Between start and end: schedule for next interval
//            let minutesSinceStart = nowMinutes - startMinutes
//            let intervalsPassed = (minutesSinceStart / interval) + 1
//            nextMinutes = startMinutes + intervalsPassed * interval
//            
//            // Ensure we don't go past endMinutes
//            if nextMinutes > endMinutes {
//                nextMinutes = startMinutes
//            }
//        }
//        
//        // Convert nextMinutes to DateComponents
//        var nextDateComponents = DateComponents()
//        var nextDate = now
//        if (BuildUtilities.isDebugEnabled) {
//            nextDate = calendar.date(byAdding: .second, value: nextSeconds, to: nextDate)!
//        } else {
//            nextDate = calendar.date(byAdding: .minute, value: nextMinutes, to: nextDate)!
//        }
//        
//        nextDateComponents.hour = calendar.component(.hour, from: nextDate)
//        nextDateComponents.minute = calendar.component(.minute, from: nextDate)
//        nextDateComponents.second = calendar.component(.second, from: nextDate)
//        return nextDateComponents
//    }
}
