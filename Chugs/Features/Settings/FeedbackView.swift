//
//  FeedbackView.swift
//  Tipot
//
//  Created by Shay Blum on 08/01/2026.
//

import SwiftUI

struct FeedbackView: View {

    private static let maxCharacters = 2000

    @Environment(\.dismiss) private var dismiss
    @State private var message: String = ""
    @State private var isSending = false
    @State private var showThankYou = false

    private var remainingCharacters: Int {
        Self.maxCharacters - message.count
    }

    private var canSend: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    var body: some View {
        VStack(spacing: 24) {

            // Intro
            VStack(spacing: 8) {
                Text(LocalizedStringKey("feedback.title"))
                    .font(.title2.bold())

                Text(LocalizedStringKey("feedback.subtitle"))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 16)

            // Message input
            VStack(alignment: .trailing, spacing: 6) {
                TextEditor(text: $message)
                    .frame(minHeight: 140)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
                    .onChange(of: message) { _, newValue in
                        if newValue.count > Self.maxCharacters {
                            message = String(newValue.prefix(Self.maxCharacters))
                        }
                    }

                // Character counter
                Text(
                    String(
                        format: NSLocalizedString(
                            "feedback.charactersRemaining",
                            comment: ""
                        ),
                        remainingCharacters
                    )
                )
                .font(.footnote)
                .foregroundColor(
                    remainingCharacters <= 0 ? .red : .secondary
                )
            }

            // Footer
            Text(LocalizedStringKey("feedback.footer"))
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Send button
            Button {
                Task {
                    await sendFeedback()
                }
            } label: {
                Text(LocalizedStringKey("feedback.sendButton"))
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(sendButtonBackground)
                    .cornerRadius(999)
            }
            .disabled(!canSend)

            Spacer()
        }
        .padding(.horizontal, 20)
        .navigationTitle(LocalizedStringKey("feedback.navTitle"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            LocalizedStringKey("feedback.thankYou.title"),
            isPresented: $showThankYou
        ) {
            Button(LocalizedStringKey("feedback.thankYou.button")) {
                dismiss()
            }
        } message: {
            Text(LocalizedStringKey("feedback.thankYou.message"))
        }
    }

    // MARK: - Networking

    private func sendFeedback() async {
        guard canSend else { return }

        isSending = true
        defer { isSending = false }

        let url = URL(string: "https://feedback.tipot.app/v1/feedback")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "message": message,
            "platform": "ios",
            "app_version": Bundle.main.appVersionString
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (_, response) = try await URLSession.shared.data(for: request)

            if (response as? HTTPURLResponse)?.statusCode == 200 {
                AnalyticsUtilities.trackFeedbackSubmitted(
                    messageLength: message.count,
                    source: "settings"
                )
                await MainActor.run {
                    showThankYou = true
                    message = ""
                }
            }
        } catch {
            // Silent failure is acceptable for one-way feedback
            print("Feedback send failed:", error)
        }
    }

    // MARK: - UI helpers

    private var sendButtonBackground: some View {
        Group {
            if canSend {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(#colorLiteral(red: 0.0, green: 0.7843137389, blue: 1.0, alpha: 1.0)),
                        Color(#colorLiteral(red: 0.0, green: 0.4470588267, blue: 0.9764705896, alpha: 1.0))
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            } else {
                Color(.systemGray4)
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedbackView()
    }
}
