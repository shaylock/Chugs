//
//  NotificationTrackingButtonsView.swift
//  Tipot
//
//  Created by Shay Blum on 27/12/2025.
//

import SwiftUI
import ChugsShared

struct NotificationTrackingButtonsView: View {
    @AppStorage("numberOfGulps", store: AppGroup.defaults)
    private var numberOfGulps: Double = 1.0

    @State private var didTrack = false

    public var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("track.slider.gulps")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(numberOfGulps))")
                    .font(.system(size: 16, weight: .semibold))
            }

            PillSlider(
                value: $numberOfGulps,
                range: 1...10,
                step: 1
            )
            .frame(height: 60)
        }
        .padding(.horizontal, 20)   // ✅ THIS is the key line
        .padding(.vertical, 8)      // optional, but looks nicer in notifications
    }
}


