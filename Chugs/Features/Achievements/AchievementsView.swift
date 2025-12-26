//
//  AchievementsView.swift
//  Chugs
//
//  Created by Shay Blum on 25/12/2025.
//

import SwiftUI

struct AchievementsView: View {
    let achievements: [Achievement]
    let progress: [String: AchievementProgress]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

//                AchievementHeaderView(
//                    unlockedCount: 7,
//                    totalCount: achievements.count
//                )

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(achievements) { achievement in
                        AchievementCardView(
                            achievement: achievement,
                            progress: progress[achievement.id]
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Achievements")
    }
}

//#Preview {
//    AchievementsView()
//}
