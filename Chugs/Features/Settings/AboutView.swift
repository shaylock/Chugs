//
//  AboutView.swift
//  Tipot
//
//  Created by Shay Blum on 06/01/2026.
//

import SwiftUI

struct AboutView: View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // App Identity
                VStack(spacing: 8) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)

                    Text("Tipot")
                        .font(.title.bold())

                    Text(LocalizedStringKey("about.tagline"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)

                // What the app does
                infoCard(
                    title: LocalizedStringKey("about.whatItDoes.title"),
                    text: LocalizedStringKey("about.whatItDoes.body")
                )

                // Disclaimer (most important)
                infoCard(
                    title: LocalizedStringKey("about.disclaimer.title"),
                    text: LocalizedStringKey("about.disclaimer.body")
                )

                // Version
                VStack(spacing: 4) {
                    Text(LocalizedStringKey("about.version"))
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Text(Bundle.main.appVersionString)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle(LocalizedStringKey("about.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Components

    @ViewBuilder
    private func infoCard(title: LocalizedStringKey, text: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}
