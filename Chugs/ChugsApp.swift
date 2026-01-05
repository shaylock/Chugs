//
//  ChugsApp.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//

import SwiftUI
import UserNotifications
import Mixpanel

enum AppGroup {
    static let id = "group.com.shayblum.Chugs"
    static let defaults = UserDefaults(suiteName: id)!
}

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
    @Environment(\.scenePhase) private var scenePhase
    private let notificationDelegate: NotificationDelegate
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("lastAppActivationTime") private var lastAppActivationTime: Double = 0
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    
    private let logger = LoggerUtilities.makeLogger(for: Self.self)
    
    init() {
        notificationDelegate = NotificationDelegate()
        UNUserNotificationCenter.current().delegate = notificationDelegate
        
        AnalyticsUtilities.initializeMixpanel()
        AnalyticsUtilities.trackAppStart()
        
        // TODO: why is this here?
        OnboardingPageConstants.subtitleFont = .system(size: 18)
        OnboardingPageConstants.buttonFont = .system(size: 20, weight: .semibold)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
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
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(from: oldPhase, to: newPhase)
            }
        }
    }
    
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            logger.info("Scene became active (from \(String(describing: oldPhase)))")
            if hasCompletedOnboarding {
                Task {
                    await runAppResumeLogic()
                }
            }

        case .background:
            AnalyticsUtilities.flushMixpanel()
            logger.info("Scene moved to background")

        case .inactive:
            break

        @unknown default:
            break
        }
    }
    
    @MainActor
    private func runAppResumeLogic() async {
        let now = Date()

//        let elapsedSinceLastActivation: TimeInterval =
//            lastAppActivationTime == 0
//            ? 0
//            : now.timeIntervalSince1970 - lastAppActivationTime
        
        let allowed = await NotificationPermission.allowedNotifications()
        if (!allowed) {
            notificationsEnabled = false
        }
        NotificationManager.shared.ensureChugsCategoryExists()
        
        // Fan-out lifecycle event
        await HydrationManager.shared.runAppResumeLogic()
        
        // Persist new activation time
        lastAppActivationTime = now.timeIntervalSince1970
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DrinkTrackView()
                .tabItem {
                    Label("tab.drink", systemImage: "drop.fill")
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
