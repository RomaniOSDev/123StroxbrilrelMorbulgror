import SwiftUI

struct MainTabSelectionKey: EnvironmentKey {
    static let defaultValue: (MainTab) -> Void = { _ in }
}

extension EnvironmentValues {
    var selectMainTab: (MainTab) -> Void {
        get { self[MainTabSelectionKey.self] }
        set { self[MainTabSelectionKey.self] = newValue }
    }
}
