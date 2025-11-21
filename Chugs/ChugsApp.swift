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
            .foregroundColor(theme.label)
            .font(font)
    }
}

@main
struct ChugsApp: App {
    private let notificationDelegate: NotificationDelegate
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false // 🆕 persistent onboarding flag
    
    init() {
        notificationDelegate = NotificationDelegate()
        UNUserNotificationCenter.current().delegate = notificationDelegate
        
        // Request notification permission and ensure our category exists.
        if hasCompletedOnboarding {
            NotificationManager.shared.requestNotificationPermission()
            NotificationManager.shared.ensureChugsCategoryExists()
        }
        
        OnboardingPageConstants.subtitleFont = .system(size: 18)
        OnboardingPageConstants.buttonFont = .system(size: 20, weight: .semibold)
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                // Normal app flow
                MainTabView()
                    .appTheme(AppTheme(
                        label: Color("Label"),
                        background: Color("SystemBackground"),
                        accent: Color("AccentColor")
                    ))
            } else {
                // 🆕 Show onboarding until completed
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}

// 🆕 Extracted your TabView into a reusable view for clarity
struct MainTabView: View {
    var body: some View {
        TabView {
            DrinkTrackView()
                .tabItem {
                    Label("tab_drink", systemImage: "drop.fill")
                }
            
            NotificationSettingView()
                .tabItem {
                    Label("tab_reminders", systemImage: "alarm")
                }
            
            SettingsView()
                .tabItem {
                    Label("tab_settings", systemImage: "gearshape")
                }
        }
    }
}

// preview
struct ChugsApp_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
