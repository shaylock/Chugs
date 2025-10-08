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
    
    // MARK: - Request permission
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
    }
    
    // MARK: - Set up action buttons
    func setupActions() {
        let gulp1 = UNNotificationAction(identifier: "CHUG_1", title: "1 gulp", options: [])
        let gulp2 = UNNotificationAction(identifier: "CHUG_2", title: "2 gulps", options: [])
        let gulp3 = UNNotificationAction(identifier: "CHUG_3", title: "3 gulps", options: [])
        let gulp4 = UNNotificationAction(identifier: "CHUG_4", title: "4 gulps", options: [])
        let more = UNNotificationAction(identifier: "CHUG_MORE", title: "More…", options: [.foreground])
        let notNow = UNNotificationAction(identifier: "NOT_NOW", title: "Not now", options: [])

        let category = UNNotificationCategory(
            identifier: "CHUGS_CATEGORY",
            actions: [gulp1, gulp2, gulp3, gulp4, more, notNow],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func setNotificationType(_ type: NotificationType) {
        print("Notification type set to \(type.rawValue)")
        // Your logic here, e.g., update scheduled notifications
        switch type {
        case .smart:
            let scheduler = SmartNotificationScheduler()
//            scheduler.scheduleNext()
            
        case .interval:
            let scheduler = IntervalNotificationScheduler()
            scheduler.scheduleNext()
        }
    }
    
    // MARK: - Schedule notifications for the day
    func scheduleNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Load persisted settings
        let startMinutes = userDefaults.integer(forKey: "startMinutes")
        let endMinutes = userDefaults.integer(forKey: "endMinutes")
        let goalWhole = userDefaults.integer(forKey: "goalWhole")
        let goalFractionTenths = userDefaults.integer(forKey: "goalFractionTenths")
        let gulpSize = userDefaults.integer(forKey: "gulpSize")
        
        let goalMl = (Double(goalWhole) + Double(goalFractionTenths)/10.0) * 1000 // liters → ml

        // Prevent division by zero
        guard gulpSize > 0 else { return }

        let totalGulps = Int(ceil(goalMl / Double(gulpSize))) // total notifications
        let totalTimeMinutes = endMinutes - startMinutes
        guard totalTimeMinutes > 0 else { return }

        let intervalMinutes = Double(totalTimeMinutes) / Double(totalGulps)
        
        for i in 0..<totalGulps {
            let notificationMinutes = Double(startMinutes) + intervalMinutes * Double(i)
            let hour = Int(notificationMinutes) / 60
            let minute = Int(notificationMinutes) % 60
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let content = UNMutableNotificationContent()
            content.title = "Time to Chug 💧"
            content.body = "Stay hydrated! How many gulps did you take?"
            content.categoryIdentifier = "CHUGS_CATEGORY"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
}
