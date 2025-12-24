//
//  SettingsView.swift
//  Chugs
//
//  Created by Shay Blum on 19/09/2025.
//

import SwiftUI

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
                notificationTimesSection()
                gulpSizeSection
                resetReplaySection	
            }
            .navigationTitle(LocalizedStringKey("settings.title"))
        }
    }

    private var resetReplaySection: some View {
        Section(header: Text(LocalizedStringKey("settings.resetReplay.header"))) {
            Button {
                showResetConfirmation = true
            } label: {
                Text(LocalizedStringKey("settings.resetDailyProgress"))
                    .foregroundColor(dailyProgress == 0 ? .gray : .red)
            }
            .disabled(dailyProgress == 0)
            .confirmationDialog(
                LocalizedStringKey("settings.resetDailyProgress.confirmation"),
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button(LocalizedStringKey("settings.reset"), role: .destructive) {
                    dailyProgress = 0
                }
                Button(LocalizedStringKey("settings.cancel"), role: .cancel) {}
            }

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

    private var gulpSizeSection: some View {
        Section(header: Text(LocalizedStringKey("settings.gulpSize.header"))) {
            Picker(LocalizedStringKey("settings.gulpSize.picker"), selection: $tempGulpSizeInt) {
                ForEach(1..<101, id: \.self) { value in
                    Text("\(value) ml").tag(value)
                }
            }
            .onChange(of: tempGulpSizeInt) {
                gulpSize = Double(tempGulpSizeInt) / 1000.0
            }
        }
    }
}

private struct notificationTimesSection: View {
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60   // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60      // 22:00
    @State private var draftStartMinutes: Int
    @State private var draftEndMinutes: Int
    private let logger = LoggerUtilities.makeLogger(for: Self.self)
    
    init() {
        let start = UserDefaults.standard.integer(forKey: "startMinutes")
        let end = UserDefaults.standard.integer(forKey: "endMinutes")

        _draftStartMinutes = State(initialValue: start == 0 ? 8 * 60 : start)
        _draftEndMinutes = State(initialValue: end == 0 ? 22 * 60 : end)
    }
    
    private var hasChanges: Bool {
        draftStartMinutes != startMinutes ||
        draftEndMinutes != endMinutes
    }
    
    var body: some View {
        Section(header: Text(LocalizedStringKey("settings.notificationTimes.header"))) {
            DatePicker(
                LocalizedStringKey("settings.startHour"),
                selection: Binding(
                    get: { TimeUtilities.minutesToDate(draftStartMinutes) },
                    set: { newValue in
                        let newMinutes = TimeUtilities.dateToMinutes(newValue)
                        draftStartMinutes = newMinutes
                        if draftStartMinutes > draftEndMinutes {
                            draftEndMinutes = draftStartMinutes
                        }
                    }
                ),
                displayedComponents: .hourAndMinute
            )

            DatePicker(
                LocalizedStringKey("settings.endHour"),
                selection: Binding(
                    get: { TimeUtilities.minutesToDate(draftEndMinutes) },
                    set: { newValue in
                        let newMinutes = TimeUtilities.dateToMinutes(newValue)
                        draftEndMinutes = newMinutes
                        if draftEndMinutes < draftStartMinutes {
                            draftStartMinutes = draftEndMinutes
                        }
                    }
                ),
                displayedComponents: .hourAndMinute
            )
            
            Button(action: {
                startMinutes = draftStartMinutes
                endMinutes = draftEndMinutes
                Task {
                    await IntervalNotificationScheduler.shared.scheduleDailyNotifications()
                }
            }) {
                Text("settings.notifications.confirmButton")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(
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
                    )
                    .cornerRadius(999)
                    .shadow(
                        color: hasChanges ? Color.primary.opacity(0.2) : .clear,
                        radius: 10,
                        x: 0,
                        y: 6
                    )
                    .frame(maxWidth: 320)
                    .animation(.easeInOut(duration: 0.2), value: hasChanges)
            }
            .disabled(!hasChanges)
        }
    }
}

#Preview {
    SettingsView()
}

