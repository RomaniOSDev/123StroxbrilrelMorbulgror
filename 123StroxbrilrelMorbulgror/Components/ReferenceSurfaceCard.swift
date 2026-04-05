import SwiftUI

/// Raised panel with optional left accent stripe (reference “spine” look).
struct ReferenceSurfaceCard<Content: View>: View {
    enum AccentEdge {
        case leading
        case none
    }

    let accent: AccentEdge
    @ViewBuilder let content: () -> Content

    init(accent: AccentEdge = .leading, @ViewBuilder content: @escaping () -> Content) {
        self.accent = accent
        self.content = content
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if accent == .leading {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary, Color.appAccent],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 5)
                    .padding(.vertical, 10)
                    .padding(.leading, 4)
            }

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: ReferenceElevation.cardCorner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [ReferenceElevation.surfaceGradientTop, ReferenceElevation.surfaceGradientBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: ReferenceElevation.cardCorner, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.14), Color.clear, Color.appAccent.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: ReferenceElevation.cardCorner, style: .continuous)
                .stroke(Color.appAccent.opacity(0.2), lineWidth: 0.5)
        )
        .referenceFloatingShadow(cornerRadius: ReferenceElevation.cardCorner)
    }
}
