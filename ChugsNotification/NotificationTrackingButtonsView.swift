//
//  NotificationTrackingButtonsView.swift
//  Chugs
//
//  Created by Shay Blum on 27/12/2025.
//

import SwiftUI
import ChugsShared

struct NotificationTrackingButtonsView: View {

    @State private var numberOfGulps: Double = 3
    @State private var didTrack = false

    public var body: some View {
        // Track + slider section
        VStack(spacing: 16) {
            Button {
                // TODO: REPLACE
                print("💧 Track button tapped with \(Int(numberOfGulps)) gulps")

                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    didTrack = true
                }

                // Reset after short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        didTrack = false
                    }
                }

            } label: {
                Text(didTrack ? NSLocalizedString("track.button.great", comment: "") + " ✓" :
                        NSLocalizedString("track.button.chug", comment: "") + " 💧")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: didTrack
                                ? [Color.green.opacity(0.9), Color.green]
                                : [
                                    Color(red: 0.0, green: 0.78, blue: 1.0),
                                    Color(red: 0.0, green: 0.45, blue: 0.98)
                                  ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(999)
                    .scaleEffect(didTrack ? 0.97 : 1.0)
                    .opacity(didTrack ? 0.9 : 1.0)
            }
            .disabled(didTrack)


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
        }
        .padding(.horizontal, 24)
    }
}

