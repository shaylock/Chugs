//
//  AchievementHeaderView.swift
//  Chugs
//
//  Created by Shay Blum on 25/12/2025.
//

import SwiftUI

struct AchievementHeaderView: View {

    let unlockedCount: Int
    let totalCount: Int
    let streakDays: Int?

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Title
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)

                Text("Achievements")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            // Progress text
            Text("\(unlockedCount) of \(totalCount) unlocked")
                .font(.subheadline)
                .opacity(0.9)

            // Progress bar
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)

            // Optional streak
            if let streakDays = streakDays, streakDays > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)

                    Text("\(streakDays)-day streak")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.top, 4)
            }

        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue, Color.cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(20)
        .shadow(radius: 6)
        .padding(.horizontal)
    }
}

#Preview {
    AchievementHeaderView(unlockedCount: 12, totalCount: 30, streakDays: 5)
}
