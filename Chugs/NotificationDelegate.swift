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
    
    let tracker: ChugTracker
    
    init(tracker: ChugTracker) {
        self.tracker = tracker
        super.init()
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // Request permission if not asked before
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if !granted {
                        self.promptToOpenSettings()
                    }
                }
            case .denied:
                // Already denied, prompt to open settings
                self.promptToOpenSettings()
            case .authorized, .provisional, .ephemeral:
                // Permission granted, nothing to do
                break
            @unknown default:
                break
            }
        }
    }
    
    private func promptToOpenSettings() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else { return }
            
            let alert = UIAlertController(
                title: "Notifications Disabled",
                message: "To receive chug reminders, please enable notifications in Settings.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            
            rootVC.present(alert, animated: true)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "CHUG_1":
            dailyProgress += gulpSize
        case "CHUG_2":
            dailyProgress += gulpSize * 2.0
        case "CHUG_3":
            dailyProgress += gulpSize * 3.0
        case "CHUG_4":
            dailyProgress += gulpSize * 4.0
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
