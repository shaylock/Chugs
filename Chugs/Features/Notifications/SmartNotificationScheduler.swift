//
//  SmartNotificationScheduler.swift
//  Chugs
//
//  Created by Shay Blum on 08/10/2025.
//

import Foundation
import UserNotifications
import SwiftUI

enum SmartInterval: String, CaseIterable, Identifiable {
    case veryOften = "settings.notifications.type.smart.veryOften"
    case often = "settings.notifications.type.smart.often"
    case normal = "settings.notifications.type.smart.normal"
    case rarely = "settings.notifications.type.smart.rarely"
    case veryRarely = "settings.notifications.type.smart.veryRarely"
    
    var id: String { rawValue }
    
    var value: Double {
        switch self {
        case .veryOften:
            return 10.0
        case .often:
            return 20.0
        case .normal:
            return 40.0
        case .rarely:
            return 60.0
        case .veryRarely:
            return 90.0
        }
    }
}

struct SmartNotificationScheduler: NotificationScheduling {
    // AppStorage values
    @AppStorage("smartInterval") private var smartInterval: SmartInterval = .normal  // in minutes
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60     // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60        // 22:00
    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("storedDailyProgress") private var storedDailyProgress: Double = 0.0
    
    private let logger = LoggerUtilities.makeLogger(for: SmartNotificationScheduler.self)
    
    func scheduleNotifications() {
        Task {
            await NotificationUtilities.scheduleDailyNotifications(
                // todo: if fixed interval is not 60 this will break
                interval: 60, startMinutes: startMinutes, endMinutes: endMinutes
            )
            scheduleNextDynamicNotification()
        }
    }
    
    func scheduleNextDynamicNotification() {
        let hoursPassed: Double = (Double)(Calendar.current.component(.hour, from: Date()))
        let goalUntilNow = (dailyGoal / 24) * hoursPassed
        let urgency: Double = max(1, 1 - (storedDailyProgress / goalUntilNow))
        let habit: Double = HydrationManager.shared.hydrationHabits.fetchRatio(for: Date())
        let habitFactor: Double = HydrationManager.shared.hydrationHabits.fetchActivity(for: Date())
        let urgencyFactor: Double = 1 - habitFactor
        logger.debug("habit: \(habit), habitFactor: \(habitFactor), urgency: \(urgency), urgencyFactor: \(urgencyFactor)")
        let reminder = 1 - ((urgency * urgencyFactor) + (habit * habitFactor))
//        let minutesUntilNext = BuildUtilities.isDebugEnabled ? 0.1 : max(smartInterval.value * reminder, 0.5) // Minimum of 30 seconds
        let minutesUntilNext = max(smartInterval.value * reminder, 0.5) // Minimum of 30 seconds
        logger.debug("reminder: \(reminder), scheduling next smart notification in \(minutesUntilNext) minutes.")
        // todo: if fixed interval is not 60 this will break
        if minutesUntilNext < Calendar.current.minutesLeftInHour &&
            minutesUntilNext < Calendar.current.minutesLeftUntil(endMinutes) {
            Task {
                await NotificationUtilities.scheduleSingleNotificationIn(minutes: minutesUntilNext)
            }
        }
    }
    
    func rescheduleNextDynamicNotification() {
        Task {
            await NotificationUtilities.removeLastSingleNotification()
            scheduleNextDynamicNotification()
        }
    }
}
