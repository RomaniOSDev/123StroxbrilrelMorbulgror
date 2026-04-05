import Combine
import Foundation

@MainActor
final class DataDecodeViewModel: ObservableObject {
    struct ChartItem: Identifiable {
        let label: String
        let value: Double
        var id: String { label }
    }

    @Published private(set) var items: [ChartItem] = []
    @Published private(set) var showAxisLabels: Bool = true
    @Published private(set) var secondsRemaining: Double = 0
    @Published private(set) var initialTimeTotal: Double = 0

    @Published var toggleAnswers: [Int: Bool] = [:]
    @Published var numericAnswers: [Int: String] = [:]

    @Published private(set) var phase: Int = 0
    @Published private(set) var isFinished: Bool = false
    @Published private(set) var outcome: RawActivityOutcome?

    private var cancellable: AnyCancellable?
    private var startedAt: Date?
    let difficulty: ReferenceDifficulty
    private let level: ReferenceLevelIndex

    private var checksUsed: Int = 0
    private var maxChecks: Int = 0

    private var validations: [() -> Bool] = []

    init(difficulty: ReferenceDifficulty, level: ReferenceLevelIndex) {
        self.difficulty = difficulty
        self.level = level
        buildLevel()
    }

    /// Reassigns the dictionary so `@Published` reliably notifies observers (subscript-only mutation can skip updates).
    func setNumericAnswer(index: Int, value: String) {
        var next = numericAnswers
        next[index] = value
        numericAnswers = next
    }

    func setToggleAnswer(index: Int, value: Bool) {
        var next = toggleAnswers
        next[index] = value
        toggleAnswers = next
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

    func submitPhase() {
        guard !isFinished else { return }
        guard phase < validations.count else { return }
        let ok = validations[phase]()
        if !ok {
            checksUsed += 1
            if checksUsed >= maxChecks {
                finishFailure()
            }
            return
        }

        if phase < validations.count - 1 {
            phase += 1
        } else {
            finishSuccess()
        }
    }

    private func finishSuccess() {
        guard !isFinished else { return }
        isFinished = true
        stop()
        let elapsed = elapsedSeconds()
        let timeRatio = max(0, secondsRemaining / max(initialTimeTotal, 1))
        let stars = computeStars(timeRatio: timeRatio, checks: checksUsed + 1)
        outcome = RawActivityOutcome(
            stars: stars,
            seconds: elapsed,
            accuracy: 1.0,
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

    private func computeStars(timeRatio: Double, checks: Int) -> Int {
        if checks == 1, timeRatio >= 0.25 {
            return 3
        }
        if checks <= 3, timeRatio >= 0.08 {
            return 2
        }
        return 1
    }

    private func buildLevel() {
        checksUsed = 0
        phase = 0
        validations = []

        let baseItems: [ChartItem] = [
            ChartItem(label: "Jan", value: 12),
            ChartItem(label: "Feb", value: 16),
            ChartItem(label: "Mar", value: 9),
            ChartItem(label: "Apr", value: 14),
            ChartItem(label: "May", value: 21)
        ]

        let idx = min(level.rawValue, 6)
        switch difficulty {
        case .easy:
            items = Array(baseItems.prefix(4))
            showAxisLabels = true
            initialTimeTotal = [96, 91, 86, 81, 77, 73, 69][idx]
            maxChecks = 10
            validations = [
                { [weak self] in
                    guard let self else { return false }
                    let v = self.toggleAnswers[0] ?? false
                    return v == true
                },
                { [weak self] in
                    guard let self else { return false }
                    let text = self.numericAnswers[1]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    return text == "14"
                }
            ]
            setToggleAnswer(index: 0, value: false)
            setNumericAnswer(index: 1, value: "")
        case .normal:
            items = baseItems
            showAxisLabels = false
            initialTimeTotal = [88, 84, 80, 76, 72, 70, 66][idx]
            maxChecks = 9
            validations = [
                { [weak self] in
                    guard let self else { return false }
                    let v = self.toggleAnswers[0] ?? false
                    return v == false
                },
                { [weak self] in
                    guard let self else { return false }
                    let text = self.numericAnswers[1]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    return Int(text) == 12
                }
            ]
            setToggleAnswer(index: 0, value: false)
            setNumericAnswer(index: 1, value: "")
        case .hard:
            items = baseItems
            showAxisLabels = false
            initialTimeTotal = [74, 70, 66, 62, 58, 55, 52][idx]
            maxChecks = 8
            validations = [
                { [weak self] in
                    guard let self else { return false }
                    let text = self.numericAnswers[0]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    guard let value = Double(text) else { return false }
                    return abs(value - 33) < 0.01
                }
            ]
            setNumericAnswer(index: 0, value: "")
        }

        secondsRemaining = initialTimeTotal
    }
}
