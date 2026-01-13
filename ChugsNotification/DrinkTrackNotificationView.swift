//
//  TrackingButtonsNotificationView.swift
//  Tipot
//
//  Created by Shay Blum on 26/12/2025.
//

import SwiftUI
import ChugsShared

struct DrinkTrackNotificationView: View {

    var body: some View {
        VStack(spacing: 20) {
            NotificationProgressView()
            NotificationTrackingButtonsView()
        }
        .padding(.vertical, 16)
        .fixedSize(horizontal: false, vertical: true)
    }
}

