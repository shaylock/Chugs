//
//  NotificationDelegate.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//

import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    let tracker: ChugTracker
    init(tracker: ChugTracker) { self.tracker = tracker }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "CHUG_1":
            tracker.addChug(amount: 1)
        case "CHUG_2":
            tracker.addChug(amount: 2)
        case "CHUG_3":
            tracker.addChug(amount: 3)
        case "CHUG_4":
            tracker.addChug(amount: 4)
        case "CHUG_MORE":
            // Opens the app, nothing extra yet
            print("Opening app for more gulps…")
        case "NOT_NOW":
            print("Skipped chug")
        default:
            break
        }
        completionHandler()
    }
}
