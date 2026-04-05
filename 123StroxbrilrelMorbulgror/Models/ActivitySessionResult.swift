import Foundation

struct ActivitySessionResult: Hashable {
    let activity: ReferenceActivity
    let difficulty: ReferenceDifficulty
    let level: ReferenceLevelIndex
    let starsEarned: Int
    let secondsUsed: TimeInterval
    let accuracy: Double
    let succeeded: Bool
    let newAchievements: [AchievementDefinition]
}
