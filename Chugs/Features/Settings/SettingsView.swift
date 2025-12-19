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
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60   // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60      // 22:00
    @AppStorage("gulpSize") private var gulpSize: Double = 10.0 / 1000.0 // 10 ml
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("tooltipsShown") private var tooltipsShown: Bool = false
    @AppStorage("volumeUnit") private var volumeUnitRaw: String = VolumeUnit.localeDefault.rawValue

    private var volumeUnit: VolumeUnit {
        get { VolumeUnit(rawValue: volumeUnitRaw) ?? .liters }
        set { volumeUnitRaw = newValue.rawValue }
    }
    private var gulpDisplayUnit: GulpDisplayUnit {
        switch volumeUnit {
        case .liters:
            return .milliliters
        case .ounces, .gallons:
            return .ounces
        }
    }
    private var gulpRange: ClosedRange<Int> {
        switch gulpDisplayUnit {
        case .milliliters:
            return 10...50
        case .ounces:
            return 1...6
        }
    }

    @State private var tempGulpSizeInt: Int = 10
    @State private var showResetConfirmation = false
    
    private var displayedGulpValue: Int {
        let value = Int(volumeUnit.convert(fromLiters: gulpSize))
        return max(1, min(value, 100))
    }

    private func setGulp(fromDisplayedValue value: Int) {
        let safeValue = max(1, value)

        switch volumeUnit {
        case .liters:
            gulpSize = Double(safeValue)
        case .ounces:
            gulpSize = Double(safeValue) / 33.814
        case .gallons:
            gulpSize = Double(safeValue) / 0.264172
        }
    }

    var body: some View {
        NavigationView {
            Form {
                goalsSection
                unitsSection
                notificationTimesSection
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
                    Text(dailyGoal.formattedVolume(unit: volumeUnit, fractionDigits: 1))
//                    Text(String(format: "%.1fL", dailyGoal))
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

    private var notificationTimesSection: some View {
        Section(header: Text(LocalizedStringKey("settings.notificationTimes.header"))) {
            DatePicker(LocalizedStringKey("settings.startHour"),
                       selection: Binding(
                           get: { TimeUtilities.minutesToDate(startMinutes) },
                           set: { newValue in
                               let newMinutes = TimeUtilities.dateToMinutes(newValue)
                               startMinutes = newMinutes
                               if startMinutes > endMinutes { endMinutes = startMinutes }
                           }),
                       displayedComponents: .hourAndMinute)

            DatePicker(LocalizedStringKey("settings.endHour"),
                       selection: Binding(
                           get: { TimeUtilities.minutesToDate(endMinutes) },
                           set: { newValue in
                               let newMinutes = TimeUtilities.dateToMinutes(newValue)
                               endMinutes = newMinutes
                               if endMinutes < startMinutes { startMinutes = endMinutes }
                           }),
                       displayedComponents: .hourAndMinute)
        }
    }
    
    private var gulpSizeSection: some View {
        Section(header: Text(LocalizedStringKey("settings.gulpSize.header"))) {
            Picker(
                LocalizedStringKey("settings.gulpSize.picker"),
                selection: $tempGulpSizeInt
            ) {
                ForEach(gulpRange, id: \.self) { value in
                    Text("\(value) \(gulpDisplayUnit.symbol)")
                        .tag(value)
                }
            }
            .onAppear {
                tempGulpSizeInt = gulpDisplayUnit.fromLiters(gulpSize)
            }
            .onChange(of: tempGulpSizeInt) {
                gulpSize = gulpDisplayUnit.toLiters(tempGulpSizeInt)
            }
            .onChange(of: volumeUnitRaw) {
                tempGulpSizeInt = gulpDisplayUnit.fromLiters(gulpSize)
            }
        }
    }
    
    private var unitsSection: some View {
        Section(header: Text(LocalizedStringKey("settings.units.header"))) {
            Picker(LocalizedStringKey("settings.units.picker"), selection: $volumeUnitRaw) {
                ForEach(VolumeUnit.allCases, id: \.rawValue) { unit in
                    Text(unit.symbol)
                        .tag(unit.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    SettingsView()
}

