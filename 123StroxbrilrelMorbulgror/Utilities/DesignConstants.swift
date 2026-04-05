import SwiftUI

enum DesignConstants {
    static let springResponse: Double = 0.5
    static let springDamping: Double = 0.7
    static let easeDuration: Double = 0.3

    static var spring: Animation {
        .spring(response: springResponse, dampingFraction: springDamping)
    }

    static var easeInOut: Animation {
        .easeInOut(duration: easeDuration)
    }

    static let minTap: CGFloat = 44
    static let buttonHorizontalPadding: CGFloat = 16
}

/// Shared shadows, corner radii, and gradient stops for depth across the app.
enum ReferenceElevation {
    static let cardCorner: CGFloat = 18
    static let panelCorner: CGFloat = 20
}

extension ReferenceElevation {
    static var screenGradientTop: Color { Color.appBackground }
    static var screenGradientMid: Color { Color.appBackground.opacity(0.98) }
    static var screenGradientAccent: Color { Color.appPrimary.opacity(0.12) }

    static var surfaceGradientTop: Color { Color.appSurface }
    static var surfaceGradientBottom: Color { Color.appSurface.opacity(0.88) }
}
