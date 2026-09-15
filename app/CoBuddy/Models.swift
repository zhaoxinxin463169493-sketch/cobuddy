import SwiftUI

// MARK: - Companion

struct Companion: Identifiable, Hashable {
    enum Style: String { case quiet, coach, cafe, midnight }

    let id: String
    let name: String
    let tagline: String
    let style: Style

    var colors: [Color] {
        switch style {
        case .quiet:    return [CB.mint, CB.blue]
        case .coach:    return [Color(red: 1.000, green: 0.702, blue: 0.420), CB.coral]
        case .cafe:     return [Color(red: 1.000, green: 0.851, blue: 0.557), Color(red: 0.969, green: 0.635, blue: 0.231)]
        case .midnight: return [Color(red: 0.557, green: 0.482, blue: 1.000), Color(red: 0.357, green: 0.294, blue: 0.878)]
        }
    }

    var ambient: String {
        switch style {
        case .quiet:    return "You don't have to finish everything."
        case .coach:    return "Five-minute check-ins. Keep going."
        case .cafe:     return "Sounds like a busy café. Nobody is watching."
        case .midnight: return "Late night. Just you and the screen."
        }
    }

    static let all: [Companion] = [
        Companion(id: "nova",     name: "Nova",      tagline: "Quiet. Says nothing. Just stays.", style: .quiet),
        Companion(id: "bo",       name: "Coach Bo",  tagline: "Check-ins every 5 minutes. No excuses.",  style: .coach),
        Companion(id: "sunny",    name: "Sunny",     tagline: "Café hum + soft background noise.",       style: .cafe),
        Companion(id: "midnight", name: "Midnight",  tagline: "For 1am deadlines. Dim and calm.",        style: .midnight)
    ]

    static func by(_ id: String) -> Companion {
        all.first { $0.id == id } ?? all[0]
    }
}

// MARK: - Session

struct FocusSession: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var taskName: String
    var tagName: String
    var companionId: String
    var plannedMinutes: Int
    var focusedSeconds: Int
    var startedAt: Date
    var endedAt: Date
    var mood: String?          // "good" | "strong" | "tired"
    var note: String?
    var completed: Bool

    var isToday: Bool { Calendar.current.isDateInToday(startedAt) }
}

// MARK: - Tags & durations

enum TaskTag: String, CaseIterable, Identifiable {
    case deepWork = "Deep work"
    case study    = "Study"
    case tidyUp   = "Tidy up"
    case email    = "Email"
    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .deepWork: return "🧠"
        case .study:    return "📚"
        case .tidyUp:   return "🧹"
        case .email:    return "✉️"
        }
    }
}

let cbDurations = [15, 25, 45, 60]
