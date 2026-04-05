import SwiftUI

struct ContentView: View {
    @StateObject private var progress = ReferenceProgressStore()

    var body: some View {
        Group {
            if progress.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    progress.completeOnboarding()
                }
            }
        }
        .environmentObject(progress)
    }
}

#Preview {
    ContentView()
}
