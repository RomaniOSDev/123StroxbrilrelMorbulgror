import Combine
import Foundation

@MainActor
final class RecallRaceViewModel: ObservableObject {
    struct Passage: Identifiable {
        let id = UUID()
        let title: String
        let segments: [Segment]
    }

    enum Segment {
        case text(String)
        case blank(Blank)
    }

    struct Blank: Identifiable, Hashable {
        let id: UUID
        let answer: String
        let hint: String?
        let decoys: [String]
    }

    @Published private(set) var passages: [Passage] = []
    @Published var answers: [UUID: String] = [:]
    @Published private(set) var secondsRemaining: Double = 0
    @Published private(set) var initialTimeTotal: Double = 0
    @Published private(set) var submitAttempts: Int = 0
    @Published private(set) var isFinished: Bool = false
    @Published private(set) var outcome: RawActivityOutcome?

    private var cancellable: AnyCancellable?
    private var startedAt: Date?
    private let difficulty: ReferenceDifficulty
    private let level: ReferenceLevelIndex

    private var maxWrongSubmits: Int = 0

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

    func submit() {
        guard !isFinished else { return }
        let blanks = passages.flatMap { passage in
            passage.segments.compactMap { segment -> Blank? in
                if case .blank(let blank) = segment { return blank }
                return nil
            }
        }

        var correct = 0
        for blank in blanks {
            let value = answers[blank.id]?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            let target = blank.answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if value == target {
                correct += 1
            }
        }

        if correct == blanks.count {
            finishSuccess()
        } else {
            submitAttempts += 1
            if submitAttempts >= maxWrongSubmits {
                finishFailure()
            }
        }
    }

    private func finishSuccess() {
        guard !isFinished else { return }
        isFinished = true
        stop()
        let elapsed = elapsedSeconds()
        let timeRatio = max(0, secondsRemaining / max(initialTimeTotal, 1))
        let stars = computeStars(timeRatio: timeRatio, attempts: submitAttempts + 1)
        let accuracy = 1.0
        outcome = RawActivityOutcome(
            stars: stars,
            seconds: elapsed,
            accuracy: accuracy,
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
        guard let startedAt else { return max(0, initialTimeTotal - secondsRemaining) }
        return Date().timeIntervalSince(startedAt)
    }

    private func computeStars(timeRatio: Double, attempts: Int) -> Int {
        if attempts == 1, timeRatio >= 0.28 {
            return 3
        }
        if attempts <= 3, timeRatio >= 0.12 {
            return 2
        }
        return 1
    }

    private func buildLevel() {
        let content = RecallRaceContent.passages(difficulty: difficulty, level: level)
        passages = content

        let idx = min(level.rawValue, 6)
        switch difficulty {
        case .easy:
            initialTimeTotal = [118, 112, 106, 100, 96, 92, 88][idx]
            maxWrongSubmits = 12
        case .normal:
            initialTimeTotal = [108, 102, 97, 92, 88, 84, 80][idx]
            maxWrongSubmits = 9
        case .hard:
            initialTimeTotal = [92, 86, 81, 76, 72, 68, 64][idx]
            maxWrongSubmits = 7
        }

        secondsRemaining = initialTimeTotal
    }
}

private enum RecallRaceContent {
    static func passages(difficulty: ReferenceDifficulty, level: ReferenceLevelIndex) -> [RecallRaceViewModel.Passage] {
        let hintForEasy = difficulty == .easy
        let includeDecoys = difficulty == .hard
        let setLabel = " — Set \(level.rawValue + 1)"

        func blank(_ answer: String, hint: String?, decoys: [String]) -> RecallRaceViewModel.Segment {
            .blank(
                RecallRaceViewModel.Blank(
                    id: UUID(),
                    answer: answer,
                    hint: hintForEasy ? hint : nil,
                    decoys: includeDecoys ? decoys : []
                )
            )
        }

        switch difficulty {
        case .easy:
            return [
                RecallRaceViewModel.Passage(
                    title: "Passage A\(setLabel)",
                    segments: [
                        .text("A concise "),
                        blank("abstract", hint: "short summary word", decoys: ["summary", "synopsis"]),
                        .text(" helps readers grasp scope before details.")
                    ]
                ),
                RecallRaceViewModel.Passage(
                    title: "Passage B\(setLabel)",
                    segments: [
                        .text("Cross-links reduce "),
                        blank("redundancy", hint: "repetition", decoys: ["overlap", "noise"]),
                        .text(" by pointing to existing explanations.")
                    ]
                ),
                RecallRaceViewModel.Passage(
                    title: "Passage C\(setLabel)",
                    segments: [
                        .text("Footnotes often carry "),
                        blank("citations", hint: "sources", decoys: ["quotes", "tables"]),
                        .text(" without breaking the flow.")
                    ]
                )
            ]
        case .normal:
            return [
                RecallRaceViewModel.Passage(
                    title: "Section I\(setLabel)",
                    segments: [
                        .text("When two entries disagree, favor the one with a clearer "),
                        blank("scope", hint: nil, decoys: []),
                        .text(" statement and a recent revision note.")
                    ]
                ),
                RecallRaceViewModel.Passage(
                    title: "Section II\(setLabel)",
                    segments: [
                        .text("Charts demand reading the axis before comparing "),
                        blank("peaks", hint: nil, decoys: []),
                        .text(" across categories.")
                    ]
                ),
                RecallRaceViewModel.Passage(
                    title: "Section III\(setLabel)",
                    segments: [
                        .text("A structured bibliography saves time when you must "),
                        blank("verify", hint: nil, decoys: []),
                        .text(" a claim quickly.")
                    ]
                ),
                RecallRaceViewModel.Passage(
                    title: "Section IV\(setLabel)",
                    segments: [
                        .text("Headings act as "),
                        blank("signposts", hint: nil, decoys: []),
                        .text(" for scanning long articles.")
                    ]
                )
            ]
        case .hard:
            return [
                RecallRaceViewModel.Passage(
                    title: "Dense A\(setLabel)",
                    segments: [
                        .text("Indexes accelerate lookup, while appendices host "),
                        blank("tabular", hint: nil, decoys: ["linear", "narrative"]),
                        .text(" data that would distract in-line.")
                    ]
                ),
                RecallRaceViewModel.Passage(
                    title: "Dense B\(setLabel)",
                    segments: [
                        .text("If labels are missing, infer units from "),
                        blank("footnotes", hint: nil, decoys: ["captions", "endnotes"]),
                        .text(" near the figure.")
                    ]
                ),
                RecallRaceViewModel.Passage(
                    title: "Dense C\(setLabel)",
                    segments: [
                        .text("Parallel passages should be checked for "),
                        blank("consistent", hint: nil, decoys: ["constant", "distant"]),
                        .text(" terminology across sections.")
                    ]
                ),
                RecallRaceViewModel.Passage(
                    title: "Dense D\(setLabel)",
                    segments: [
                        .text("When blanks look similar, compare "),
                        blank("context", hint: nil, decoys: ["content", "contact"]),
                        .text(" rather than guessing from spelling alone.")
                    ]
                ),
                RecallRaceViewModel.Passage(
                    title: "Dense E\(setLabel)",
                    segments: [
                        .text("A timeline clarifies order when the narrative is "),
                        blank("nonlinear", hint: nil, decoys: ["linear", "sequential"]),
                        .text(" across chapters.")
                    ]
                )
            ]
        }
    }
}
