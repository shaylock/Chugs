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

// Mock example manager
//final class NotificationManager {
//    static let shared = NotificationManager()
//    
//    func setNotificationType(_ type: NotificationType) {
//        print("Notification type set to \(type.rawValue)")
//        // Your logic here, e.g., update scheduled notifications
//    }
//}

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
            logger.debug("picker changed to \(notificationType.rawValue)")
            NotificationManager.shared.setNotificationType(notificationType)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

private struct notificationSettingsSectionView: View {
    @Binding var notificationType: NotificationType
    @Binding var interval: Int
    var body: some View {
        Group {
            switch notificationType {
            case .smart:
                smartSettings
            case .interval:
                intervalSettings
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    var smartSettings: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Smart notifications will trigger regular notifications based on your drinking patterns and hydration goals.")
//            Toggle("Enable AI-based timing", isOn: $useAI)
//            Stepper("Daily limit: \(dailyLimit)", value: $dailyLimit, in: 1...20)
        }
    }
    
    var intervalSettings: some View {
        VStack(alignment: .leading, spacing: 15) {
            Stepper("Every \(interval) minutes", value: $interval, in: 5...120, step: 5)
            Text("Notifications will repeat at this interval.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NotificationSettingView()
}
