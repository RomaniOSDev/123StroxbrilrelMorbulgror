import SwiftUI

struct ActivityResultView: View {
    let result: ActivitySessionResult
    let onNextLevel: () -> Void
    let onRetry: () -> Void
    let onBackToLevels: () -> Void

    let canGoNext: Bool

    @State private var starsShown = 0
    @State private var bannerPresented = false

    var body: some View {
        ZStack(alignment: .top) {
            ReferenceScreenBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    Text(result.succeeded ? "Great Run" : "Keep Going")
                        .font(.largeTitle.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appTextPrimary, Color.appAccent.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.appPrimary.opacity(0.35), radius: 12, y: 6)
                        .multilineTextAlignment(.center)

                    Text("You finished this stage. Review your stats below.")
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)

                    starRow
                        .padding(.vertical, 8)

                    statsGrid

                    VStack(spacing: 12) {
                        if canGoNext {
                            ReferencePrimaryButton(title: "Next Level", systemImage: "forward.fill", action: onNextLevel)
                        }
                        ReferencePrimaryButton(title: "Retry", systemImage: "arrow.clockwise", action: onRetry)
                        ReferenceSecondaryButton(title: "Back to Levels", systemImage: "list.bullet.rectangle", action: onBackToLevels)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
                .padding(.top, bannerPresented && !result.newAchievements.isEmpty ? 56 : 0)
            }

            if bannerPresented && !result.newAchievements.isEmpty {
                achievementBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
            }
        }
        .onAppear {
            animateStars()
            if !result.newAchievements.isEmpty {
                withAnimation(DesignConstants.spring) {
                    bannerPresented = true
                }
            }
        }
    }

    private var starRow: some View {
        HStack(spacing: 18) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < starsShown ? "star.fill" : "star")
                    .font(.system(size: 40))
                    .foregroundStyle(index < starsShown ? Color.appAccent : Color.appTextSecondary.opacity(0.35))
                    .shadow(color: index < starsShown ? Color.appAccent.opacity(0.85) : .clear, radius: 10)
                    .scaleEffect(index < starsShown ? 1 : 0.6)
                    .animation(DesignConstants.spring, value: starsShown)
            }
        }
    }

    private func animateStars() {
        starsShown = 0
        let earned = min(3, max(0, result.starsEarned))
        for index in 0..<earned {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                withAnimation(DesignConstants.spring) {
                    starsShown = index + 1
                }
            }
        }
    }

    private var statsGrid: some View {
        ReferenceSurfaceCard(accent: .leading) {
            VStack(spacing: 12) {
                HStack {
                    Text("Run summary")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                    Spacer()
                    ReferenceMetricPill(text: result.succeeded ? "Cleared" : "Try again", prominent: result.succeeded)
                }
                ReferenceSectionDivider()
                statLine(title: "Time", value: formattedTime(result.secondsUsed))
                statLine(title: "Accuracy", value: "\(Int((result.accuracy * 100).rounded()))%")
                statLine(title: "Stars earned", value: "\(result.starsEarned) / 3")
            }
        }
    }

    private func statLine(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(Color.appTextPrimary)
                .font(.body.weight(.semibold))
        }
    }

    private func formattedTime(_ seconds: TimeInterval) -> String {
        let s = max(0, seconds)
        if s < 60 {
            return String(format: "%.1fs", s)
        }
        let m = Int(s) / 60
        let r = Int(s) % 60
        return "\(m)m \(r)s"
    }

    private var achievementBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("New Highlight")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            ForEach(result.newAchievements) { item in
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Text(item.detail)
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface, Color.appSurface.opacity(0.88)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.appAccent.opacity(0.45), Color.appPrimary.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .referenceFloatingShadow(cornerRadius: 14)
    }
}
