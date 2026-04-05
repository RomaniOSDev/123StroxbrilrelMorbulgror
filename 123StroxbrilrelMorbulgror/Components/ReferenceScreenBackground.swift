import SwiftUI

/// Full-screen backdrop: base gradient, soft vignette, and subtle depth tint.
struct ReferenceScreenBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    ReferenceElevation.screenGradientTop,
                    ReferenceElevation.screenGradientMid,
                    ReferenceElevation.screenGradientAccent.opacity(0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.appAccent.opacity(0.14), Color.clear],
                center: .topTrailing,
                startRadius: 40,
                endRadius: 380
            )

            RadialGradient(
                colors: [Color.appPrimary.opacity(0.08), Color.clear],
                center: .bottomLeading,
                startRadius: 60,
                endRadius: 320
            )

            LinearGradient(
                colors: [Color.clear, Color.appPrimary.opacity(0.05)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
    }
}

extension View {
    /// Applies the standard layered screen backdrop behind content.
    func referenceScreenBackdrop() -> some View {
        background(
            ReferenceScreenBackground()
                .ignoresSafeArea()
        )
    }

    /// Contact + diffuse shadows for floating panels (cards, chips, chart shells).
    func referenceFloatingShadow(cornerRadius _: CGFloat = ReferenceElevation.cardCorner) -> some View {
        self
            .shadow(color: Color.black.opacity(0.18), radius: 1, y: 1)
            .shadow(color: Color.appPrimary.opacity(0.22), radius: 12, y: 6)
            .shadow(color: Color.appAccent.opacity(0.14), radius: 22, y: 12)
    }
}
