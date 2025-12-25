//
//  NotificationSettingView.swift
//  Chugs
//
//  Created by Shay Blum on 29/09/2025.
//

import SwiftUI

struct NotificationSettingView: View {
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60   // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60      // 22:00
    @AppStorage("gulpSize") private var gulpSize: Int = 10
    @AppStorage("notificationType") private var notificationType: NotificationType = .smart
    
    @State private var useAI = true
    @State private var dailyLimit = 5
    
    private let logger = LoggerUtilities.makeLogger(for: Self.self)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                notificationTypePickerView(notificationType: $notificationType)
                notificationSettingsSectionView(notificationType: $notificationType)
                Spacer()
            }
            .navigationTitle("settings.notifications.title")
        }
    }
}

private struct notificationTypePickerView: View {
    @Binding var notificationType: NotificationType
    private let logger = LoggerUtilities.makeLogger(for: Self.self)
    
    var body: some View {
        Picker("settings.notifications.typePicker.title", selection: $notificationType) {
            ForEach(NotificationType.allCases) { type in
                Text(LocalizedStringKey(type.rawValue)).tag(type)
            }
        }
        .onChange(of: notificationType) {
            notificationType.makeScheduler().scheduleNotifications()
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

private struct notificationSettingsSectionView: View {
    @Binding var notificationType: NotificationType

    var body: some View {
        Group {
            switch notificationType {
            case .smart:
                SmartSettingsContainer()
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

struct SmartSettingsContainer: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasHealthAccess = false

    var body: some View {
        Group {
            if hasHealthAccess {
                SmartSettings()
            } else {
                SmartHealthPermissionView()
            }
        }
        .onAppear(perform: refreshAccess)
        .onChange(of: scenePhase) {
            refreshAccess()
        }
    }

    private func refreshAccess() {
        hasHealthAccess = HealthStore.shared.hasReadAccess()
    }
}


struct SmartSettings: View {
    @AppStorage("notificationType") private var notificationType: NotificationType = .smart
    @AppStorage("smartInterval") private var smartInterval: SmartInterval = .normal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("settings.notifications.smart.description")
            
            Picker("settings.notifications.smart.typePicker.title", selection: $smartInterval) {
                ForEach(SmartInterval.allCases) { type in
                    Text(LocalizedStringKey(type.rawValue)).tag(type)
                }
            }
            .onChange(of: smartInterval) {
                notificationType.makeScheduler().scheduleNotifications()
            }
            .pickerStyle(.inline)
            .padding()
        }
    }
}

struct SmartHealthPermissionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("settings.notifications.smart.health.description")

            VStack(alignment: .leading, spacing: 8) {
                Label(
                    "settings.notifications.smart.health.step.settings",
                    systemImage: "chevron.forward"
                )
                Label(
                    "settings.notifications.smart.health.step.health",
                    systemImage: "chevron.forward"
                )
                Label(
                    "settings.notifications.smart.health.step.enable",
                    systemImage: "chevron.forward"
                )
            }
            .font(.footnote)
            .foregroundColor(.secondary)

            Button(action: openAppSettings) {
                Text("settings.notifications.smart.health.enableButton")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
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
                    .cornerRadius(999)
                    .frame(maxWidth: 320)
            }
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct IntervalSettingsView: View {
    @AppStorage("notificationType") private var notificationType: NotificationType = .smart
    @AppStorage("interval") private var interval: Int = 30
    @State private var tempInterval: Int = 30
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            Picker("settings.notifications.intervalPicker.title", selection: $tempInterval) {
                ForEach(Array(stride(from: 5, through: 120, by: 5)), id: \.self) { minutes in
                    Text(String(format: NSLocalizedString("settings.notifications.intervalPicker.minutes", comment: ""), minutes))
                        .tag(minutes)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxWidth: .infinity, maxHeight: 150)
            
            Text("settings.notifications.interval.description")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button(action: {
                interval = tempInterval
                guard notificationType == .interval else { return }
                notificationType.makeScheduler().scheduleNotifications()
            }) {
                Text("settings.notifications.confirmButton")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(
                        Group {
                            if tempInterval == interval {
                                Color(.systemGray4)
                            } else {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(#colorLiteral(red: 0.0, green: 0.7843137389, blue: 1.0, alpha: 1.0)),
                                        Color(#colorLiteral(red: 0.0, green: 0.4470588267, blue: 0.9764705896, alpha: 1.0))
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )
                    .cornerRadius(999)
                    .shadow(color: Color.primary.opacity(0.2), radius: 10, x: 0, y: 6)
                    .frame(maxWidth: 320)
                    .animation(.easeInOut(duration: 0.2), value: tempInterval != interval)
            }
            .disabled(tempInterval == interval)
        }
        .padding()
        .onAppear { tempInterval = interval }
    }
}

#Preview {
    NotificationSettingView()
}
