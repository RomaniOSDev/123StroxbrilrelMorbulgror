import SwiftUI

struct ActivitiesHomeView: View {
    var body: some View {
        ZStack {
            ReferenceScreenBackground()
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ReferenceScreenHeader(
                        eyebrow: "Training",
                        title: "Activities",
                        subtitle: "Each path trains a different reference skill: pairing facts, restoring terms, and reading charts."
                    )

                    ForEach(ReferenceActivity.allCases) { activity in
                        NavigationLink {
                            ActivityLevelsView(activity: activity)
                        } label: {
                            ActivityRowCard(activity: activity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
    }
}

private struct ActivityRowCard: View {
    let activity: ReferenceActivity

    var body: some View {
        ReferenceSurfaceCard(accent: .leading) {
            HStack(alignment: .center, spacing: 14) {
                ReferenceActivityGlyph(activity: activity, size: 52)

                VStack(alignment: .leading, spacing: 8) {
                    Text(activity.titleKey)
                        .font(.title3.bold())
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)

                    Text(activity.detail)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        ReferenceMetricPill(text: "Tap to open stages", prominent: false)
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
        }
    }
}
