import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progress: ReferenceProgressStore
    @Environment(\.selectMainTab) private var selectMainTab

    private var maxPossibleStars: Int {
        ReferenceActivity.allCases.count
            * ReferenceDifficulty.allCases.count
            * ReferenceLevelIndex.allCases.count
            * 3
    }

    private var starsProgress: Double {
        let max = max(1, maxPossibleStars)
        return Double(progress.totalStarsEarned()) / Double(max)
    }

    var body: some View {
        ZStack {
            ReferenceScreenBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    heroBlock

                    statsOverview

                    ReferenceSectionDivider()

                    primaryActions

                    ReferenceSectionDivider()

                    Text("Practice tracks")
                        .font(.title3.bold())
                        .foregroundStyle(Color.appTextPrimary)

                    VStack(spacing: 12) {
                        ForEach(ReferenceActivity.allCases) { activity in
                            NavigationLink {
                                ActivityLevelsView(activity: activity)
                            } label: {
                                HomeActivityRow(activity: activity)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    ReferenceSectionDivider()

                    NavigationLink {
                        ExploreView()
                    } label: {
                        ReferenceSurfaceCard(accent: .leading) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.appPrimary.opacity(0.3))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "book.pages.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.appAccent)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Reference Toolkit")
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)
                                    Text("Short reading notes on skimming, citations, charts, and more.")
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 8)
                                Image(systemName: "chevron.right.circle.fill")
                                    .foregroundStyle(Color.appAccent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroBlock: some View {
        ReferenceSurfaceCard(accent: .leading) {
            VStack(alignment: .leading, spacing: 14) {
                HomeHeroCanvas()
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)

                Text("Learning hub")
                    .font(.caption.weight(.semibold))
                    .tracking(1.1)
                    .foregroundStyle(Color.appAccent)

                Text("Train retrieval, precision, and chart reading in one place.")
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Use the tracks below to jump into a challenge, or open the toolkit for calm reading.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("At a glance")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                ReferenceMetricPill(text: "\(progress.totalStarsEarned()) / \(maxPossibleStars) stars", prominent: true)
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appBackground.opacity(0.95), Color.appBackground.opacity(0.72)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 1, y: 1)
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appAccent, Color.appPrimary, Color.appAccent.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(12, geo.size.width * CGFloat(starsProgress)))
                        .shadow(color: Color.appAccent.opacity(0.4), radius: 4, y: 2)
                }
                .frame(height: 12)
            }
            .frame(height: 12)
            .accessibilityLabel("Overall star collection progress")
            .accessibilityValue("\(Int((starsProgress * 100).rounded())) percent")

            HStack(spacing: 10) {
                HomeStatTile(
                    icon: "star.fill",
                    title: "Stars",
                    value: "\(progress.totalStarsEarned())"
                )
                HomeStatTile(
                    icon: "clock.fill",
                    title: "Learning",
                    value: shortTime(progress.totalPlaySeconds)
                )
                HomeStatTile(
                    icon: "flag.checkered",
                    title: "Runs",
                    value: "\(progress.activitiesCompleted)"
                )
            }
        }
    }

    private func shortTime(_ seconds: Double) -> String {
        let s = Int(seconds.rounded())
        let m = s / 60
        if m >= 60 {
            return "\(m / 60)h"
        }
        if m > 0 {
            return "\(m)m"
        }
        return "\(s)s"
    }

    private var primaryActions: some View {
        VStack(spacing: 12) {
            Button {
                selectMainTab(.activities)
            } label: {
                HStack {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.title3)
                    Text("Open Activities")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                }
                .foregroundStyle(Color.appTextPrimary)
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appPrimary.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.appAccent.opacity(0.45)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.18), radius: 2, y: 2)
                .shadow(color: Color.appPrimary.opacity(0.4), radius: 14, y: 7)
            }
            .buttonStyle(.plain)

            HStack(spacing: 12) {
                Button {
                    selectMainTab(.explore)
                } label: {
                    secondaryActionLabel(icon: "globe.europe.africa.fill", title: "Explore")
                }
                .buttonStyle(.plain)

                Button {
                    selectMainTab(.profile)
                } label: {
                    secondaryActionLabel(icon: "chart.bar.fill", title: "Progress")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func secondaryActionLabel(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(Color.appTextPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface.opacity(0.98), Color.appSurface.opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.4), Color.appPrimary.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
        .shadow(color: Color.appPrimary.opacity(0.12), radius: 8, y: 4)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(ReferenceProgressStore())
    .environment(\.selectMainTab) { _ in }
}

// MARK: - Subviews

private struct HomeHeroCanvas: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            var ribbon = Path()
            ribbon.move(to: CGPoint(x: 0, y: h * 0.55))
            ribbon.addCurve(
                to: CGPoint(x: w, y: h * 0.45),
                control1: CGPoint(x: w * 0.3, y: h * 0.2),
                control2: CGPoint(x: w * 0.7, y: h * 0.85)
            )
            context.stroke(ribbon, with: .color(Color.appAccent.opacity(0.55)), style: StrokeStyle(lineWidth: 3, lineCap: .round))

            for i in 0..<4 {
                let x = w * (0.12 + CGFloat(i) * 0.22)
                let barH = h * [0.35, 0.55, 0.28, 0.62][i]
                let r = CGRect(x: x, y: h * 0.78 - barH * h, width: w * 0.14, height: barH * h)
                context.fill(Path(roundedRect: r, cornerRadius: 4), with: .color(Color.appPrimary.opacity(0.4 + Double(i) * 0.08)))
            }
        }
    }
}

private struct HomeActivityRow: View {
    let activity: ReferenceActivity

    var body: some View {
        ReferenceSurfaceCard(accent: .none) {
            HStack(spacing: 14) {
                ReferenceActivityGlyph(activity: activity, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.titleKey)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Text(activity.detail)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundStyle(Color.appAccent)
                    .font(.title3)
            }
        }
    }
}

private struct HomeStatTile: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.appAccent)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface.opacity(0.95), Color.appSurface.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.appAccent.opacity(0.22)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .referenceFloatingShadow(cornerRadius: 14)
    }
}
