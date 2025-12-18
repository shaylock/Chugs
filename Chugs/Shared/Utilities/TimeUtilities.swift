//
//  TimeUtilities.swift
//  Chugs
//
//  Created by Shay Blum on 10/10/2025.
//

import SwiftUI

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
}
