//
//  SettingsView.swift
//  Chugs
//
//  Created by Shay Blum on 19/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var isCustomGulpEnabled = false
    @State private var gulpSize = 10
    
    var body: some View {
        NavigationView {
            Form {
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
