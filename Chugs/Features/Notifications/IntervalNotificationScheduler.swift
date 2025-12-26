//
//  IntervalNotificationScheduler.swift
//  Chugs
//
//  Created by Shay Blum on 08/10/2025.
//

import SwiftUI
import UserNotifications

struct IntervalNotificationScheduler: NotificationScheduling {
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60   // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60      // 22:00
    @AppStorage("interval") private var interval: Int = 30               // Minutes
    private let logger = LoggerUtilities.makeLogger(for: Self.self)
    static var shared: IntervalNotificationScheduler = .init()
    
    func scheduleNotifications() {
        Task {
            await NotificationUtilities.scheduleDailyNotifications(
                interval: interval, startMinutes: startMinutes, endMinutes: endMinutes
            )
        }
    }
    
    func scheduleNextDynamicNotification() {
    }
    
    func rescheduleNextDynamicNotification() {
    }
}
