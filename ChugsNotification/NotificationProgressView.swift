//
//  NotificationProgressView.swift
//  Tipot
//
//  Created by Shay Blum on 26/12/2025.
//

import SwiftUI
import ChugsShared

public struct NotificationProgressView: View {
    @AppStorage("storedDailyProgress", store: AppGroup.defaults)
    private var storedDailyProgress: Double = 0.0
    @AppStorage("lastUpdateDay", store: AppGroup.defaults)
    private var lastUpdateDay: Date = Date.distantPast
    @AppStorage("dailyGoal", store: AppGroup.defaults)
    private var dailyGoal: Double = 2.0

    public init() {}

    public var body: some View {
        ZStack {

            // Background ring
            RingView(progress: 1.0)
                .opacity(0.12)

            // Progress ring
            RingView(progress: min(storedDailyProgress / dailyGoal, 1.0))

            VStack(spacing: 4) {
                Text(String(format: "%.2fL", storedDailyProgress))
                    .font(.system(size: 24, weight: .bold))

                Text(String(format: "/ %.1fL", dailyGoal))
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
