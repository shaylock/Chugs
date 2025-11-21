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
    @State private var tempGulpSizeInt: Int = 10
    @State private var showResetConfirmation = false
    
    var body: some View {
        NavigationView {
            Form {
                goalsSection
                notificationTimesSection
                gulpSizeSection
                resetReplayView
            }
            .navigationTitle("Settings")
        }
    }
    
    private var resetReplayView: some View {
        Section(header: Text("Reset / Replay")) {
            Button(action: {
                showResetConfirmation = true
            }) {
                Text("Reset Daily Progress")
                    .foregroundColor(dailyProgress == 0 ? .gray : .red)
            }
            .disabled(dailyProgress == 0)
            .confirmationDialog(
                "Are you sure you want to reset your daily progress? This action cannot be undone.",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    dailyProgress = 0
                    debugPrint("Daily progress reset to 0!")
                }
                Button("Cancel", role: .cancel) { }
            }
            
            Button(action: {
                hasCompletedOnboarding = false
                print("Onboarding flag reset!")
            }) {
                Text("Replay Onboarding")
                    .foregroundColor(.red)
            }
            
            Button(action: {
                tooltipsShown = false
                print("Tooltips flag reset!")
            }) {
                Text("Replay Tooltips")
                    .foregroundColor(.red)
            }
        }
    }
    
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
                
                PillSlider(value: $dailyGoal,
                           range: 1...5,
                           step: 0.1,
                           thumbSize: 48,              // bigger thumb
                           trackHeight: 8,
                           thumbColor: Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)),
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
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
