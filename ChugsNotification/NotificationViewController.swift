//
//  NotificationViewController.swift
//  ChugsNotification
//
//  Created by Shay Blum on 26/12/2025.
//

import UIKit
import UserNotifications
import UserNotificationsUI

final class NotificationViewController: UIViewController, UNNotificationContentExtension {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("🚰 ChugsNotification viewDidLoad")

        view.backgroundColor = .systemYellow

        let label = UILabel()
        label.text = "CHUGS EXTENSION LOADED !!"
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func didReceive(_ notification: UNNotification) {
        print("🚰 didReceive notification")
    }
}

