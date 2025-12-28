//
//  NotificationViewController.swift
//  ChugsNotification
//
//  Created by Shay Blum on 26/12/2025.
//

import UIKit
import SwiftUI
import UserNotifications
import UserNotificationsUI

enum AppGroup {
    static let id = "group.com.shayblum.Chugs"
    static let defaults = UserDefaults(suiteName: id)!
}

final class NotificationViewController: UIViewController, UNNotificationContentExtension {
    @AppStorage(
        "storedDailyProgress",
        store: AppGroup.defaults
    )
    private var storedDailyProgress: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: REVERT
        let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroup.id)

        print("📦 App Group container URL:", url ?? "nil")


        print("🚰 ChugsNotification viewDidLoad yess")
        print("stored daily progress is \(storedDailyProgress) liters")

        let swiftUIView = DrinkTrackNotificationView()
        let hostingController = UIHostingController(rootView: swiftUIView)

        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    func didReceive(_ notification: UNNotification) {
        // No-op for now
    }
}


