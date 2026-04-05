import SwiftUI

struct ExploreView: View {
    private let topics: [ExploreTopic] = [
        ExploreTopic(
            title: "How References Are Organized",
            detail: "Most reference works use predictable patterns: alphabetical lists, thematic clusters, and cross-links that help you jump between related entries without rereading entire sections."
        ),
        ExploreTopic(
            title: "Skimming with Purpose",
            detail: "Start with headings and marginal cues, then narrow to the paragraph that answers your exact question. This mirrors how professionals move through dense material under time limits."
        ),
        ExploreTopic(
            title: "Verifying Details",
            detail: "When facts matter, compare at least two independent snippets. Small disagreements often reveal scope limits, exceptions, or outdated phrasing you should notice."
        ),
        ExploreTopic(
            title: "Building a Quick Citation",
            detail: "Capture the title, section, and date in one line. Even informal notes benefit from a consistent mini-format so you can revisit the source confidently."
        ),
        ExploreTopic(
            title: "Tables, Charts, and Units",
            detail: "Always read axis labels and footnotes before interpreting a number. Similar charts can hide different scales—note the range before comparing peaks."
        ),
        ExploreTopic(
            title: "When to Go Deeper",
            detail: "If an answer feels incomplete, follow the nearest cross-reference rather than guessing. The shortest path is often the labeled bridge, not a new search."
        )
    ]

    var body: some View {
        ZStack {
            ReferenceScreenBackground()
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ReferenceScreenHeader(
                        eyebrow: "Browse",
                        title: "Reference Toolkit",
                        subtitle: "Practical ideas you can apply immediately. Pick a card to read a short note—no quizzes here, just calm guidance."
                    )

                    ForEach(Array(topics.enumerated()), id: \.element.id) { index, topic in
                        ReferenceSurfaceCard(accent: index.isMultiple(of: 2) ? .leading : .none) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(topic.title)
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)
                                    Spacer(minLength: 8)
                                    ReferenceMetricPill(text: "Note \(index + 1)", prominent: false)
                                }
                                ReferenceSectionDivider()
                                Text(topic.detail)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
    }
}

private struct ExploreTopic: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}
