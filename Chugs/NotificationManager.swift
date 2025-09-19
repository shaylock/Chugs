//
//  NotificationManager.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
    }
    
    func scheduleNotification(in hours: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Chug 💧"
        content.body = "Stay hydrated! How many gulps did you take?"
        content.categoryIdentifier = "CHUGS_CATEGORY"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(hours * 5), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
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
}
