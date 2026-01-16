//
//  SmartNotificationScheduler.swift
//  Tipot
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
    
    var fixedInterval: Int {
        switch self {
        case .veryOften:
            return 30
        case .often:
            return 45
        case .normal:
            return 60
        case .rarely:
            return 90
        case .veryRarely:
            return 120
        }
    }
    
    var minimumDynamic: Double {
        switch self {
        case .veryOften:
            return 0.5
        case .often:
            return 5.0
        case .normal:
            return 10.0
        case .rarely:
            return 15.0
        case .veryRarely:
            return 20.0
        }
    }
}

struct SmartNotificationScheduler: NotificationScheduling {
    // AppStorage values
    @AppStorage("smartInterval") private var smartInterval: SmartInterval = .normal  // in minutes
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60     // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60        // 22:00
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    
    @AppStorage("storedDailyProgress", store: AppGroup.defaults)
    private var storedDailyProgress: Double = 0.0
    @AppStorage("dailyGoal", store: AppGroup.defaults)
    private var dailyGoal: Double = 2.0
    
    private let logger = LoggerUtilities.makeLogger(for: SmartNotificationScheduler.self)
    
    func getIntervalString() -> String {
        return smartInterval.rawValue
    }
    
    func isNotificationEnabled() -> Bool {
        return notificationsEnabled
    }
    
    func scheduleNotifications() {
        guard notificationsEnabled else { return }
        Task {
            await NotificationUtilities.scheduleDailyNotifications(
                interval: smartInterval.fixedInterval, startMinutes: startMinutes, endMinutes: endMinutes
            )
            await scheduleNextDynamicNotification()
        }
    }
    
    func scheduleNextDynamicNotification() async {
        guard notificationsEnabled else { return }
        let hoursPassed: Double = (Double)(Calendar.current.component(.hour, from: Date()))
        let goalUntilNow = (dailyGoal / 24) * hoursPassed
        let urgency: Double = max(1, 1 - (storedDailyProgress / goalUntilNow))
        let habit: Double = HydrationManager.shared.hydrationHabits.fetchRatio(for: Date())
        let habitFactor: Double = HydrationManager.shared.hydrationHabits.fetchActivity(for: Date())
        let urgencyFactor: Double = 1 - habitFactor
        logger.debug("habit: \(habit), habitFactor: \(habitFactor), urgency: \(urgency), urgencyFactor: \(urgencyFactor)")
        let reminder = 1 - ((urgency * urgencyFactor) + (habit * habitFactor))
        let minutesUntilNext = max(smartInterval.value * reminder, smartInterval.minimumDynamic)
        logger.debug("reminder: \(reminder), scheduling next smart notification in \(minutesUntilNext) minutes.")
        let timeToExistingNotification = await NotificationUtilities.timeToNextNotification() ?? .infinity
        
        guard minutesUntilNext < timeToExistingNotification else {
            logger.debug("Skipping: another notification is scheduled sooner.")
            return
        }
        guard minutesUntilNext < Calendar.current.minutesLeftUntil(endMinutes) else {
            logger.debug("Skipping: next notification would be after end time.")
            return
        }
        await NotificationUtilities.scheduleSingleNotificationIn(minutes: minutesUntilNext)
    }

    
    func rescheduleNextDynamicNotification() {
        guard notificationsEnabled else { return }
        Task {
            await NotificationUtilities.removeLastSingleNotification()
            await scheduleNextDynamicNotification()
        }
    }
}
