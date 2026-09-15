import Foundation
import Combine

/// Local-only persistence (JSON file). No account, no backend, no analytics.
final class SessionStore: ObservableObject {
    @Published private(set) var sessions: [FocusSession] = []

    @Published var companionId: String = "nova"
    @Published var tagName: String = TaskTag.deepWork.rawValue
    @Published var durationMinutes: Int = 25
    @Published var lastTaskName: String = ""

    private let fileURL: URL

    init() {
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("CoBuddy", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent("sessions.json")
        load()
    }

    // MARK: - Mutations

    func add(_ session: FocusSession) {
        sessions.append(session)
        lastTaskName = session.taskName
        save()
    }

    func updateMood(_ sessionId: UUID, mood: String) {
        guard let i = sessions.firstIndex(where: { $0.id == sessionId }) else { return }
        sessions[i].mood = mood
        save()
    }

    func updateNote(_ sessionId: UUID, note: String) {
        guard let i = sessions.firstIndex(where: { $0.id == sessionId }) else { return }
        sessions[i].note = note.isEmpty ? nil : note
        save()
    }

    // MARK: - Aggregates

    var secondsToday: Int {
        sessions.filter { $0.isToday }.reduce(0) { $0 + $1.focusedSeconds }
    }

    var secondsThisWeek: Int {
        let cal = Calendar.current
        guard let week = cal.dateInterval(of: .weekOfYear, for: Date()) else { return 0 }
        return sessions.filter { week.contains($0.startedAt) }
            .reduce(0) { $0 + $1.focusedSeconds }
    }

    var sessionsThisWeek: Int {
        let cal = Calendar.current
        guard let week = cal.dateInterval(of: .weekOfYear, for: Date()) else { return 0 }
        return sessions.filter { week.contains($0.startedAt) }.count
    }

    /// Consecutive days (ending today or yesterday) with at least one session.
    var streak: Int {
        let cal = Calendar.current
        let days = Set(sessions.map { cal.startOfDay(for: $0.startedAt) })
        guard !days.isEmpty else { return 0 }

        var cursor = cal.startOfDay(for: Date())
        if !days.contains(cursor) {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: cursor),
                  days.contains(yesterday) else { return 0 }
            cursor = yesterday
        }
        var count = 0
        while days.contains(cursor) {
            count += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return count
    }

    var bestStreak: Int {
        let cal = Calendar.current
        let sorted = Set(sessions.map { cal.startOfDay(for: $0.startedAt) }).sorted()
        var best = 0, run = 0
        var previous: Date?
        for day in sorted {
            if let p = previous,
               let next = cal.date(byAdding: .day, value: 1, to: p),
               cal.isDate(next, inSameDayAs: day) {
                run += 1
            } else {
                run = 1
            }
            best = max(best, run)
            previous = day
        }
        return best
    }

    /// Last 7 days, oldest first.
    func lastWeek() -> [(day: Date, seconds: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { offset in
            guard let day = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let total = sessions
                .filter { cal.isDate($0.startedAt, inSameDayAs: day) }
                .reduce(0) { $0 + $1.focusedSeconds }
            return (day, total)
        }
    }

    func secondsByTag() -> [(tag: String, seconds: Int)] {
        let cal = Calendar.current
        guard let week = cal.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        var map: [String: Int] = [:]
        for s in sessions where week.contains(s.startedAt) {
            map[s.tagName, default: 0] += s.focusedSeconds
        }
        return map.map { (tag: $0.key, seconds: $0.value) }
            .sorted { $0.seconds > $1.seconds }
    }

    // MARK: - Disk

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        sessions = (try? decoder.decode([FocusSession].self, from: data)) ?? []
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted]
        guard let data = try? encoder.encode(sessions) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
