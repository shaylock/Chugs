//
//  TrackingButtonsNotificationView.swift
//  Tipot
//
//  Created by Shay Blum on 26/12/2025.
//

import SwiftUI
import ChugsShared

struct DrinkTrackNotificationView: View {

    @State private var numberOfGulps: Double = 3

    // Temporary mock data
    private let currentLiters: Double = 1.75
    private let goalLiters: Double = 2.5

    private var progress: Double {
        min(currentLiters / goalLiters, 1.0)
    }

    var body: some View {
        VStack(spacing: 20) {
            NotificationProgressView(
                progress: progress,
                currentLiters: currentLiters,
                goalLiters: goalLiters
            )
            
            NotificationTrackingButtonsView()
        }
        .padding(.vertical, 16)
    }
}

