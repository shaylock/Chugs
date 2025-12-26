//
//  AchievementCardView.swift
//  Chugs
//
//  Created by Shay Blum on 25/12/2025.
//

import SwiftUI

struct AchievementCardView: View {
    let achievement: Achievement
    let progress: AchievementProgress?

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.iconName)
                .font(.largeTitle)
                .foregroundColor(progress?.isUnlocked == true ? .blue : .gray)

            Text(achievement.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            if progress?.isUnlocked == false {
                ProgressView(
                    value: Double(progress?.currentValue ?? 0),
                    total: Double(achievement.goalValue)
                )
            } else {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

#Preview {
    AchievementCardView(
        achievement: Achievement(
            id: "achievement1",
            title: "First Chug",
            description: "Complete your first chug",
            type: .volume,
            goalValue: 1,
            iconName: "star.fill"
        ),
        progress: AchievementProgress(
            achievementID: "achievement1",
            currentValue: 0,
            isUnlocked: false
        )
    )
}
    
