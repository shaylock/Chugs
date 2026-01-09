//
//  SettingsView.swift
//  Tipot
//
//  Created by Shay Blum on 19/09/2025.
//

import SwiftUI
import ChugsShared

struct SettingsView: View {
    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("dailyProgress") private var dailyProgress: Double = 0.0
    @AppStorage("gulpSize") private var gulpSize: Double = 10.0 / 1000.0 // 10 ml
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("tooltipsShown") private var tooltipsShown: Bool = false

    @State private var tempGulpSizeInt: Int = 10
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                goalsSection
                NotificationSection()
                gulpSizeSection()
                resetReplaySection
                feedbackSection
                aboutSection
            }
            .navigationTitle(LocalizedStringKey("settings.title"))
        }
    }

    private var resetReplaySection: some View {
        Section(header: Text(LocalizedStringKey("settings.resetReplay.header"))) {
            Button {
                hasCompletedOnboarding = false
            } label: {
                Text(LocalizedStringKey("settings.replayOnboarding"))
                    .foregroundColor(.red)
            }

            Button {
                tooltipsShown = false
            } label: {
                Text(LocalizedStringKey("settings.replayTooltips"))
                    .foregroundColor(.red)
            }
        }
    }
    
    private var feedbackSection: some View {
        Section {
            NavigationLink {
                FeedbackView()
            } label: {
                Label(
                    LocalizedStringKey("settings.feedback.title"),
                    systemImage: "bubble.left"
                )
            }
        }
    }
    
    private var aboutSection: some View {
        Section {
            NavigationLink {
                AboutView()
            } label: {
                Label(
                    LocalizedStringKey("settings.about.title"),
                    systemImage: "info.circle"
                )
            }
        }
    }


    private var goalsSection: some View {
        Section(header: Text(LocalizedStringKey("settings.goals.header"))) {
            VStack(spacing: 12) {
                HStack {
                    Text(LocalizedStringKey("settings.goals.dailyWaterConsumption"))
                    Spacer()
                    Text(String(format: "%.1fL", dailyGoal))
                }

                PillSlider(value: $dailyGoal,
                           range: 1...5,
                           step: 0.1,
                           thumbSize: 48,
                           trackHeight: 8,
                           thumbColor: Color(#colorLiteral(red: 0.47, green: 0.84, blue: 0.97, alpha: 1)),
                           fillColor: Color(#colorLiteral(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)),
                           trackColor: Color.gray.opacity(0.25),
                           showValueLabels: false)
                    .frame(height: 60)
            }
            .padding(16)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

struct gulpSizeSection: View {
    @AppStorage("gulpSize") private var gulpSize: Double = 10.0 / 1000.0 // liters
    
    private var gulpSizeInML: Binding<Int> {
        Binding(
            get: {
                Int((gulpSize * 1000).rounded())
            },
            set: { newValue in
                gulpSize = Double(newValue) / 1000.0
            }
        )
    }
    
    var body: some View {
        Section(header: Text(LocalizedStringKey("settings.gulpSize.header"))) {
            Picker(LocalizedStringKey("settings.gulpSize.picker"), selection: gulpSizeInML) {
                ForEach(1..<101, id: \.self) { value in
                    Text("\(value) ml").tag(value)
                }
            }
        }
    }
}

struct NotificationSection: View {
    @AppStorage("notificationType") private var notificationType: NotificationType = .smart
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60   // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60      // 22:00
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true

    @State private var draftStartMinutes: Int = 8 * 60
    @State private var draftEndMinutes: Int = 22 * 60

    private let logger = LoggerUtilities.makeLogger(for: Self.self)

    private var hasChanges: Bool {
        draftStartMinutes != startMinutes ||
        draftEndMinutes != endMinutes
    }

    var body: some View {
        Section(header: Text("settings.notificationTimes.header")) {

            Toggle("settings.notifications.enable", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { _, newValue in
                    handleNotificationToggleChange(isEnabled: newValue)
                }

            DatePicker(
                "settings.startHour",
                selection: Binding(
                    get: { TimeUtilities.minutesToDate(draftStartMinutes) },
                    set: updateStartTime
                ),
                displayedComponents: .hourAndMinute
            )

            DatePicker(
                "settings.endHour",
                selection: Binding(
                    get: { TimeUtilities.minutesToDate(draftEndMinutes) },
                    set: updateEndTime
                ),
                displayedComponents: .hourAndMinute
            )

            Button(action: confirmChanges) {
                Text("settings.notifications.confirmButton")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(buttonBackground)
                    .cornerRadius(999)
                    .shadow(
                        color: hasChanges ? Color.primary.opacity(0.2) : .clear,
                        radius: 10,
                        x: 0,
                        y: 6
                    )
            }
            .frame(maxWidth: 320)
            .disabled(!hasChanges)
            .animation(.easeInOut(duration: 0.2), value: hasChanges)
        }
        .onAppear(perform: loadDraftValues)
    }
}

private extension NotificationSection {

    func loadDraftValues() {
        draftStartMinutes = startMinutes
        draftEndMinutes = endMinutes
    }

    func updateStartTime(_ date: Date) {
        let minutes = TimeUtilities.dateToMinutes(date)
        draftStartMinutes = minutes
        if draftStartMinutes > draftEndMinutes {
            draftEndMinutes = draftStartMinutes
        }
    }

    func updateEndTime(_ date: Date) {
        let minutes = TimeUtilities.dateToMinutes(date)
        draftEndMinutes = minutes
        if draftEndMinutes < draftStartMinutes {
            draftStartMinutes = draftEndMinutes
        }
    }

    func confirmChanges() {
        startMinutes = draftStartMinutes
        endMinutes = draftEndMinutes
        notificationType
            .makeScheduler()
            .scheduleNotifications()
    }

    func handleNotificationToggleChange(isEnabled: Bool) {
        AnalyticsUtilities.trackNotificationToggleChanged(notificationType: notificationType, isEnabled: isEnabled)
        if isEnabled {
            Task {
                let granted = await NotificationPermission.shared
                    .requestNotificationPermission(promptIfNeeded: true)

                if granted {
                    notificationType.makeScheduler().scheduleNotifications()
                } else {
                    await MainActor.run {
                        notificationsEnabled = false
                    }
                }
            }
        } else {
            Task {
                await NotificationUtilities.removeAllNotifications()
            }
        }
    }

    var buttonBackground: some View {
        Group {
            if hasChanges {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(#colorLiteral(red: 0.0, green: 0.7843137389, blue: 1.0, alpha: 1.0)),
                        Color(#colorLiteral(red: 0.0, green: 0.4470588267, blue: 0.9764705896, alpha: 1.0))
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            } else {
                Color(.systemGray4)
            }
        }
    }
}


#Preview {
    SettingsView()
}

