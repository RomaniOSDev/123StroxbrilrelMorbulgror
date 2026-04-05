import SwiftUI

/// Capsule progress bar with gradient fill (timers, global progress).
struct ReferenceProgressTrack: View {
    let value: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.appBackground.opacity(0.95), Color.appBackground.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.appAccent.opacity(0.45), Color.appPrimary.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 1, y: 1)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appPrimary, Color.appAccent.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(8, geo.size.width * CGFloat(min(1, max(0, value)))))
                    .shadow(color: Color.appAccent.opacity(0.45), radius: 4, y: 2)
            }
        }
        .frame(height: 12)
    }
}

/// Compact metric chip (scores, tags).
struct ReferenceMetricPill: View {
    let text: String
    var prominent: Bool = false

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(prominent ? Color.appTextPrimary : Color.appTextSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: prominent
                                ? [Color.appPrimary.opacity(0.5), Color.appPrimary.opacity(0.28)]
                                : [Color.appBackground.opacity(0.85), Color.appBackground.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [Color.appAccent.opacity(0.5), Color.appPrimary.opacity(0.25)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.appPrimary.opacity(prominent ? 0.2 : 0.08), radius: prominent ? 6 : 3, y: 2)
    }
}

/// Horizontal gradient hairline between sections.
struct ReferenceSectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.clear, Color.appAccent.opacity(0.55), Color.appPrimary.opacity(0.35), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
            .shadow(color: Color.appAccent.opacity(0.35), radius: 4, y: 0)
            .padding(.vertical, 4)
    }
}
