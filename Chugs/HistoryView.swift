//
//  HistoryView.swift
//  Chugs
//
//  Created by Shay Blum on 25/11/2025.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var manager = HydrationManager.shared

    var body: some View {
        NavigationView {
            List(manager.dailyHistory) { day in
                VStack(alignment: .leading) {
                    Text(formatDate(day.date))
                        .font(.headline)

                    Text(String(format: "%.2f L", day.totalLiters))
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("History")
            .onAppear {
                manager.fetchHydrationHistory()
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
