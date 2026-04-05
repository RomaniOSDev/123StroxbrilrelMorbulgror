import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        ZStack {
            ReferenceScreenBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ReferenceScreenHeader(
                        eyebrow: "App",
                        title: "Settings",
                        subtitle: "Rate the app or read our policies in Safari."
                    )

                    ReferenceSurfaceCard(accent: .leading) {
                        VStack(spacing: 0) {
                            settingsRow(
                                icon: "star.fill",
                                title: "Rate Us",
                                tint: Color.appAccent
                            ) {
                                rateApp()
                            }

                            ReferenceSectionDivider()
                                .padding(.vertical, 6)

                            settingsRow(
                                icon: "hand.raised.fill",
                                title: AppExternalLink.privacyPolicy.title,
                                tint: Color.appPrimary
                            ) {
                                openPolicy(.privacyPolicy)
                            }

                            ReferenceSectionDivider()
                                .padding(.vertical, 6)

                            settingsRow(
                                icon: "doc.text.fill",
                                title: AppExternalLink.termsOfUse.title,
                                tint: Color.appPrimary
                            ) {
                                openPolicy(.termsOfUse)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func settingsRow(icon: String, title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 28, alignment: .center)
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private func openPolicy(_ link: AppExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
