//
//  HydrationLogView.swift
//  Chugs
//
//  Created by Shay Blum on 22/09/2025.
//

import SwiftUI

// HydrationLog.swift
// SwiftUI implementation of the provided HTML UI
// iOS 15+ recommended (for some modern SwiftUI APIs)

struct DrinkTrackView: View {
    @State private var consumedLiters: Double = 1.8
    private let goalLiters: Double = 3.0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            // Main content centered vertically
            VStack(spacing: 28) {
                ZStack {
                    // Outer ring background (faint)
                    RingView(progress: 1.0)
                        .frame(width: 220, height: 220)
                        .opacity(0.12)

                    // Progress ring showing consumed/goal
                    RingView(progress: min(consumedLiters / goalLiters, 1.0))
                        .frame(width: 220, height: 220)

                    // Center text
                    VStack(spacing: 6) {
                        Text(String(format: "%.1fL", consumedLiters))
                            .font(.system(size: 36, weight: .bold))
                        Text(String(format: "/ %.0fL", goalLiters))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                VStack(spacing: 12) {
                    Button(action: {
                        // simple example: add 250ml to consumed amount
                        consumedLiters = min(consumedLiters + 0.25, goalLiters)
                    }) {
                        Text("Log Drink")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.0, green: 0.7843137389, blue: 1.0, alpha: 1.0)), Color(#colorLiteral(red: 0.0, green: 0.4470588267, blue: 0.9764705896, alpha: 1.0))]), startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(999)
                            .shadow(color: Color.primary.opacity(0.2), radius: 10, x: 0, y: 6)
                            .frame(maxWidth: 320)
                    }

                    Text("Stay refreshed and energized!")
                        .font(.system(size: 13))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(
            // background-light / background-dark analog
            (colorScheme == .dark ? Color(#colorLiteral(red: 0.05882352963, green: 0.070588238, blue: 0.1372549087, alpha: 1)) : Color(#colorLiteral(red: 0.9607843161, green: 0.9725490212, blue: 0.9725490212, alpha: 1)))
                .edgesIgnoringSafeArea(.all)
        )
    }
}

// MARK: - RingView
struct RingView: View {
    var progress: Double // 0.0 - 1.0

    var body: some View {
        Circle()
            .trim(from: 0, to: CGFloat(progress))
            .stroke(
                AngularGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.0, green: 0.7843137389, blue: 1.0, alpha: 1.0)), Color(#colorLiteral(red: 0.0, green: 0.4470588267, blue: 0.9764705896, alpha: 1.0))]), center: .center),
                style: StrokeStyle(lineWidth: 8, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
    }
}

// MARK: - Preview
struct HydrationLogView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DrinkTrackView()
                .environment(\.colorScheme, .light)

            DrinkTrackView()
                .environment(\.colorScheme, .dark)
        }
    }
}
