import Foundation

enum ReferenceActivity: Int, CaseIterable, Identifiable {
    case quickFacts = 0
    case recallRace = 1
    case dataDecode = 2

    var id: Int { rawValue }

    var titleKey: String {
        switch self {
        case .quickFacts: return "Quick Facts Challenge"
        case .recallRace: return "Reference Recall Race"
        case .dataDecode: return "Data Decode"
        }
    }

    var detail: String {
        switch self {
        case .quickFacts:
            return "Match short facts to the correct topic labels under time pressure."
        case .recallRace:
            return "Read brief passages and restore missing terms with precision."
        case .dataDecode:
            return "Read charts and answer focused questions about the values shown."
        }
    }
}

enum ReferenceDifficulty: Int, CaseIterable, Identifiable {
    case easy = 0
    case normal = 1
    case hard = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }
}

enum ReferenceLevelIndex: Int, CaseIterable, Identifiable {
    case one = 0
    case two = 1
    case three = 2
    case four = 3
    case five = 4
    case six = 5
    case seven = 6

    var id: Int { rawValue }

    var displayTitle: String {
        "Level \(rawValue + 1)"
    }

    /// Last level within a difficulty track (unlocks the next difficulty’s Level 1).
    static var lastInTrack: ReferenceLevelIndex {
        ReferenceLevelIndex.allCases.last ?? .one
    }
}

extension Notification.Name {
    static let referenceProgressDidReset = Notification.Name("referenceProgressDidReset")
}
