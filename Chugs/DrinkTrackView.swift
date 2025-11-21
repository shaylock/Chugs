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
    @AppStorage("lastProgressDate") private var lastProgressDate: String = ""
    @AppStorage("tooltipsShown") private var tooltipsShown: Bool = false

    @State private var numberOfGulps: Double = 1.0
    @State private var tooltipIndex: Int = 0
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            mainContent
                .disabled(showingTooltip) // disable interactions when tooltip is active
            
            if showingTooltip {
                tooltipOverlay
            }
        }
        .onAppear { resetIfNewDay() }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { resetIfNewDay() }
        }
    }
    
    // MARK: - Main content
    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 28) {
                progressView
                trackingButtonsView
            }
            
            Spacer()
        }
    }
    
    private var showingTooltip: Bool {
        !tooltipsShown && tooltipIndex < 3
    }
    
    // MARK: - Tooltip overlay
    private var tooltipOverlay: some View {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                tooltipIndex += 1
                if tooltipIndex >= 3 {
                    tooltipsShown = true
                }
            }
            .overlay(
                Group {
                    switch tooltipIndex {
                    case 0:
                        TooltipView(text: "This ring shows your progress towards your daily goal!", target: .circle)
                    case 1:
                        TooltipView(text: "Tap this button to log a gulp!", target: .chugButton)
                    case 2:
                        TooltipView(text: "Use this slider to select the number of gulps.", target: .slider)
                    default:
                        EmptyView()
                    }
                }
            )
    }
    
    // MARK: - Progress view
    private var progressView: some View {
        ZStack {
            RingView(progress: 1.0)
                .frame(width: 220, height: 220)
                .opacity(0.12)
            RingView(progress: min(dailyProgress / dailyGoal, 1.0))
                .frame(width: 220, height: 220)
            
            VStack(spacing: 6) {
                Text(String(format: "%.2fL", dailyProgress))
                    .font(.system(size: 36, weight: .bold))
                Text(String(format: "/ %.1fL", dailyGoal))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Buttons and slider
    private var trackingButtonsView: some View {
        VStack(spacing: 16) {
            Button(action: {
                dailyProgress += gulpSize * numberOfGulps
            }) {
                (Text("button_chug") + Text(" 💧"))
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
                    Text("slider_gulps")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    Spacer()
                    Text(String(format: "%.0f", numberOfGulps))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(UIColor.label))
                }
                
                PillSlider(value: $numberOfGulps,
                           range: 1...10,
                           step: 1,
                           thumbSize: 48,
                           trackHeight: 8,
                           thumbColor: Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)),
                           fillColor: Color(#colorLiteral(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)),
                           trackColor: Color.gray.opacity(0.25),
                           showValueLabels: false)
                    .frame(height: 60)
                    .padding()
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func resetIfNewDay() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if lastProgressDate != today {
            dailyProgress = 0.0
            lastProgressDate = today
        }
    }
}

// MARK: - Tooltip View
struct TooltipView: View {
    enum Target { case circle, chugButton, slider }
    
    let text: String
    let target: Target
    
    var body: some View {
        VStack {
            if target == .circle { Spacer().frame(height: 120) } // roughly center
            else if target == .chugButton { Spacer().frame(height: 300) }
            else if target == .slider { Spacer().frame(height: 400) }
            
            Text(text)
                .font(.headline)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 6)
            
            Spacer()
        }
        .padding()
        .transition(.opacity)
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
