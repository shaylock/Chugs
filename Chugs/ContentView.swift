//
//  ContentView.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var tracker: ChugTracker
    @State private var interval = 1
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("💧 Chugs")
                    .font(.largeTitle)
                
                Stepper("Reminder every \(interval) hrs", value: $interval, in: 1...6)
                
                Button("Set Reminder") {
                    NotificationManager.shared.scheduleNotifications()
                }
                .buttonStyle(.borderedProminent)
                
                ProgressView(value: Double(tracker.dailyGulps), total: Double(tracker.goal))
                    .padding()
                
                Text("Today's water intake: \(tracker.dailyGulps)/\(tracker.goal)")
            }
            .padding()
            .onAppear {
                NotificationManager.shared.requestPermission()
                NotificationManager.shared.setupActions()
            }
            .navigationTitle("Chugs")
        }
    }
}
