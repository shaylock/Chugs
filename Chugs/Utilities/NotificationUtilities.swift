//
//  NotificationUtilities.swift
//  Chugs
//
//  Created by Shay Blum on 17/10/2025.
//

import SwiftUI

final class NotificationUtilities {
    
    static func checkPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            // Request authorization if not already granted
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                print("Error requesting notification authorization: \(error)")
                return false
            }
        }
    }
}
