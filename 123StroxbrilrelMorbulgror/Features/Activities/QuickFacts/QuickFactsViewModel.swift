import Combine
import Foundation

@MainActor
final class QuickFactsViewModel: ObservableObject {
    struct TopicLabel: Identifiable, Hashable {
        let id: String
        let title: String
    }

    struct FactCard: Identifiable, Hashable {
        let id: UUID
        let text: String
        let topicId: String
    }

    @Published private(set) var topics: [TopicLabel] = []
    @Published private(set) var floatingFacts: [FactCard] = []
    @Published private(set) var secondsRemaining: Double = 0
    @Published private(set) var initialTimeTotal: Double = 0
    @Published private(set) var wrongAttempts: Int = 0
    @Published private(set) var isFinished: Bool = false
    @Published private(set) var outcome: RawActivityOutcome?

    private var cancellable: AnyCancellable?
    private var startedAt: Date?
    private let difficulty: ReferenceDifficulty
    private let level: ReferenceLevelIndex

    private var initialSeconds: Double = 0
    private var maxWrong: Int = 0
    private var totalPairs: Int = 0

    init(difficulty: ReferenceDifficulty, level: ReferenceLevelIndex) {
        self.difficulty = difficulty
        self.level = level
        buildLevel()
    }

    func start() {
        guard !isFinished else { return }
        startedAt = Date()
        cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stop() {
        cancellable?.cancel()
        cancellable = nil
    }

    private func tick() {
        guard !isFinished else { return }
        secondsRemaining = max(0, secondsRemaining - 0.1)
        if secondsRemaining <= 0 {
            finishFailure()
        }
    }

    func handleDrop(factId: UUID, on topicId: String) {
        guard !isFinished else { return }
        guard let idx = floatingFacts.firstIndex(where: { $0.id == factId }) else { return }
        let fact = floatingFacts[idx]

        if fact.topicId == topicId {
            floatingFacts.remove(at: idx)
            if floatingFacts.isEmpty {
                finishSuccess()
            }
        } else {
            wrongAttempts += 1
            if wrongAttempts >= maxWrong {
                finishFailure()
            }
        }
    }

    private func finishSuccess() {
        guard !isFinished else { return }
        isFinished = true
        stop()
        let elapsed = elapsedSeconds()
        let initial = max(initialSeconds, 1)
        let timeRatio = secondsRemaining / initial
        let mistakes = wrongAttempts
        let stars = computeStars(mistakes: mistakes, timeRatio: timeRatio)
        let accuracy = 1 - (Double(mistakes) / Double(max(1, totalPairs + mistakes)))
        outcome = RawActivityOutcome(
            stars: stars,
            seconds: elapsed,
            accuracy: min(1, max(0, accuracy)),
            succeeded: true
        )
    }

    private func finishFailure() {
        guard !isFinished else { return }
        isFinished = true
        stop()
        let elapsed = elapsedSeconds()
        outcome = RawActivityOutcome(
            stars: 0,
            seconds: elapsed,
            accuracy: 0,
            succeeded: false
        )
    }

    private func elapsedSeconds() -> TimeInterval {
        guard let startedAt else { return max(0, initialSeconds - secondsRemaining) }
        return Date().timeIntervalSince(startedAt)
    }

    private func computeStars(mistakes: Int, timeRatio: Double) -> Int {
        if mistakes == 0, timeRatio >= 0.32 {
            return 3
        }
        if mistakes <= 2 {
            return 2
        }
        return 1
    }

    private func buildLevel() {
        let pool = QuickFactsContent.pairs(for: level)
        let idx = min(level.rawValue, 6)
        switch difficulty {
        case .easy:
            totalPairs = 5
            initialSeconds = [105, 99, 93, 87, 81, 75, 69][idx]
            maxWrong = 10
        case .normal:
            totalPairs = 10
            initialSeconds = [82, 76, 71, 66, 61, 56, 51][idx]
            maxWrong = 7
        case .hard:
            totalPairs = 15
            initialSeconds = [62, 57, 52, 48, 44, 40, 36][idx]
            maxWrong = 4
        }

        let trimmed = Array(pool.prefix(totalPairs))
        var topicMap: [String: String] = [:]
        for item in trimmed {
            topicMap[item.topicId] = item.topicTitle
        }

        topics = topicMap.keys.sorted().map { id in
            TopicLabel(id: id, title: topicMap[id] ?? id)
        }

        floatingFacts = trimmed.map { pair in
            FactCard(id: UUID(), text: pair.fact, topicId: pair.topicId)
        }.shuffled()

        secondsRemaining = initialSeconds
        initialTimeTotal = initialSeconds
    }
}

private struct QuickFactPair {
    let topicId: String
    let topicTitle: String
    let fact: String
}

private enum QuickFactsContent {
    static func pairs(for level: ReferenceLevelIndex) -> [QuickFactPair] {
        let base: [QuickFactPair] = [
            QuickFactPair(topicId: "t1", topicTitle: "Indexes", fact: "An index lists terms with page pointers for fast lookup."),
            QuickFactPair(topicId: "t2", topicTitle: "Appendix", fact: "Appendix sections often hold long tables that would interrupt the main text."),
            QuickFactPair(topicId: "t3", topicTitle: "Glossary", fact: "A glossary gives concise definitions for specialized vocabulary."),
            QuickFactPair(topicId: "t4", topicTitle: "Bibliography", fact: "Bibliographies collect sources used so readers can verify claims."),
            QuickFactPair(topicId: "t5", topicTitle: "Cross-refs", fact: "Cross-references send you to related entries without repeating details."),
            QuickFactPair(topicId: "t6", topicTitle: "Scope notes", fact: "Scope notes clarify what a section intentionally excludes."),
            QuickFactPair(topicId: "t7", topicTitle: "Figures", fact: "Captions for figures summarize what the visual is meant to show."),
            QuickFactPair(topicId: "t8", topicTitle: "Editions", fact: "Edition statements help you spot revised material and corrections."),
            QuickFactPair(topicId: "t9", topicTitle: "Preface", fact: "A preface often explains why the work was organized as it is."),
            QuickFactPair(topicId: "t10", topicTitle: "Abstracts", fact: "Abstracts compress the aim and outcome of a longer piece."),
            QuickFactPair(topicId: "t11", topicTitle: "Footnotes", fact: "Footnotes carry clarifications without crowding the main paragraph."),
            QuickFactPair(topicId: "t12", topicTitle: "Chapters", fact: "Chapter titles signal the next conceptual unit in longer works."),
            QuickFactPair(topicId: "t13", topicTitle: "Symbols", fact: "Symbol lists decode abbreviations used across many pages."),
            QuickFactPair(topicId: "t14", topicTitle: "Maps", fact: "Maps orient readers when place names appear throughout the text."),
            QuickFactPair(topicId: "t15", topicTitle: "Timelines", fact: "Timelines align events when narrative order differs from chronology."),
            QuickFactPair(topicId: "t16", topicTitle: "Standards", fact: "Standards sections define how terms are used consistently."),
            QuickFactPair(topicId: "t17", topicTitle: "Errata", fact: "Errata sheets correct mistakes discovered after printing."),
            QuickFactPair(topicId: "t18", topicTitle: "Supplements", fact: "Supplements extend the core text with optional deep dives."),
            QuickFactPair(topicId: "t19", topicTitle: "Captions", fact: "Captions anchor illustrations to the surrounding discussion."),
            QuickFactPair(topicId: "t20", topicTitle: "Metadata", fact: "Metadata fields record authorship, dates, and revision history.")
        ]

        let layered: [QuickFactPair]
        switch level {
        case .one:
            layered = base
        case .two:
            layered = base.map { pair in
                QuickFactPair(topicId: pair.topicId, topicTitle: pair.topicTitle, fact: pair.fact + " Always verify the heading before quoting.")
            }
        case .three:
            layered = base.map { pair in
                QuickFactPair(topicId: pair.topicId, topicTitle: pair.topicTitle, fact: "Advanced check: " + pair.fact + " Note any qualifiers nearby.")
            }
        case .four:
            layered = base.map { pair in
                QuickFactPair(topicId: pair.topicId, topicTitle: pair.topicTitle, fact: "Focused review: " + pair.fact + " Watch for narrow wording.")
            }
        case .five:
            layered = base.map { pair in
                QuickFactPair(topicId: pair.topicId, topicTitle: pair.topicTitle, fact: "Tight scan: " + pair.fact + " Ignore surface similarities.")
            }
        case .six:
            layered = base.map { pair in
                QuickFactPair(topicId: pair.topicId, topicTitle: pair.topicTitle, fact: "Detail pass: " + pair.fact + " Pair claims with labels.")
            }
        case .seven:
            layered = base.map { pair in
                QuickFactPair(topicId: pair.topicId, topicTitle: pair.topicTitle, fact: "Expert match: " + pair.fact + " Validate before locking.")
            }
        }

        return layered
    }
}
