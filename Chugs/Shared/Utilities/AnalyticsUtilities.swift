//
//  AnalyticsUtilities.swift
//  Chugs
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
    }

    static func getAnonymousUserId() -> String {
        if let existingId = anonymousUserId {
            return existingId
        }

        let newId = UUID().uuidString
        anonymousUserId = newId
        return newId
    }

    /// Identifies the anonymous user and tracks app start
    static func trackAppStart() {
        let userId = getAnonymousUserId()

        let mixpanel = Mixpanel.mainInstance()
        mixpanel.identify(distinctId: userId)

        mixpanel.track(
            event: "App Started",
            properties: [
                "anonymous_user": true
            ]
        )
    }
    
    /// Identifies the anonymous user and tracks app start
    static func trackDrink() {
        let userId = getAnonymousUserId()

        let mixpanel = Mixpanel.mainInstance()
        mixpanel.identify(distinctId: userId)

        mixpanel.track(
            event: "Drink Logged",
            properties: [
                "anonymous_user": true
            ]
        )
    }
}
