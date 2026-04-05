import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var progress: ReferenceProgressStore

    var body: some View {
        ZStack {
            ReferenceScreenBackground()
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ReferenceScreenHeader(
                        eyebrow: "Overview",
                        title: "Your Progress",
                        subtitle: "Stars, time, and milestones stay on this device until you reset."
                    )

                    NavigationLink {
                        SettingsView()
                    } label: {
                        ReferenceSurfaceCard(accent: .leading) {
                            HStack(spacing: 14) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.appAccent)
                                    .frame(width: 40, alignment: .center)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Settings")
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)
                                    Text("Rate us, privacy, and terms")
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                                Spacer(minLength: 8)
                                Image(systemName: "chevron.right.circle.fill")
                                    .foregroundStyle(Color.appAccent)
                                    .font(.title3)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    statsBlock

                    achievementsBlock

                    ReferencePrimaryButton(title: "Reset All Progress", systemImage: "arrow.counterclockwise.circle.fill") {
                        progress.resetAllProgress()
                    }

                    Text("This clears stars, unlocks, timers, and activity counts on this device.")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
    }

    private var statsBlock: some View {
        ReferenceSurfaceCard(accent: .leading) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Statistics")
                        .font(.title3.bold())
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    ReferenceMetricPill(text: "Live", prominent: true)
                }

                ReferenceSectionDivider()

                statRow(icon: "star.circle.fill", title: "Total stars collected", value: "\(progress.totalStarsEarned())")
                statRow(icon: "clock.fill", title: "Total time learning", value: formattedTime(progress.totalPlaySeconds))
                statRow(icon: "flag.checkered", title: "Finished runs", value: "\(progress.activitiesCompleted)")
            }
        }
    }

    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 28, alignment: .center)
            Text(title)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(Color.appTextPrimary)
                .font(.body.weight(.semibold))
        }
    }

    private func formattedTime(_ seconds: Double) -> String {
        let s = Int(seconds.rounded())
        let m = s / 60
        let r = s % 60
        if m >= 60 {
            let h = m / 60
            let mm = m % 60
            return "\(h)h \(mm)m"
        }
        return "\(m)m \(r)s"
    }

    private var achievementsBlock: some View {
        ReferenceSurfaceCard(accent: .none) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Achievements")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTextPrimary)

                ReferenceSectionDivider()

                let unlocked = AchievementEvaluator.unlocked(from: progress)
                ForEach(AchievementDefinition.all) { item in
                    let isOn = unlocked.contains(item.id)
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: isOn
                                            ? [Color.appPrimary.opacity(0.5), Color.appPrimary.opacity(0.28)]
                                            : [Color.appBackground.opacity(0.65), Color.appBackground.opacity(0.45)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isOn ? Color.appAccent.opacity(0.6) : Color.appTextSecondary.opacity(0.25),
                                            lineWidth: 1
                                        )
                                )
                            Image(systemName: isOn ? "seal.fill" : "seal")
                                .foregroundStyle(isOn ? Color.appAccent : Color.appTextSecondary)
                                .font(.title3)
                        }
                        .shadow(color: isOn ? Color.appAccent.opacity(0.35) : .clear, radius: isOn ? 8 : 0, y: 3)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Text(item.detail)
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
