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
       
//    // ⚙️ Testing Mode
//        print("🔧 Scheduling TEST notifications every 10 seconds...")

    func scheduleNext() async {
        logger.debug("Schedule next interval notification - interval is \(interval) minutes")
        guard await NotificationUtilities.checkPermission() else {
            logger.warning("No permission to send notifications. Skipping schedule.")
            return
        }
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for a drink!"
        content.body = "Stay hydrated 🥤"
        content.categoryIdentifier = "CHUGS_CATEGORY"
        content.sound = .default
        
        // Create trigger
        let nextDateComponents = createNextNotificationDateComponents()
        let trigger = UNCalendarNotificationTrigger(dateMatching: nextDateComponents, repeats: false)
//        logger.debug("Exact time of trigger: \(trigger)")
        
        // Create request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Schedule notification
        do {
            try await center.add(request)
            logger.info("Scheduled next notification to fire in \(nextDateComponents)")
        } catch {
            logger.error("Failed to schedule notification: \(error)")
        }
    }
    
    private func createNextNotificationDateComponents() -> DateComponents {
        let now = Date()
        let calendar = Calendar.current
        let nowMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        
        var nextMinutes: Int
        let nextSeconds: Int = BuildUtilities.isDebugEnabled ? interval : 0
        
        if nowMinutes >= endMinutes {
            // After end time: schedule for start time tomorrow
            nextMinutes = startMinutes
        } else if nowMinutes < startMinutes {
            // Before start time: schedule for start time today
            nextMinutes = startMinutes
        } else {
            // Between start and end: schedule for next interval
            let minutesSinceStart = nowMinutes - startMinutes
            let intervalsPassed = (minutesSinceStart / interval) + 1
            nextMinutes = startMinutes + intervalsPassed * interval
            
            // Ensure we don't go past endMinutes
            if nextMinutes > endMinutes {
                nextMinutes = startMinutes
            }
        }
        
        // Convert nextMinutes to DateComponents
        var nextDateComponents = DateComponents()
        var nextDate = now
        if (BuildUtilities.isDebugEnabled) {
            nextDate = calendar.date(byAdding: .second, value: nextSeconds, to: nextDate)!
        } else {
            nextDate = calendar.date(byAdding: .minute, value: nextMinutes, to: nextDate)!
        }
        
        nextDateComponents.hour = calendar.component(.hour, from: nextDate)
        nextDateComponents.minute = calendar.component(.minute, from: nextDate)
        nextDateComponents.second = calendar.component(.second, from: nextDate)
        return nextDateComponents
    }
}
