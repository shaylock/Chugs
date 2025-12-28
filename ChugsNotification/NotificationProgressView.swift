//
//  NotificationProgressView.swift
//  Chugs
//
//  Created by Shay Blum on 26/12/2025.
//

import SwiftUI
import ChugsShared

public struct NotificationProgressView: View {
    @AppStorage(
        "storedDailyProgress",
        store: AppGroup.defaults
    )
    private var storedDailyProgress: Double = 0.0

    let progress: Double          // 0...1
    let currentLiters: Double
    let goalLiters: Double

    public init(
        progress: Double,
        currentLiters: Double,
        goalLiters: Double
    ) {
        self.progress = progress
        self.currentLiters = currentLiters
        self.goalLiters = goalLiters
    }

    public var body: some View {
        ZStack {

            // Background ring
            RingView(progress: 1.0)
                .opacity(0.12)

            // Progress ring
//            RingView(progress: progress)
            RingView(progress: min(storedDailyProgress / goalLiters, 1.0))

            VStack(spacing: 4) {
                Text(String(format: "%.2fL", storedDailyProgress))
                    .font(.system(size: 24, weight: .bold))

                Text(String(format: "/ %.1fL", goalLiters))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 140, height: 140)
    }
}
