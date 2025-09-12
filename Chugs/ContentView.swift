//
//  ContentView.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("chugCount") private var chugCount: Int = 0
    @State private var started = false

    var body: some View {
        VStack(spacing: 20) {
            Text("💧 Chugs")
                .font(.largeTitle)
                .bold()

            Button(started ? "Reschedule Now" : "Start Reminders") {
                NotificationScheduler.scheduleNext(in: 10) // quick test: 10 seconds
                started = true
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(Capsule())

            Text("Chugs so far: \(chugCount)")
                .font(.headline)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding()
    }
}
