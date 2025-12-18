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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    private let logger = LoggerUtilities.makeLogger(for: Self.self)
    
    init() {
        notificationDelegate = NotificationDelegate()
        UNUserNotificationCenter.current().delegate = notificationDelegate
        
        // Request notification permission and ensure our category exists.
        if hasCompletedOnboarding {
            NotificationPermission.shared.requestNotificationPermission()
            NotificationManager.shared.ensureChugsCategoryExists()
        }
        
        OnboardingPageConstants.subtitleFont = .system(size: 18)
        OnboardingPageConstants.buttonFont = .system(size: 20, weight: .semibold)
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .appTheme(AppTheme(
                        label: Color("Label"),
                        background: Color("SystemBackground"),
                        accent: Color("AccentColor")
                    ))
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DrinkTrackView()
                .tabItem {
                    Label("tab.drink", systemImage: "drop.fill")
                }

            HistoryView() // ← New tab
                .tabItem {
                    Label("tab.stats", systemImage: "chart.bar")
                }

            NotificationSettingView()
                .tabItem {
                    Label("tab.reminders", systemImage: "alarm")
                }

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gearshape")
                }
        }
    }
}


#Preview {
    MainTabView()
}
