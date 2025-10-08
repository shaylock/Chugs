//
//  TestSettingsView.swift
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
    @AppStorage("notificationType") private var notificationType: NotificationType = .smart
    
    // Smart notifications
    
    // Interval notifications
    @AppStorage("interval") private var interval: Int = 30
    
//    @State private var selectedType: NotificationType = .smart
    
    // Local state for sections
    @State private var useAI = true
    @State private var dailyLimit = 5
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                notificationTypePicker
                notificationSettingsSection
                Spacer()
            }
            .navigationTitle("Notifications")
        }
    }
}

// MARK: - Sections
private extension NotificationSettingView {
    
    var notificationTypePicker: some View {
        Picker("Notification Type", selection: $notificationType) {
            ForEach(NotificationType.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    var notificationSettingsSection: some View {
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
            Toggle("Enable AI-based timing", isOn: $useAI)
            Stepper("Daily limit: \(dailyLimit)", value: $dailyLimit, in: 1...20)
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
