//
//  DrinkTrackView.swift
//  Chugs
//
//  Created by Shay Blum on 22/09/2025.
//

import SwiftUI

struct DrinkTrackView: View {
    // MARK: - Mode
    var demoMode: Bool = false   // 🆕 Allows safe “sandbox” behavior for onboarding

    // MARK: - Persistent storage (used in live mode)
    @AppStorage("dailyGoal") private var storedDailyGoal: Double = 3.0
    @AppStorage("dailyProgress") private var storedDailyProgress: Double = 0.0
    @AppStorage("gulpSize") private var storedGulpSize: Double = 10.0 / 1000.0 // 10 ml

    // MARK: - Local state (used in demo mode)
    @State private var localDailyGoal: Double = 3.0
    @State private var localDailyProgress: Double = 0.0
    @State private var localGulpSize: Double = 10.0 / 1000.0
    @State private var numberOfGulps: Double = 1.0
    
    private var dailyGoalBinding: Binding<Double> {
        demoMode ? $localDailyGoal : $storedDailyGoal
    }

    private var dailyProgressBinding: Binding<Double> {
        demoMode ? $localDailyProgress : $storedDailyProgress
    }

    private var gulpSizeBinding: Binding<Double> {
        demoMode ? $localGulpSize : $storedGulpSize
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                progressView
                trackingButtonsView
            }

            Spacer()
        }
        .overlay(
            demoMode ?
                Text("Demo Mode")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.top, 10)
                    .padding(.trailing, 10)
                : nil,
            alignment: .topTrailing
        )
    }

    // MARK: - Components
    private var progressView: some View {
        ZStack {
            RingView(progress: 1.0)
                .frame(width: 220, height: 220)
                .opacity(0.12)

//            RingView(progress: min(dailyProgress / dailyGoal, 1.0))
//                .frame(width: 220, height: 220)
            RingView(progress: min(dailyProgressBinding.wrappedValue / dailyGoalBinding.wrappedValue, 1.0))
                .frame(width: 220, height: 220)

            VStack(spacing: 6) {
                Text(String(format: "%.2fL", dailyProgressBinding.wrappedValue))
                    .font(.system(size: 36, weight: .bold))
                Text(String(format: "/ %.1fL", dailyGoalBinding.wrappedValue))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var trackingButtonsView: some View {
        VStack(spacing: 16) {
//            Button(action: {
////                dailyProgress += gulpSize * numberOfGulps
//                dailyProgressBinding.wrappedValue += gulpSizeBinding.wrappedValue * numberOfGulps
//                if demoMode {
//                    // Add a small playful animation or log in demo mode
//                    print("[Demo] Incremented progress: \(dailyProgress)")
//                }
//            }) {
//                Text("Chug! 💧")
//                    .font(.system(size: 16, weight: .bold))
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 14)
//                    .background(
//                        LinearGradient(
//                            gradient: Gradient(colors: [
//                                Color(#colorLiteral(red: 0.0, green: 0.7843137389, blue: 1.0, alpha: 1.0)),
//                                Color(#colorLiteral(red: 0.0, green: 0.4470588267, blue: 0.9764705896, alpha: 1.0))
//                            ]),
//                            startPoint: .leading, endPoint: .trailing
//                        )
//                    )
//                    .foregroundColor(.white)
//                    .cornerRadius(999)
//                    .shadow(color: Color.primary.opacity(0.2), radius: 10, x: 0, y: 6)
//                    .frame(maxWidth: 320)
//            }
            Button(action: {
                dailyProgressBinding.wrappedValue += gulpSizeBinding.wrappedValue * numberOfGulps
                if demoMode {
                    print("[Demo] Incremented progress: \(dailyProgressBinding.wrappedValue)")
                }
            }) {
                Text("Chug! 💧")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(#colorLiteral(red: 0.0, green: 0.7843137389, blue: 1.0, alpha: 1.0)),
                                Color(#colorLiteral(red: 0.0, green: 0.4470588267, blue: 0.9764705896, alpha: 1.0))
                            ]),
                            startPoint: .leading, endPoint: .trailing
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
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    Spacer()
                    Text(String(format: "%.0f", numberOfGulps))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(UIColor.label))
                }

                Slider(value: $numberOfGulps, in: 1...10, step: 1)
                    .accentColor(Color(#colorLiteral(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)))
            }
            .padding(.horizontal, 24)

            if !demoMode {
                Button(action: {
                    dailyProgressBinding.wrappedValue = 0.0
                }) {
                    Text("Reset Progress")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)),
                                    Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
                                ]),
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(999)
                        .shadow(color: Color.primary.opacity(0.2), radius: 10, x: 0, y: 6)
                        .frame(maxWidth: 200)
                }
            }
        }
    }
}

// MARK: - RingView
struct RingView: View {
    var progress: Double // 0.0 - 1.0

    var body: some View {
        Circle()
            .trim(from: 0, to: CGFloat(progress))
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color(#colorLiteral(red: 0.0, green: 0.7843137389, blue: 1.0, alpha: 1.0)),
                        Color(#colorLiteral(red: 0.0, green: 0.4470588267, blue: 0.9764705896, alpha: 1.0))
                    ]),
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 8, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
    }
}

// MARK: - Previews
#Preview("Live Mode (default)") {
    DrinkTrackView()
        .environment(\.colorScheme, .light)
}

#Preview("Demo Mode (onboarding)") {
    DrinkTrackView(demoMode: true)
        .environment(\.colorScheme, .light)
        .frame(height: 400)
        .padding()
}
