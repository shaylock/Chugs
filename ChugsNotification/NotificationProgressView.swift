//
//  NotificationProgressView.swift
//  Tipot
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

    @AppStorage(
        "lastUpdateDay",
        store: AppGroup.defaults
    )
    private var lastUpdateDay: Date = Date.distantPast

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
        .onAppear {
            resetProgressIfNeeded()
        }
    }

    private func resetProgressIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastUpdateDay)

        guard today != lastDay else { return }

        storedDailyProgress = 0
        lastUpdateDay = today
    }
}
