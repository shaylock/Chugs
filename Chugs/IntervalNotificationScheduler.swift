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
    // 👇 Add a debug flag
    private let isTesting = true
    
    func scheduleNext() {
        let center = UNUserNotificationCenter.current()
        
        // 1. Clear all pending notifications for this app
        center.removeAllPendingNotificationRequests()
        
        // 2. Request authorization (safe to call repeatedly)
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted, error == nil else {
                print("Notification permission not granted or error: \(String(describing: error))")
                return
            }
            
            
            // 3. Schedule notifications for today within time window
            if isTesting {
                scheduleTestNotifications(center: center)
            } else {
                scheduleTodayNotifications(center: center)
            }
//            scheduleTodayNotifications(center: center)
            
            // 4. Schedule reschedule job for next day at midnight
//            scheduleRescheduleAtMidnight(center: center)
        }
    }
    
    private func scheduleTodayNotifications(center: UNUserNotificationCenter) {
        let now = Date()
        let calendar = Calendar.current
        
        // Start & end times as today's date + offset
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else { return }
        let startTime = calendar.date(byAdding: .minute, value: startMinutes, to: startOfDay)!
        let endTime = calendar.date(byAdding: .minute, value: endMinutes, to: startOfDay)!
        
        var nextNotificationTime = startTime
        
        // Loop over all notification times for the day
        while nextNotificationTime <= endTime {
            if nextNotificationTime > now {
                scheduleNotification(at: nextNotificationTime, center: center)
            }
            nextNotificationTime = calendar.date(byAdding: .minute, value: interval, to: nextNotificationTime)!
        }
        
        print("Scheduled notifications from \(formatted(startTime)) to \(formatted(endTime)) every \(interval) minutes.")
    }
    
    // MARK: - ⚙️ Testing Mode
    private func scheduleTestNotifications(center: UNUserNotificationCenter) {
        print("🔧 Scheduling TEST notifications every 10 seconds...")

        for i in 1...5 {
            let content = UNMutableNotificationContent()
            content.title = "Test #\(i)"
            content.body = "This is a test notification fired after \(i * 10) seconds."
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(i * 10), repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            center.add(request) { error in
                if let error = error {
                    print("Error scheduling test notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func scheduleNotification(at date: Date, center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = "Time for a drink!"
        content.body = "Stay hydrated 🥤"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleRescheduleAtMidnight(center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = "Rescheduling daily notifications"
        content.sound = nil
        
        // Midnight trigger
        var midnightComponents = DateComponents()
        midnightComponents.hour = 0
        midnightComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: midnightComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "rescheduleDailyNotifications",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule daily rescheduler: \(error.localizedDescription)")
            }
        }
        
        print("Scheduled daily rescheduler at midnight.")
    }
    
    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
