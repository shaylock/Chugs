//
//  ChugsApp.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//


import SwiftUI
import UserNotifications

// 1️⃣ Define a Theme struct holding your colors
struct AppTheme {
    let label: Color
    let background: Color
    let accent: Color
}

// 2️⃣ Create an EnvironmentKey for the theme
private struct AppThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme(
        label: Color("Label"),
        background: Color("SystemBackground"),
        accent: Color("AccentColor")
    )
}

// 3️⃣ Add EnvironmentValues extension for easy access
extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// 4️⃣ Create a View extension for convenience
extension View {
    func appTheme(_ theme: AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}

// 5️⃣ Create a custom Text style to automatically use the theme
struct ThemedText: View {
    @Environment(\.appTheme) private var theme
    let content: String
    let font: Font
    
    init(_ content: String, font: Font = .body) {
        self.content = content
        self.font = font
    }
    
    var body: some View {
        Text(content)
            .foregroundColor(theme.label)   // Automatically uses Label color
            .font(font)
    }
}

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
//                HomeView(tracker: tracker)
//                    .tabItem {
//                        Label("Home", systemImage: "house.fill")
//                    }
                
                DrinkTrackView()
                    .tabItem {
                        Label("Drink", systemImage: "drop.fill")
                    }
                
//                ContentView(tracker: tracker)
//                    .tabItem {
//                        Label("Chugs", systemImage: "drop.fill")
//                    }
                
                NotificationSettingView()
                    .tabItem {
                        Label("Reminders", systemImage: "alarm")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .appTheme(AppTheme(
                label: Color("Label"),
                background: Color("SystemBackground"),
                accent: Color("AccentColor")
            ))
        }
    }
}
