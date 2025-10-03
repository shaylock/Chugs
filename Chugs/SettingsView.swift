//
//  SettingsView.swift
//  Chugs
//
//  Created by Shay Blum on 19/09/2025.
//

import SwiftUI

struct SettingsView: View {
    // Settings for daily goal
    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    
    // Settings for notifications
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60   // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60      // 22:00
    
    // Gulp settings
    @AppStorage("gulpSize") private var gulpSize: Int = 10
    
    
    
    
    
    // Settings for manual input of gulp size
    @AppStorage("remindersEnabled") private var isRemindersEnabled: Bool = false
    @AppStorage("isCustomGulpEnabled") private var isCustomGulpEnabled: Bool = false
    // todo: Settings for automatic gulp size calculation
    
    
    
    // Helpers: convert between Int minutes and Date for the pickers
    private var startDate: Date {
        minutesToDate(startMinutes)
    }
    private var endDate: Date {
        minutesToDate(endMinutes)
    }
    
    private func minutesToDate(_ minutes: Int) -> Date {
        let h = minutes / 60
        let m = minutes % 60
        return Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: Date()) ?? Date()
    }
    
    private func dateToMinutes(_ date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }
    
    var body: some View {
        NavigationView {
            Form {
                goalsSection
                notificationTimesSection
                gulpSizeSection
            }
            .navigationTitle("Settings")
        }
    }
    
    // MARK: - Reminders Section
    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Reminders")
                .font(.headline)
//                .foregroundColor(foregroundColor)
                .padding(.horizontal, 4)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Reminders")
                            .font(.system(size: 16, weight: .medium))
//                            .foregroundColor(foregroundColor)

                        Text("Daily reminders to drink water")
                            .font(.subheadline)
//                            .foregroundColor(foregroundMutedColor)
                    }

                    Spacer()

                    Toggle("", isOn: $isRemindersEnabled)
                        .labelsHidden()
//                        .toggleStyle(SwitchToggleStyle(tint: .primaryColor))
                }
                .padding(16)
                .overlay(Divider().offset(y: 20), alignment: .bottom)

//                NavigationLink(destination: ScheduleView()) {
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text("Schedule")
//                                .font(.system(size: 16, weight: .medium))
////                                .foregroundColor(foregroundColor)
//                            Text("Customize your reminder schedule")
//                                .font(.subheadline)
////                                .foregroundColor(foregroundMutedColor)
//                        }
//                        Spacer()
//                        Image(systemName: "chevron.right")
////                            .foregroundColor(foregroundMutedColor)
//                    }
//                    .padding(16)
//                }
            }
//            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//            .shadow(color: shadowColor, radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Goals Section
    private var goalsSection: some View {
        Section(header: Text("Goals")) {
//            VStack(alignment: .leading, spacing: 12) {
//                Text("Daily water consumption")
//                    .font(.headline)
//                //                .foregroundColor(foregroundColor)
//                    .padding(.horizontal, 4)
//                    .padding(.bottom, 8)
                
            VStack(spacing: 12) {
                HStack {
                    Text("Daily Water Consumption")
                        .font(.system(size: 16, weight: .medium))
                    //                        .foregroundColor(foregroundColor)
                    Spacer()
                    Text(String(format: "%.1fL", dailyGoal))
                        .font(.system(size: 16, weight: .semibold))
                    //                        .foregroundColor(.primaryColor)
                }
                
                Slider(value: $dailyGoal, in: 1...5, step: 0.1)
                    .accentColor(.blue)   // progress bar color
            }
            .padding(16)
            //            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            //            .shadow(color: shadowColßor, radius: 2, x: 0, y: 1)
//            }
        }
    }
    
    private var notificationTimesSection: some View {
        Section(header: Text("Notification times")) {
            VStack(alignment: .leading, spacing: 0) {
                // Start / End hours (stored as minutes)
                DatePicker("Start hour",
                           selection: Binding(
                            get: { startDate },
                            set: { newValue in
                                let newMinutes = dateToMinutes(newValue)
                                startMinutes = newMinutes
                                if startMinutes > endMinutes {
                                    endMinutes = startMinutes
                                }
                            }),
                           displayedComponents: .hourAndMinute)
                
                DatePicker("End hour",
                           selection: Binding(
                            get: { endDate },
                            set: { newValue in
                                let newMinutes = dateToMinutes(newValue)
                                endMinutes = newMinutes
                                if endMinutes < startMinutes {
                                    startMinutes = endMinutes
                                }
                            }),
                           displayedComponents: .hourAndMinute)
            }
        }
    }
    
    private var gulpSizeSection: some View {
        Section(header: Text("Gulp size")) {
            Picker("Gulp size in ml", selection: $gulpSize) {
                ForEach(1..<101, id: \.self) { value in
                    Text("\(value) ml").tag(value)
                }
            }
        }
    }
    
    private var hoursSection1: some View {
        Section(header: Text("Notification times")) {
            VStack(alignment: .leading, spacing: 12) { // spacing between pickers
                HStack {
                    Text("Start hour")
                        .frame(width: 90, alignment: .leading) // fixed label width
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { startDate },
                            set: { newValue in
                                let newMinutes = dateToMinutes(newValue)
                                startMinutes = newMinutes
                                if startMinutes > endMinutes {
                                    endMinutes = startMinutes
                                }
                            }),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }

                HStack {
                    Text("End hour")
                        .frame(width: 90, alignment: .leading) // same fixed label width
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { endDate },
                            set: { newValue in
                                let newMinutes = dateToMinutes(newValue)
                                endMinutes = newMinutes
                                if endMinutes < startMinutes {
                                    startMinutes = endMinutes
                                }
                            }),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
            }
        }
    }

}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
