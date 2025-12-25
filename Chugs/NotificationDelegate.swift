//
//  NotificationDelegate.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//

import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    @AppStorage("gulpSize") private var gulpSize: Double = 10.0 / 1000.0 // 10 ml
    @AppStorage("notificationType") private var notificationType: NotificationType = .smart

    override init() {
        super.init()
    }

    // ✅ SHOW notification while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([
            .banner,   // show banner
            .sound,    // play sound
            .badge     // update badge (optional)
        ])
    }

    // ✅ Handle notification actions
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case "CHUG_1":
            HydrationManager.shared.addWater(amount: gulpSize)
            notificationType.makeScheduler().scheduleNextDynamicNotification()
        case "CHUG_2":
            HydrationManager.shared.addWater(amount: gulpSize * 2.0)
            notificationType.makeScheduler().scheduleNextDynamicNotification()
        case "CHUG_3":
            HydrationManager.shared.addWater(amount: gulpSize * 3.0)
            notificationType.makeScheduler().scheduleNextDynamicNotification()
        case "CHUG_4":
            HydrationManager.shared.addWater(amount: gulpSize * 4.0)
            notificationType.makeScheduler().scheduleNextDynamicNotification()
        case "CHUG_MORE":
            print("Opening app for more gulps…")
        case "NOT_NOW":
            print("Skipped chug")
        default:
            break
        }
        completionHandler()
    }
}
