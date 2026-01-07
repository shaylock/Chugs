//
//  AnalyticsUtilities.swift
//  Tipot
//
//  Created by Shay Blum on 31/12/2025.
//

import SwiftUI
import Mixpanel

enum AnalyticsConfig {

    static var mixpanelToken: String {
        #if DEBUG
        return "8359b405c51785db4df297da935e1855"
        #elseif STAGING
        return "8359b405c51785db4df297da935e1855"
        #else
        return "7d55d70ff9053e7f6b396d68f6ea3ac1"
        #endif
    }
}

struct AnalyticsUtilities {
    @AppStorage("anonymousUserId") private static var anonymousUserId: String?
    
    static func initializeMixpanel() {
        print("Initializing Mixpanel with token: \(AnalyticsConfig.mixpanelToken)")
        Mixpanel.initialize(
            token: AnalyticsConfig.mixpanelToken,
            trackAutomaticEvents: false,
            serverURL: "https://api-eu.mixpanel.com"
        )
        #if DEBUG
        Mixpanel.mainInstance().loggingEnabled = true
        #endif
    }
    
    static func flushMixpanel() {
        Mixpanel.mainInstance().flush()
    }

    static func getAnonymousUserId() -> String {
        if let existingId = anonymousUserId {
            return existingId
        }

        let newId = UUID().uuidString
        anonymousUserId = newId
        return newId
    }

    private static func identifyAnonymousUser() {
        let userId = getAnonymousUserId()
        Mixpanel.mainInstance().identify(distinctId: userId)
    }
    
    static func trackAppStart() {
        identifyAnonymousUser()

        Mixpanel.mainInstance().track(
            event: "App Started",
            properties: [
                "anonymous_user": true
            ]
        )
        Mixpanel.mainInstance().flush()
    }
    
    static func trackDrink(
        fromNotification: Bool,
        numberOfGulps: Int
    ) {
        identifyAnonymousUser()
        identifyAnonymousUser()
        let source = fromNotification ? "notification" : "app"

        Mixpanel.mainInstance().track(
            event: "Drink Logged",
            properties: [
                "anonymous_user": true,
                "source": source,
                "number_of_gulps": numberOfGulps
            ]
        )

        if fromNotification {
            Mixpanel.mainInstance().flush()
        }
    }
    
    static func trackNotificationToggleChanged(
        notificationType: NotificationType,
        isEnabled: Bool
    ) {
        identifyAnonymousUser()

        let properties: [String: MixpanelType] = [
            "anonymous_user": true,
            "notification_type": notificationType.rawValue,
            "notifications_enabled": isEnabled
        ]

        Mixpanel.mainInstance().track(
            event: isEnabled
                ? "Notifications Enabled"
                : "Notifications Disabled",
            properties: properties
        )
    }
    
    static func trackNotificationSettingsChanged(
        notificationType: NotificationType,
        intervalValue: String,
        isEnabled: Bool
    ) {
        identifyAnonymousUser()

        let properties: [String: MixpanelType] = [
            "anonymous_user": true,
            "notification_type": notificationType.rawValue,
            "notification_interval_value": intervalValue,
            "notifications_enabled": isEnabled
        ]

        let mixpanel = Mixpanel.mainInstance()
        
        mixpanel.people.set(properties: properties)
        mixpanel.track(
            event: "Notification Settings Changed",
            properties: properties
        )
    }
    
    static func trackNotificationSettingsSnapshotIfNeeded(
        notificationType: NotificationType,
        intervalValue: String,
        isEnabled: Bool
    ) {
        let snapshotKey = "didTrackNotificationSettingsSnapshot"
        let hasTracked = UserDefaults.standard.bool(forKey: snapshotKey)

        guard !hasTracked else { return }

        trackNotificationSettingsChanged(
            notificationType: notificationType,
            intervalValue: intervalValue,
            isEnabled: isEnabled
        )

        UserDefaults.standard.set(true, forKey: snapshotKey)
    }
}
