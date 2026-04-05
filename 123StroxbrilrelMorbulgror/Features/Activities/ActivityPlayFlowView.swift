import SwiftUI

struct ActivityPlayFlowView: View {
    @EnvironmentObject private var progress: ReferenceProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var context: ActivityPlayContext
    @State private var sessionResult: ActivitySessionResult?
    @State private var sessionToken = UUID()

    init(activity: ReferenceActivity, difficulty: ReferenceDifficulty, level: ReferenceLevelIndex) {
        _context = State(initialValue: ActivityPlayContext(activity: activity, difficulty: difficulty, level: level))
    }

    var body: some View {
        Group {
            if let sessionResult {
                ActivityResultView(
                    result: sessionResult,
                    onNextLevel: { goNext(after: sessionResult) },
                    onRetry: {
                        self.sessionResult = nil
                        sessionToken = UUID()
                    },
                    onBackToLevels: { dismiss() },
                    canGoNext: computeNextDestination(after: sessionResult) != nil
                )
            } else {
                gameLayer
                    .id(sessionToken)
            }
        }
    }

    @ViewBuilder
    private var gameLayer: some View {
        switch context.activity {
        case .quickFacts:
            QuickFactsView(difficulty: context.difficulty, level: context.level, onComplete: { finalize($0) })
        case .recallRace:
            RecallRaceView(difficulty: context.difficulty, level: context.level, onComplete: { finalize($0) })
        case .dataDecode:
            DataDecodeView(difficulty: context.difficulty, level: context.level, onComplete: { finalize($0) })
        }
    }

    private func finalize(_ raw: RawActivityOutcome) {
        let before = AchievementEvaluator.unlocked(from: progress)
        progress.recordActivityCompletion(
            activity: context.activity,
            difficulty: context.difficulty,
            level: context.level,
            earnedStars: raw.stars,
            sessionSeconds: raw.seconds
        )
        let after = AchievementEvaluator.unlocked(from: progress)
        let fresh = AchievementEvaluator.newlyUnlocked(before: before, after: after)
        sessionResult = ActivitySessionResult(
            activity: context.activity,
            difficulty: context.difficulty,
            level: context.level,
            starsEarned: raw.stars,
            secondsUsed: raw.seconds,
            accuracy: raw.accuracy,
            succeeded: raw.succeeded,
            newAchievements: fresh
        )
    }

    private func goNext(after result: ActivitySessionResult) {
        guard let dest = computeNextDestination(after: result) else { return }
        context = dest
        sessionResult = nil
        sessionToken = UUID()
    }

    private func computeNextDestination(after result: ActivitySessionResult) -> ActivityPlayContext? {
        guard result.succeeded, result.starsEarned >= 1 else { return nil }

        if result.level != .lastInTrack {
            let nextLevel = ReferenceLevelIndex(rawValue: result.level.rawValue + 1)!
            let candidate = ActivityPlayContext(activity: result.activity, difficulty: result.difficulty, level: nextLevel)
            if progress.isLevelUnlocked(activity: candidate.activity, difficulty: candidate.difficulty, level: candidate.level) {
                return candidate
            }
            return nil
        }

        if result.difficulty != .hard {
            let nextDifficulty = ReferenceDifficulty(rawValue: result.difficulty.rawValue + 1)!
            let candidate = ActivityPlayContext(activity: result.activity, difficulty: nextDifficulty, level: .one)
            if progress.isLevelUnlocked(activity: candidate.activity, difficulty: candidate.difficulty, level: candidate.level) {
                return candidate
            }
        }

        return nil
    }
}

struct RawActivityOutcome: Equatable {
    let stars: Int
    let seconds: TimeInterval
    let accuracy: Double
    let succeeded: Bool
}

struct ActivityPlayContext: Hashable {
    let activity: ReferenceActivity
    let difficulty: ReferenceDifficulty
    let level: ReferenceLevelIndex
}
