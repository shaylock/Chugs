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
    
    @AppStorage("numberOfGulps", store: AppGroup.defaults)
    private var numberOfGulps: Double = 1.0

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
        case "TRACK":
            HydrationManager.shared.addWater(amount: gulpSize * numberOfGulps)
            notificationType.makeScheduler().rescheduleNextDynamicNotification()
            AnalyticsUtilities.trackDrink(fromNotification: true, numberOfGulps: Int(numberOfGulps))
        default:
            break
        }
        completionHandler()
    }
}
