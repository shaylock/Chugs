//
//  ChugsApp.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//


import SwiftUI
import UserNotifications

@main
struct ChugsApp: App {
    @StateObject private var tracker = ChugTracker()
    private let notificationDelegate: NotificationDelegate
    
    init() {
        let tracker = ChugTracker()
        _tracker = StateObject(wrappedValue: tracker)
        notificationDelegate = NotificationDelegate(tracker: tracker)
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(tracker: tracker)
                    .tabItem {
                        Label("Chugs", systemImage: "drop.fill")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
        }
    }
}
