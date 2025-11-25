//
//  NotificationDelegate.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//

import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    @AppStorage("dailyProgress") private var dailyProgress: Double = 0.0
    @AppStorage("gulpSize") private var gulpSize: Double = 10.0 / 1000.0 // 10 ml
    
    override init() {
        super.init()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "CHUG_1":
            HydrationManager.shared.addWater(amount: gulpSize)
        case "CHUG_2":
            HydrationManager.shared.addWater(amount: gulpSize * 2.0)
        case "CHUG_3":
            HydrationManager.shared.addWater(amount: gulpSize * 3.0)
        case "CHUG_4":
            HydrationManager.shared.addWater(amount: gulpSize * 4.0)
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
