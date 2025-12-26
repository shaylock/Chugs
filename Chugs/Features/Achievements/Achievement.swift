//
//  Achievement.swift
//  Chugs
//
//  Created by Shay Blum on 25/12/2025.
//

import SwiftUI

enum AchievementType: String, Codable {
    case consistency
    case volume
    case reminders
    case habit
    case fun
}

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: AchievementType
    let goalValue: Int
    let iconName: String
}

struct AchievementProgress: Codable {
    let achievementID: String
    var currentValue: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
}

