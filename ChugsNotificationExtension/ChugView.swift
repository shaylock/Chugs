//
//  ChugView.swift
//  Chugs
//
//  Created by Shay Blum on 10/10/2025.
//

import SwiftUI

struct ChugView: View {
    @State var dailyProgress: Double
    var gulpSize: Double
    @State var numberOfGulps: Double
    var sharedDefaults: UserDefaults?

    var body: some View {
        VStack(spacing: 16) {
            Text("Time for a drink! 💧")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 8)

            Text("Stay hydrated")
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Button(action: chugAction) {
                Text("Chug! 💧")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.78, blue: 1.0),
                                Color(red: 0.0, green: 0.45, blue: 0.98)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(999)
                    .shadow(color: Color.primary.opacity(0.2), radius: 10, x: 0, y: 6)
                    .frame(maxWidth: 320)
            }

            VStack(spacing: 6) {
                HStack {
                    Text("Gulps:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(numberOfGulps))")
                        .font(.system(size: 13, weight: .semibold))
                }

                Slider(value: $numberOfGulps, in: 1...10, step: 1)
                    .tint(Color.blue)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .padding()
    }

    private func chugAction() {
        dailyProgress += gulpSize * numberOfGulps
        sharedDefaults?.set(dailyProgress, forKey: "dailyProgress")
        sharedDefaults?.set(numberOfGulps, forKey: "numberOfGulps")
    }
}
