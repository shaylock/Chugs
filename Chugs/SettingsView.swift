//
//  SettingsView.swift
//  Chugs
//
//  Created by Shay Blum on 19/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("startMinutes") private var startMinutes: Int = 8 * 60   // 08:00
    @AppStorage("endMinutes") private var endMinutes: Int = 22 * 60      // 22:00
    @AppStorage("gulpSize") private var gulpSize: Double = 10.0 / 1000.0 // 10 ml
    @State private var tempGulpSizeInt: Int = 10
    
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
    
//    // MARK: - Reminders Section
//    private var remindersSection: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            Text("Reminders")
//                .font(.headline)
//                .padding(.horizontal, 4)
//                .padding(.bottom, 8)
//
//            VStack(spacing: 0) {
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text("Reminders")
//                            .font(.system(size: 16, weight: .medium))
//
//                        Text("Daily reminders to drink water")
//                            .font(.subheadline)
//                    }
//
//                    Spacer()
//                }
//                .padding(16)
//                .overlay(Divider().offset(y: 20), alignment: .bottom)
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//        }
//    }
    
    // MARK: - Goals Section
    private var goalsSection: some View {
        Section(header: Text("Goals")) {
            VStack(spacing: 12) {
                HStack {
                    Text("Daily Water Consumption")
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    Text(String(format: "%.1fL", dailyGoal))
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Slider(value: $dailyGoal, in: 1...5, step: 0.1)
                    .accentColor(.blue)   // progress bar color
            }
            .padding(16)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
    
    private var notificationTimesSection: some View {
        Section(header: Text("Notification times")) {
            VStack(alignment: .leading, spacing: 0) {
                // Start / End hours (stored as minutes)
                DatePicker("Start hour",
                           selection: Binding(
                            get: { TimeUtilities.minutesToDate(startMinutes) },
                            set: { newValue in
                                let newMinutes = TimeUtilities.dateToMinutes(newValue)
                                startMinutes = newMinutes
                                if startMinutes > endMinutes {
                                    endMinutes = startMinutes
                                }
                            }),
                           displayedComponents: .hourAndMinute)
                
                DatePicker("End hour",
                           selection: Binding(
                            get: { TimeUtilities.minutesToDate(endMinutes) },
                            set: { newValue in
                                let newMinutes = TimeUtilities.dateToMinutes(newValue)
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
            Picker("Gulp size in ml", selection: $tempGulpSizeInt) {
                ForEach(1..<101, id: \.self) { value in
                    Text("\(value) ml").tag(value)
                }
            }
            .onChange(of: tempGulpSizeInt) {
                gulpSize = Double(tempGulpSizeInt) / 1000.0
                print("gulp size: \(gulpSize) ml")
            }
        }
    }
    
//    private var hoursSection1: some View {
//        Section(header: Text("Notification times")) {
//            VStack(alignment: .leading, spacing: 12) { // spacing between pickers
//                HStack {
//                    Text("Start hour")
//                        .frame(width: 90, alignment: .leading) // fixed label width
//                    DatePicker(
//                        "",
//                        selection: Binding(
//                            get: { startDate },
//                            set: { newValue in
//                                let newMinutes = dateToMinutes(newValue)
//                                startMinutes = newMinutes
//                                if startMinutes > endMinutes {
//                                    endMinutes = startMinutes
//                                }
//                            }),
//                        displayedComponents: .hourAndMinute
//                    )
//                    .labelsHidden()
//                }
//
//                HStack {
//                    Text("End hour")
//                        .frame(width: 90, alignment: .leading) // same fixed label width
//                    DatePicker(
//                        "",
//                        selection: Binding(
//                            get: { endDate },
//                            set: { newValue in
//                                let newMinutes = dateToMinutes(newValue)
//                                endMinutes = newMinutes
//                                if endMinutes < startMinutes {
//                                    startMinutes = endMinutes
//                                }
//                            }),
//                        displayedComponents: .hourAndMinute
//                    )
//                    .labelsHidden()
//                }
//            }
//        }
//    }

}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
