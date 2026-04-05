import SwiftUI

struct ReferencePrimaryButton: View {
    let title: String
    var systemImage: String?
    let action: () -> Void

    init(title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                }
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: DesignConstants.minTap)
            .padding(.horizontal, DesignConstants.buttonHorizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary, Color.appPrimary.opacity(0.88), Color.appPrimary.opacity(0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.22), Color.appAccent.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 2, y: 2)
            .shadow(color: Color.appPrimary.opacity(0.45), radius: 12, y: 6)
            .shadow(color: Color.appAccent.opacity(0.2), radius: 20, y: 10)
        }
        .buttonStyle(.plain)
    }
}

struct ReferenceSecondaryButton: View {
    let title: String
    var systemImage: String?
    let action: () -> Void

    init(title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                }
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: DesignConstants.minTap)
            .padding(.horizontal, DesignConstants.buttonHorizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appSurface.opacity(0.95), Color.appSurface.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appAccent.opacity(0.9), Color.appPrimary.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.12), radius: 2, y: 1)
            .shadow(color: Color.appPrimary.opacity(0.15), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }
}
