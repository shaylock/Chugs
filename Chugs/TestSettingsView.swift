//
//  TestSettingsView.swift
//  Chugs
//
//  Created by Shay Blum on 29/09/2025.
//

import SwiftUI

struct TestSettingsView: View {
    enum NotificationType: String, CaseIterable, Identifiable {
        case smart = "Smart"
        case interval = "Interval"
        
        var id: String { rawValue }
    }
    
    @State private var selectedType: NotificationType = .smart
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Segmented Control
                Picker("Notification Type", selection: $selectedType) {
                    ForEach(NotificationType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Dynamic Content (different UI per selection)
                Group {
                    switch selectedType {
                    case .smart:
                        SmartNotificationSettingsView()
                    case .interval:
                        IntervalNotificationSettingsView()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Notifications")
        }
    }
}

// Example configuration UIs
struct SmartNotificationSettingsView: View {
    @State private var useAI = true
    @State private var dailyLimit = 5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Toggle("Enable AI-based timing", isOn: $useAI)
            Stepper("Daily limit: \(dailyLimit)", value: $dailyLimit, in: 1...20)
        }
    }
}

struct IntervalNotificationSettingsView: View {
    @State private var interval = 30
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Stepper("Every \(interval) minutes", value: $interval, in: 5...120, step: 5)
            Text("Notifications will repeat at this interval.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}
