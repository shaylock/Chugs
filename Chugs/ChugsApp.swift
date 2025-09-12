//
//  ChugsApp.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//


import SwiftUI
import UserNotifications

@main
struct ChugsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Define actions
        let chugAction = UNNotificationAction(identifier: "CHUG_ACTION", title: "Chug 💦", options: [])
        let notNowAction = UNNotificationAction(identifier: "NOT_NOW", title: "Not Now ⏳", options: [])

        // Define category
        let category = UNNotificationCategory(
            identifier: "DRINK_REMINDER_CATEGORY",
            actions: [chugAction, notNowAction],
            intentIdentifiers: [],
            options: []
        )

        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
        center.delegate = self

        // Request permission
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error:", error.localizedDescription)
            } else {
                print("Permission granted:", granted)
            }
        }

        return true
    }

    // Handle actions
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case "CHUG_ACTION":
            let current = UserDefaults.standard.integer(forKey: "chugCount")
            UserDefaults.standard.set(current + 1, forKey: "chugCount")
            NotificationScheduler.scheduleNext(in: 10) // 10 minutes
        case "NOT_NOW":
            NotificationScheduler.scheduleNext(in: 5) // 5 minutes
        default:
            break
        }
        completionHandler()
    }

    // Show while in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound])
    }
}
