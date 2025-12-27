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

    public var body: some View {
        // Track + slider section
        VStack(spacing: 16) {

            Button {
                print("💧 Track button tapped with \(Int(numberOfGulps)) gulps")
            } label: {
                (Text("Track") + Text(" 💧"))
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.78, blue: 1.0),
                                Color(red: 0.0, green: 0.45, blue: 0.98)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(999)
            }

            VStack(spacing: 6) {
                HStack {
                    Text("Gulps")
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

