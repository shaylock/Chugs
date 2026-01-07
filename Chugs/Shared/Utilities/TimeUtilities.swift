//
//  TimeUtilities.swift
//  Tipot
//
//  Created by Shay Blum on 10/10/2025.
//

import SwiftUI

// todo: if fixed interval is not 60 this will break
extension Calendar {
    /// Remaining minutes until the next round hour (includes seconds)
    var minutesLeftInHour: Double {
        let now = Date()
        let minute = component(.minute, from: now)
        let second = component(.second, from: now)

        return Double(60 - minute) - Double(second) / 60
    }
    
    func minutesLeftUntil(_ minutes: Int) -> Double {
        guard minutes > 0 else { return 0 }

        let normalizedMinutes = minutes >= 1440 ? minutes % 1440 : minutes
        let targetHour = normalizedMinutes / 60
        let targetMinute = normalizedMinutes % 60

        let now = Date()

        // Build today's target date efficiently
        var components = dateComponents([.year, .month, .day], from: now)
        components.hour = targetHour
        components.minute = targetMinute
        components.second = 0

        guard let targetDate = date(from: components), targetDate > now
        else {
            return 0
        }

        return targetDate.timeIntervalSince(now) / 60.0
    }
}

struct TimeUtilities {
    public static func minutesToDate(_ minutes: Int) -> Date {
        let h = minutes / 60
        let m = minutes % 60
        return Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: Date()) ?? Date()
    }
    
    public static func dateToMinutes(_ date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }
    
    public static func upcomingSundayMidnight(from date: Date, calendar: Calendar = .current) -> Date {
        var cal = calendar
        // Force a stable week definition: Monday=2 ... Sunday=1 (ISO-like).
        cal.firstWeekday = 2

        let startOfToday = cal.startOfDay(for: date)

        // In Gregorian Calendar: Sunday = 1, Monday = 2, ... Saturday = 7
        let weekday = cal.component(.weekday, from: startOfToday)
        let daysUntilSunday = (1 - weekday + 7) % 7

        var candidate = cal.date(byAdding: .day, value: daysUntilSunday, to: startOfToday)!
        // candidate is "this week's Sunday 00:00" if daysUntilSunday == 0, otherwise upcoming Sunday.

        // Ensure it's strictly in the future relative to `date`
        if candidate <= date {
            candidate = cal.date(byAdding: .day, value: 7, to: candidate)!
        }
        return candidate
    }
}
