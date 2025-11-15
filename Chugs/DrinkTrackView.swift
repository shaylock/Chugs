//
//  HydrationLogView.swift
//  Chugs
//
//  Created by Shay Blum on 22/09/2025.
//

import SwiftUI


struct DrinkTrackView: View {
    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("dailyProgress") private var dailyProgress: Double = 0.0
    @AppStorage("gulpSize") private var gulpSize: Double = 10.0 / 1000.0 // 10 ml
    @State private var numberOfGulps: Double = 1.0

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            // Main content centered vertically
            VStack(spacing: 28) {
                progressView
                trackingButtonsView
            }

            Spacer()
        }
    }
    
    private var progressView: some View {
        ZStack {
            // Outer ring background (faint)
            RingView(progress: 1.0)
                .frame(width: 220, height: 220)
                .opacity(0.12)

            // Progress ring showing consumed/goal
            RingView(progress: min(dailyProgress / dailyGoal, 1.0))
                .frame(width: 220, height: 220)

            // Center text
            VStack(spacing: 6) {
                Text(String(format: "%.2fL", dailyProgress))
                    .font(.system(size: 36, weight: .bold))
                Text(String(format: "/ %.1fL", dailyGoal))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var trackingButtonsView: some View {
        VStack(spacing: 16) {
            Button(action: {
                dailyProgress += gulpSize * numberOfGulps
                print("daily progress: \(dailyProgress) / \(dailyGoal) (gulpSize: \(gulpSize), numberOfGulps: \(numberOfGulps)")
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
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    Spacer()
                    Text(String(format: "%.0f", numberOfGulps))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(UIColor.label))
                }

//                Slider(value: $numberOfGulps, in: 1...10, step: 1)
//                    .accentColor(Color(#colorLiteral(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)))
                
                PillSlider(value: $numberOfGulps,
                           range: 1...10,
                           step: 1,
                           thumbSize: 48,              // bigger thumb
                           trackHeight: 8,
                           thumbColor: Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)),
                           fillColor: Color(#colorLiteral(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)),
                           trackColor: Color.gray.opacity(0.25),
                           showValueLabels: false)
                    .frame(height: 60)
                    .padding()
            }
            .padding(.horizontal, 24)

            Button(action: {
                dailyProgress = 0.0
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
    
//    func saveWaterIntake(amountInML: Double, completion: @escaping (Bool, Error?) -> Void) {
//        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
//            return
//        }
//
//        // HK uses liters. Convert mL → L
//        let liters = amountInML / 1000.0
//        let quantity = HKQuantity(unit: .liter(), doubleValue: liters)
//
//        let now = Date()
//        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: now, end: now)
//
//        HKHealthStore().save(sample, withCompletion: completion)
//    }

}

// MARK: - RingView
struct RingView: View {
    // Settings for daily goal
    @AppStorage("dailyProgress") private var dailyProgress: Double = 3.0
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
struct DrinkTrackView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DrinkTrackView()
                .environment(\.colorScheme, .light)

            DrinkTrackView()
                .environment(\.colorScheme, .dark)
        }
    }
}

// A SwiftUI preview.
#Preview {
    DrinkTrackView()
}
