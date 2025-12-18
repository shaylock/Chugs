//
//  SmartNotificationScheduler.swift
//  Chugs
//
//  Created by Shay Blum on 08/10/2025.
//

import Foundation
import UserNotifications
import SwiftUI

struct SmartNotificationScheduler {
    // AppStorage values
    @AppStorage("smartInterval") private var smartInterval: Double = 10.0  // in minutes
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60     // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60        // 22:00

    func scheduleNext(gulpsConsumed: Int) {
        // 1. Cancel all pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // todo: drinking 0 means smaller interval to keep up with the daily goal
        // 2. Normalize gulps count
        let normalizedGulps = max(gulpsConsumed, 1)
        
        // 3. Compute delay (minutes → seconds)
        let delayMinutes = smartInterval * Double(normalizedGulps)
        let delaySeconds = delayMinutes * 60.0
        
        // 4. Determine when the notification should fire
        let now = Date()
        let scheduledTime = now.addingTimeInterval(delaySeconds)
        
        // Get today's start and end times
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now)
        let startTime = startOfDay.addingTimeInterval(TimeInterval(startMinutes * 60))
        let endTime = startOfDay.addingTimeInterval(TimeInterval(endMinutes * 60))
        
        var triggerTime: Date
        
        // 5. If the scheduled time is *after end time*, push to next day start time
        if scheduledTime > endTime {
            triggerTime = calendar.date(byAdding: .day, value: 1, to: startTime)!
            print("⏰ Next reminder postponed to tomorrow at start hour.")
        } else {
            triggerTime = scheduledTime
        }
        
        // 6. Calculate interval from now to trigger time
        let interval = triggerTime.timeIntervalSince(now)
        guard interval > 0 else { return } // safety guard
        
        // 7. Build notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Chug 💧"
        content.body = "Stay hydrated! How many gulps did you take?"
        content.categoryIdentifier = "CHUGS_CATEGORY"
        content.sound = .default
        
        // 8. Trigger & request
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: "next_gulp_reminder", content: content, trigger: trigger)
        
        // 9. Schedule
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule next gulp notification: \(error)")
            } else {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                print("✅ Next gulp notification scheduled for \(formatter.string(from: triggerTime)) (\(normalizedGulps) gulps consumed).")
            }
        }
    }
}
