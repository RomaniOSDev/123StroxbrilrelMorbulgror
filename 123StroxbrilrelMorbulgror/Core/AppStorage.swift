import Combine
import Foundation

@MainActor
final class ReferenceProgressStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "ref.hasSeenOnboarding"
        static let totalPlaySeconds = "ref.totalPlaySeconds"
        static let activitiesCompleted = "ref.activitiesCompleted"
        static func starsKey(activity: Int, difficulty: Int, level: Int) -> String {
            "ref.stars.a\(activity).d\(difficulty).l\(level)"
        }
    }

    private let defaults: UserDefaults

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var totalPlaySeconds: Double
    @Published private(set) var activitiesCompleted: Int

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalPlaySeconds = defaults.double(forKey: Keys.totalPlaySeconds)
        activitiesCompleted = defaults.integer(forKey: Keys.activitiesCompleted)
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
    }

    func stars(for activity: ReferenceActivity, difficulty: ReferenceDifficulty, level: ReferenceLevelIndex) -> Int {
        let key = Keys.starsKey(activity: activity.rawValue, difficulty: difficulty.rawValue, level: level.rawValue)
        return min(3, max(0, defaults.integer(forKey: key)))
    }

    func recordActivityCompletion(
        activity: ReferenceActivity,
        difficulty: ReferenceDifficulty,
        level: ReferenceLevelIndex,
        earnedStars: Int,
        sessionSeconds: TimeInterval
    ) {
        let key = Keys.starsKey(activity: activity.rawValue, difficulty: difficulty.rawValue, level: level.rawValue)
        let previous = defaults.integer(forKey: key)
        let merged = max(previous, min(3, max(0, earnedStars)))
        defaults.set(merged, forKey: key)

        totalPlaySeconds += max(0, sessionSeconds)
        defaults.set(totalPlaySeconds, forKey: Keys.totalPlaySeconds)

        activitiesCompleted += 1
        defaults.set(activitiesCompleted, forKey: Keys.activitiesCompleted)

        objectWillChange.send()
    }

    func totalStarsEarned() -> Int {
        var sum = 0
        for a in ReferenceActivity.allCases {
            for d in ReferenceDifficulty.allCases {
                for l in ReferenceLevelIndex.allCases {
                    sum += stars(for: a, difficulty: d, level: l)
                }
            }
        }
        return sum
    }

    func hasAnyThreeStarLevel() -> Bool {
        for a in ReferenceActivity.allCases {
            for d in ReferenceDifficulty.allCases {
                for l in ReferenceLevelIndex.allCases {
                    if stars(for: a, difficulty: d, level: l) >= 3 {
                        return true
                    }
                }
            }
        }
        return false
    }

    func hasTouchedEachActivityType() -> Bool {
        var touched = Set<Int>()
        for a in ReferenceActivity.allCases {
            for d in ReferenceDifficulty.allCases {
                for l in ReferenceLevelIndex.allCases {
                    if stars(for: a, difficulty: d, level: l) > 0 {
                        touched.insert(a.rawValue)
                    }
                }
            }
        }
        return touched.count >= ReferenceActivity.allCases.count
    }

    func isLevelUnlocked(activity: ReferenceActivity, difficulty: ReferenceDifficulty, level: ReferenceLevelIndex) -> Bool {
        switch difficulty {
        case .easy:
            if level == .one { return true }
            let previous = ReferenceLevelIndex(rawValue: level.rawValue - 1) ?? .one
            return stars(for: activity, difficulty: .easy, level: previous) >= 1
        case .normal:
            if level == .one {
                return stars(for: activity, difficulty: .easy, level: .lastInTrack) >= 1
            }
            let previous = ReferenceLevelIndex(rawValue: level.rawValue - 1) ?? .one
            return stars(for: activity, difficulty: .normal, level: previous) >= 1
        case .hard:
            if level == .one {
                return stars(for: activity, difficulty: .normal, level: .lastInTrack) >= 1
            }
            let previous = ReferenceLevelIndex(rawValue: level.rawValue - 1) ?? .one
            return stars(for: activity, difficulty: .hard, level: previous) >= 1
        }
    }

    func resetAllProgress() {
        defaults.removeObject(forKey: Keys.hasSeenOnboarding)
        defaults.removeObject(forKey: Keys.totalPlaySeconds)
        defaults.removeObject(forKey: Keys.activitiesCompleted)
        for a in ReferenceActivity.allCases {
            for d in ReferenceDifficulty.allCases {
                for l in ReferenceLevelIndex.allCases {
                    defaults.removeObject(forKey: Keys.starsKey(activity: a.rawValue, difficulty: d.rawValue, level: l.rawValue))
                }
            }
        }
        hasSeenOnboarding = false
        totalPlaySeconds = 0
        activitiesCompleted = 0
        objectWillChange.send()
        NotificationCenter.default.post(name: .referenceProgressDidReset, object: nil)
    }
}

struct AchievementDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_finish",
            title: "First Finish",
            detail: "Complete any level once."
        ),
        AchievementDefinition(
            id: "star_gatherer",
            title: "Star Gatherer",
            detail: "Collect 12 total stars across activities."
        ),
        AchievementDefinition(
            id: "steady_focus",
            title: "Steady Focus",
            detail: "Spend at least 10 minutes learning in the app."
        ),
        AchievementDefinition(
            id: "triple_mark",
            title: "Triple Mark",
            detail: "Earn three stars on any single level."
        ),
        AchievementDefinition(
            id: "wide_reader",
            title: "Wide Reader",
            detail: "Earn stars in every activity type."
        )
    ]
}

enum AchievementEvaluator {
    static func unlocked(from store: ReferenceProgressStore) -> Set<String> {
        var set = Set<String>()
        if store.activitiesCompleted >= 1 {
            set.insert("first_finish")
        }
        if store.totalStarsEarned() >= 12 {
            set.insert("star_gatherer")
        }
        if store.totalPlaySeconds >= 600 {
            set.insert("steady_focus")
        }
        if store.hasAnyThreeStarLevel() {
            set.insert("triple_mark")
        }
        if store.hasTouchedEachActivityType() {
            set.insert("wide_reader")
        }
        return set
    }

    static func newlyUnlocked(before: Set<String>, after: Set<String>) -> [AchievementDefinition] {
        let newIds = after.subtracting(before)
        return AchievementDefinition.all.filter { newIds.contains($0.id) }
    }
}
