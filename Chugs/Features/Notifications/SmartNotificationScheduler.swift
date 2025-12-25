//
//  SmartNotificationScheduler.swift
//  Chugs
//
//  Created by Shay Blum on 08/10/2025.
//

import Foundation
import UserNotifications
import SwiftUI

struct SmartNotificationScheduler: NotificationScheduling {
    // AppStorage values
    @AppStorage("smartInterval") private var smartInterval: Double = 10.0  // in minutes
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60     // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60        // 22:00
    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("storedDailyProgress") private var storedDailyProgress: Double = 0.0
    
    private let logger = LoggerUtilities.makeLogger(for: SmartNotificationScheduler.self)
    
    func scheduleNotifications() {
        Task {
            await NotificationUtilities.scheduleDailyNotifications(
                interval: 60, startMinutes: startMinutes, endMinutes: endMinutes
            )
        }
        scheduleNextDynamicNotification()
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
        let minutesUntilNext = BuildUtilities.isDebugEnabled ? 0.1 : max(smartInterval * reminder, 2.0) // Minimum 2 minutes
        logger.debug("reminder: \(reminder), scheduling next smart notification in \(minutesUntilNext) minutes.")
        Task {
            await NotificationUtilities.scheduleSingleNotificationIn(minutes: minutesUntilNext)
        }
    }
}
