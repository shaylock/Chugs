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
//    case tapToTrack
    case enableHealth
    case smartVsInterval
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var page: Int = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $page) {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    onboardingView(for: step)
                        .tag(step.rawValue)
                }
            }
            .tabViewStyle(PageTabViewStyle())

            // Skip button
            Button("Skip") {
                hasCompletedOnboarding = true
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
                title: "Welcome to Chugs 💧",
                subtitle: "Your smart water drinking buddy.",
                buttonTitle: "Continue",
                action: goToNext
            )

        case .notificationVideo:
            VideoOnboardingPage(
                title: "Track from Notifications 🚀",
                subtitle: "Long-press a reminder to log a drink instantly — no need to open the app!",
                buttonTitle: "Continue",
                videoName: "NotificationDemo",
                fileExtension: "mp4",
                action: goToNext
            )

        case .lockScreen:
            OnboardingPage<EmptyView>(
                image: "lock.fill",
                title: "Track From Lock Screen",
                subtitle: """
                In Settings → Apps → Chugs
                Open Notifications → Show Preview
                Click ’Always’.
                """,
                buttonTitle: "Open App Settings",
                action: {
                    openAppNotificationSettings()
                    goToNext()
                }
            )

//        case .tapToTrack:
//            OnboardingPage<EmptyView>(
//                title: "Tap to Track 💧",
//                subtitle: "Try it! Tap below to see how easy it is to log a drink.",
//                buttonTitle: "Continue",
//                action: goToNext
//            )

        case .enableNotifications:
            OnboardingPage<EmptyView>(
                image: "bell.badge.fill",
                title: "Enable Notifications",
                subtitle: "We’ll remind you to drink.",
                buttonTitle: "Enable",
                action: {
                    NotificationManager.shared.requestNotificationPermission()
                    NotificationManager.shared.ensureChugsCategoryExists()
                    goToNext()
                }
            )

        case .enableHealth:
            OnboardingPage<EmptyView>(
                image: "heart.fill",
                title: "Enable Health",
                subtitle: "We’ll update apple health with your progress.",
                buttonTitle: "Enable",
                action: {
                    let healthStore = HealthStore()
                    healthStore.requestAuthorization { success, error in
                        print("HealthKit authorization: \(success), error: \(String(describing: error))")
                    }
                    goToNext()
                }
            )

        case .smartVsInterval:
            OnboardingPage<EmptyView>(
                image: "gearshape.fill",
                title: "Smart vs Interval",
                subtitle: "Smart mode adapts to your habits. Interval mode reminds you every X minutes.",
                buttonTitle: "Continue",
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
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void
    let content: Content?

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
    let title: String
    let subtitle: String
    let buttonTitle: String
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
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            if player == nil, let url = Bundle.main.url(forResource: videoName, withExtension: fileExtension) {
                player = AVPlayer(url: url)
                player?.isMuted = true
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
