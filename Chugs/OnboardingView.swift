//
//  OnboardingView.swift
//  Chugs
//
//  Created by Shay Blum on 05/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var page = 0
    
    var body: some View {
        TabView(selection: $page) {
            OnboardingPage<EmptyView>(
                image: "drop.fill",
                title: "Welcome to Chugs 💧",
                subtitle: "Your smart hydration assistant — stay refreshed effortlessly.",
                buttonTitle: "Continue",
                action: { page += 1 }
            ).tag(0)
            
            OnboardingPage(
                title: "Tap to Track 💧",
                subtitle: "Try it! Tap below to see how easy it is to log a drink.",
                buttonTitle: "Continue",
                content: {
                    DrinkTrackView(demoMode: true)
                },
                action: { page += 1 } // advance your onboarding page index
            ).tag(1)
            
            OnboardingPage<EmptyView>(
                image: "bell.badge.fill",
                title: "Enable Notifications",
                subtitle: "We’ll remind you to drink at smart intervals.",
                buttonTitle: "Enable",
                action: {
                    NotificationManager.shared.requestNotificationPermission()
                    NotificationManager.shared.ensureChugsCategoryExists()
                    page += 1
                }
            ).tag(2)
            
            OnboardingPage<EmptyView>(
                image: "gearshape.fill",
                title: "Smart vs Interval",
                subtitle: "Smart mode adapts to your habits. Interval mode reminds you every X minutes.",
                buttonTitle: "Continue",
                action: { page += 1 }
            ).tag(3)
            
            OnboardingPage<EmptyView>(
                image: "lock.fill",
                title: "Quick Actions on Lock Screen",
                subtitle: "To track without unlocking, enable ‘Show Previews: Always’ under Settings → Notifications → Chugs.",
                buttonTitle: "Open Settings",
                action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    // End onboarding
                    hasCompletedOnboarding = true
                }
            ).tag(4)
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct OnboardingPage<Content: View>: View {
    let image: String?      // Optional system image
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void
    let content: Content?   // Optional embedded view

    // Flexible initializer: content is optional
    init(
        image: String? = nil,
        title: String,
        subtitle: String,
        buttonTitle: String,
        @ViewBuilder content: () -> Content? = { nil },
        action: @escaping () -> Void
    ) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.action = action
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            if let image = image, !image.isEmpty {
                Image(systemName: image)
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
            }

            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            if let content = content {
                content
                    .frame(height: 350)
                    .padding(.horizontal)
            }

            Spacer()

            Button(buttonTitle, action: action)
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
        }
    }
}



