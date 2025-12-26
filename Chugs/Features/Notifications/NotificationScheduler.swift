//
//  NotificationScheduler.swift
//  Chugs
//
//  Created by Shay Blum on 12/09/2025.
//

import Foundation
import UserNotifications

protocol NotificationScheduling {
    func scheduleNotifications()
    func scheduleNextDynamicNotification()
    func rescheduleNextDynamicNotification()
}

enum NotificationType: String, CaseIterable, Identifiable {
    case smart = "settings.notifications.type.smart"
    case interval = "settings.notifications.type.interval"
    
    var id: String { rawValue }

    func makeScheduler() -> NotificationScheduling {
        switch self {
        case .interval:
            return IntervalNotificationScheduler()
        case .smart:
            return SmartNotificationScheduler()
        }
    }
}

struct NotificationScheduler {
    public static let shared = NotificationScheduler()
}
