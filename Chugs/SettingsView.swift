//
//  SettingsView.swift
//  Chugs
//
//  Created by Shay Blum on 19/09/2025.
//

import SwiftUI

struct SettingsView: View {
    // Persisted settings
    @AppStorage("isCustomGulpEnabled") private var isCustomGulpEnabled = false
    @AppStorage("gulpSize") private var gulpSize = 10
    
    @AppStorage("goalWhole") private var goalWhole = 2
    @AppStorage("goalFractionTenths") private var goalFractionTenths = 5
    
    // Store start & end as minutes from midnight
    @AppStorage("startMinutes") private var startMinutes = 8 * 60   // 08:00
    @AppStorage("endMinutes") private var endMinutes = 22 * 60      // 22:00
    
    private var goalValue: Double {
        Double(goalWhole) + Double(goalFractionTenths) / 10.0
    }
    
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
                // Goals section
                Section(header: Text("Goals")) {
                    // Daily water intake
                    HStack {
                        Text("Daily water intake")
                        Spacer()
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(String(format: "%.1f L", goalValue))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                Picker("", selection: $goalWhole) {
                                    ForEach(0...5, id: \.self) { value in
                                        Text("\(value)").tag(value)
                                    }
                                }
                                .labelsHidden()
                                .pickerStyle(.wheel)
                                .frame(width: 70, height: 100)
                                
                                Picker("", selection: $goalFractionTenths) {
                                    ForEach(0...9, id: \.self) { t in
                                        Text(String(format: "%.1f", Double(t) / 10.0)).tag(t)
                                    }
                                }
                                .labelsHidden()
                                .pickerStyle(.wheel)
                                .frame(width: 70, height: 100)
                            }
                        }
                    }
                    
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
                
                // Gulp measuring section
                Section(header: Text("Gulp measuring")) {
                    Toggle("Set gulp size", isOn: $isCustomGulpEnabled)
                    
                    Picker("Gulp size in ml", selection: $gulpSize) {
                        ForEach(1..<101, id: \.self) { value in
                            Text("\(value) ml").tag(value)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
