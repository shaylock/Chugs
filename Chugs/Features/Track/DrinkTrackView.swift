//
//  HydrationLogView.swift
//  Chugs
//
//  Created by Shay Blum on 22/09/2025.
//

import SwiftUI


struct DrinkTrackView: View {
    @AppStorage("notificationType") private var notificationType: NotificationType = .smart
    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("storedDailyProgress") private var storedDailyProgress: Double = 0.0
    @AppStorage("gulpSize") private var gulpSize: Double = 10.0 / 1000.0 // 10 ml
    @AppStorage("tooltipsShown") private var tooltipsShown: Bool = false

    @State private var numberOfGulps: Double = 1.0
    @State private var tooltipIndex: Int = 0
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            mainContent
                .disabled(showingTooltip)

            if showingTooltip {
                tooltipOverlay
            }
        }
        .onAppear {
            HydrationManager.shared.fetchDailyProgress()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                HydrationManager.shared.fetchDailyProgress()
            }
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
                        TooltipView(
                            text: LocalizedStringKey("tooltip.progressRing.text"),
                            target: .circle
                        )
                    case 1:
                        TooltipView(
                            text: LocalizedStringKey("tooltip.chugButton.text"),
                            target: .chugButton
                        )
                    case 2:
                        TooltipView(
                            text: LocalizedStringKey("tooltip.slider.text"),
                            target: .slider
                        )
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
            RingView(progress: min(storedDailyProgress / dailyGoal, 1.0))
                .frame(width: 220, height: 220)
            
            VStack(spacing: 6) {
                Text(String(format: "%.2fL", storedDailyProgress))
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
                // TODO: REVERT
                UNUserNotificationCenter.current().getNotificationCategories { categories in
                    print("📦 Registered categories:")
                    categories.forEach { print("•", $0.identifier) }
                }
                NotificationManager.shared.testNotification()
                HydrationManager.shared.addWater(amount: gulpSize * numberOfGulps)
                notificationType.makeScheduler().rescheduleNextDynamicNotification()
            }) {
                (Text("track.button.chug") + Text(" 💧"))
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
                    Text("track.slider.gulps")
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
}

// MARK: - Tooltip View
struct TooltipView: View {
    enum Target { case circle, chugButton, slider }
    
    let text: LocalizedStringKey
    let target: Target
    
    var body: some View {
        VStack {
            if target == .circle { Spacer().frame(height: 120) } // roughly center
            else if target == .chugButton { Spacer().frame(height: 300) }
            else if target == .slider { Spacer().frame(height: 400) }
            
            Text(text)
                .font(.headline)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(14)
                .foregroundStyle(.primary)
                .shadow(radius: 4)
            
            Spacer()
        }
        .padding()
        .transition(.opacity)
    }
}

// MARK: - RingView
struct RingView: View {
    var progress: Double

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

#Preview {
    DrinkTrackView()
}
