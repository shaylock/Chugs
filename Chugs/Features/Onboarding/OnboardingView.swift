//
//  OnboardingView.swift
//  Chugs
//
//  Created by Shay Blum on 05/11/2025.
//

import SwiftUI
import AVKit

enum OnboardingStep: Int, CaseIterable {
    case welcome
    case enableNotifications
    case notificationVideo
    case lockScreen
    case enableHealth
    case smartVsInterval
}

struct OnboardingView: View {
    @AppStorage("notificationType") private var notificationType: NotificationType = .smart
    @Binding var hasCompletedOnboarding: Bool
    @State private var page: Int = 0
    
    private let logger = LoggerUtilities.makeLogger(for: OnboardingView.self)

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $page) {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    onboardingView(for: step)
                        .tag(step.rawValue)
                }
            }
            .tabViewStyle(PageTabViewStyle())

            Button(LocalizedStringKey("onboarding.skip")) {
                finishOnboarding()
            }
            .padding(.top, 16)
            .padding(.trailing, 20)
            .buttonStyle(.borderless)
            .font(.headline)
            .foregroundColor(.blue)
        }
    }

    // MARK: - Page Builder
    @ViewBuilder
    func onboardingView(for step: OnboardingStep) -> some View {
        switch step {
        case .welcome:
            OnboardingPage<EmptyView>(
                image: "drop.fill",
                title: LocalizedStringKey("onboarding.pageWelcome.title"),
                subtitle: LocalizedStringKey("onboarding.pageWelcome.subtitle"),
                buttonTitle: LocalizedStringKey("onboarding.pageWelcome.button"),
                action: goToNext
            )

        case .notificationVideo:
            VideoOnboardingPage(
                title: LocalizedStringKey("onboarding.notificationVideo.title"),
                subtitle: LocalizedStringKey("onboarding.notificationVideo.subtitle"),
                buttonTitle: LocalizedStringKey("onboarding.notificationVideo.button"),
                videoName: "NotificationDemo",
                fileExtension: "mp4",
                action: goToNext
            )

        case .lockScreen:
            OnboardingPage<EmptyView>(
                image: "lock.fill",
                title: LocalizedStringKey("onboarding.lockScreen.title"),
                subtitle: LocalizedStringKey("onboarding.lockScreen.subtitle"),
                buttonTitle: LocalizedStringKey("onboarding.lockScreen.button"),
                action: {
                    openAppNotificationSettings()
                    goToNext()
                }
            )

        case .enableNotifications:
            OnboardingPage<EmptyView>(
                image: "bell.badge.fill",
                title: LocalizedStringKey("onboarding.enableNotifications.title"),
                subtitle: LocalizedStringKey("onboarding.enableNotifications.subtitle"),
                buttonTitle: LocalizedStringKey("onboarding.enableNotifications.button"),
                action: {
                    Task { @MainActor in
                        let granted = await NotificationPermission.shared.requestNotificationPermission()
                        logger.info("Notification permission granted: \(granted)")
                        goToNext()
                    }
                }
            )

        case .enableHealth:
            OnboardingPage<EmptyView>(
                image: "heart.fill",
                title: LocalizedStringKey("onboarding.enableHealth.title"),
                subtitle: LocalizedStringKey("onboarding.enableHealth.subtitle"),
                buttonTitle: LocalizedStringKey("onboarding.enableHealth.button"),
                action: {
                    let healthStore = HealthStore()
                    healthStore.requestAuthorization { _, _ in }
                    goToNext()
                }
            )

        case .smartVsInterval:
            OnboardingPage<EmptyView>(
                image: "gearshape.fill",
                title: LocalizedStringKey("onboarding.smartVsInterval.title"),
                subtitle: LocalizedStringKey("onboarding.smartVsInterval.subtitle"),
                buttonTitle: LocalizedStringKey("onboarding.smartVsInterval.button"),
                action: finishOnboarding
            )
        }
    }

    // MARK: - Actions

    private func goToNext() {
        page += 1
    }

    private func finishOnboarding() {
        hasCompletedOnboarding = true
        Task {
            await HydrationManager.shared.runAppResumeLogic()
            notificationType.makeScheduler().scheduleNotifications()
            AnalyticsUtilities.trackNotificationSettingsSnapshotIfNeeded(
                notificationType: notificationType,
                intervalValue: notificationType.makeScheduler().getIntervalString(),
                isEnabled: notificationType.makeScheduler().isNotificationEnabled()
            )
        }
    }

    func openAppNotificationSettings() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct OnboardingPageConstants {
    static var titleFont: Font = .title.bold()
    static var subtitleFont: Font = .body
    static var buttonFont: Font = .headline
    static var imageSize: CGFloat = 80
    static var contentHeight: CGFloat = 350
}

struct OnboardingPage<Content: View>: View {
    let image: String?
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let buttonTitle: LocalizedStringKey
    let action: () -> Void
    let content: Content?

    init(
        image: String? = nil,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        buttonTitle: LocalizedStringKey,
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
                    .font(.system(size: OnboardingPageConstants.imageSize))
                    .foregroundStyle(.blue)
            }

            Text(title)
                .font(OnboardingPageConstants.titleFont)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(OnboardingPageConstants.subtitleFont)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            if let content = content {
                content
                    .frame(height: OnboardingPageConstants.contentHeight)
                    .padding(.horizontal)
            }

            Button(buttonTitle, action: action)
                .font(OnboardingPageConstants.buttonFont)
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)
                .padding(.bottom, 40)

            Spacer()
        }
    }
}

struct VideoOnboardingPage: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let buttonTitle: LocalizedStringKey
    let videoName: String
    let fileExtension: String
    let action: () -> Void

    @State private var player: AVPlayer? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.seek(to: .zero)
                        player.play()
                        NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: player.currentItem,
                            queue: .main
                        ) { _ in
                            player.seek(to: .zero)
                            player.play()
                        }
                    }
                    .onDisappear {
                        player.pause()
                    }
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.7)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal)
            }

            Button(buttonTitle, action: action)
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
        }
        .padding(.top, 30)
        .onAppear {
            if player == nil,
               let url = Bundle.main.url(forResource: videoName, withExtension: fileExtension) {
                player = AVPlayer(url: url)
                player?.isMuted = true
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
