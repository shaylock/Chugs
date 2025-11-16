//
//  NotificationSettingView.swift
//  Chugs
//
//  Created by Shay Blum on 29/09/2025.
//

import SwiftUI

enum NotificationType: String, CaseIterable, Identifiable {
    case smart = "Smart"
    case interval = "Interval"
    
    var id: String { rawValue }
}

struct NotificationSettingView: View {
    // Global settings
    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60   // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60      // 22:00
    @AppStorage("gulpSize") private var gulpSize: Int = 10
    
    // Notification settings
    @AppStorage("notificationType") private var notificationType: NotificationType = .smart
    @AppStorage("interval") private var interval: Int = 30
    @AppStorage("smartInterval") private var smartInterval: Double = 10 // in minutes
    
    // Local state
    @State private var useAI = true
    @State private var dailyLimit = 5
    
    private let logger = LoggerUtilities.makeLogger(for: Self.self)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                notificationTypePickerView(notificationType: $notificationType)
                notificationSettingsSectionView(notificationType: $notificationType, interval: $interval)
                Spacer()
            }
            .navigationTitle("Notifications")
        }
    }
    
    private func calculateSmartInterval() {
        let totalMl = dailyGoal * 1000.0
        guard gulpSize > 0 else { return }
        let gulpsNeeded = totalMl / Double(gulpSize)
        let totalMinutes = Double(endMinutes - startMinutes)
        
        guard gulpsNeeded > 0 else { return }
        let interval = totalMinutes / gulpsNeeded
        
        // Store in AppStorage
        smartInterval = interval
    }
}

private struct notificationTypePickerView: View {
    @Binding var notificationType: NotificationType
    private let logger = LoggerUtilities.makeLogger(for: Self.self)
    var body: some View {
        Picker("Notification Type", selection: $notificationType) {
            ForEach(NotificationType.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .onChange(of: notificationType) {
            setNotificationType()
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    private func setNotificationType() {
        logger.debug("Notification type changed to \(notificationType.rawValue)")
        switch notificationType {
        case .smart:
            let scheduler = SmartNotificationScheduler()
            scheduler.scheduleNext(gulpsConsumed: 0)
        case .interval:
            Task {
                await IntervalNotificationScheduler.shared.scheduleDailyNotifications()
            }
        }
    }
}

private struct notificationSettingsSectionView: View {
    @Binding var notificationType: NotificationType
    @Binding var interval: Int
    var body: some View {
        Group {
            switch notificationType {
            case .smart:
                SmartSettings()
            case .interval:
                IntervalSettingsView()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}


struct SmartSettings: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Smart notifications will trigger regular notifications based on your drinking patterns and hydration goals.")
        }
    }
}

struct IntervalSettingsView: View {
    @AppStorage("interval") private var interval: Int = 30
    @State private var tempInterval: Int = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Picker replacing the Stepper
            Picker("Notification Interval", selection: $tempInterval) {
                ForEach(Array(stride(from: 5, through: 120, by: 5)), id: \.self) { minute in
                    Text("\(minute) minutes")
                        .tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle()) // or .menu if you prefer a dropdown
            .frame(maxWidth: .infinity, maxHeight: 150)
            
            Text("Notifications will repeat at this interval.")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button(action: {
                interval = tempInterval // update stored interval
                Task {
                    await IntervalNotificationScheduler.shared.scheduleDailyNotifications()
                }
            }) {
                Text("Confirm")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(#colorLiteral(red: 0.0, green: 0.7843137389, blue: 1.0, alpha: 1.0)),
                                Color(#colorLiteral(red: 0.0, green: 0.4470588267, blue: 0.9764705896, alpha: 1.0))
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
            .disabled(tempInterval == interval)
            .opacity(tempInterval == interval ? 0.5 : 1)
        }
        .padding()
        .onAppear {
            tempInterval = interval
        }
    }
}


#Preview {
    NotificationSettingView()
}
