//
//  NotificationViewController.swift
//  ChugsNotificationExtension
//
//  Created by Shay Blum on 10/10/2025.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import SwiftUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    private var hostingController: UIHostingController<ChugView>?
    private let appGroupID = "group.com.shayblum.chugs"

    func didReceive(_ notification: UNNotification) {
        let sharedDefaults = UserDefaults(suiteName: appGroupID)
        let dailyProgress = sharedDefaults?.double(forKey: "dailyProgress") ?? 0
        let gulpSize = sharedDefaults?.double(forKey: "gulpSize") ?? 50
        let numberOfGulps = sharedDefaults?.double(forKey: "numberOfGulps") ?? 1

        // Set up SwiftUI view
        let chugView = ChugView(
            dailyProgress: dailyProgress,
            gulpSize: gulpSize,
            numberOfGulps: numberOfGulps,
            sharedDefaults: sharedDefaults
        )

        let controller = UIHostingController(rootView: chugView)
        controller.view.frame = view.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        hostingController = controller
    }
}
