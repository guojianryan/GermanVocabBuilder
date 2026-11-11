import Foundation

enum StudyLevel: String, CaseIterable, Identifiable {
    case a1 = "A1", a2 = "A2", b1 = "B1", b2 = "B2", c1 = "C1"
    var id: String { rawValue }
}

enum NounGender: String, CaseIterable, Sendable {
    case masculine, feminine, neuter
    var article: String {
        switch self { case .masculine: "der"; case .feminine: "die"; case .neuter: "das" }
    }
}

struct LessonIndex: Decodable, Sendable {
    let entries: [WordEntry]
    let lookup: [String: [String]]
}
struct WordEntry: Decodable, Identifiable, Hashable, Sendable {
    let id: String
    let headword: String
    let file: String
    let level: String
    let lessonType: String
    let partOfSpeech: String
    let gender: String?
    let article: String?
    let meaning: String
    let forms: [String]
    let related: [String]
    let searchKeys: [String]
    var nounGender: NounGender? { gender.flatMap(NounGender.init(rawValue:)) }
    var badgeText: String {
        if let article { return article }
        let verb = headword.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "^(?:\\(sich\\)|sich)\\s+", with: "", options: [.regularExpression, .caseInsensitive])
        return verb.first(where: { $0.isLetter }).map { String($0).uppercased() } ?? ""
    }
    var displayWord: String { [article, headword].compactMap { $0 }.joined(separator: " ") }
    var kind: String {
        if gender != nil { return "Noun" }
        if partOfSpeech.contains("verb") && !partOfSpeech.contains("adverb") { return "Verb" }
        if partOfSpeech.contains("adjective") { return "Adjective" }
        return "Expression"
    }
}
struct Lesson: Decodable, Sendable {
    struct Word: Decodable, Sendable {
        struct Pronunciation: Decodable, Sendable { let respelling: String?; let ipa: String?; let notes: String? }
        let headword: String
        let meaning: String
        let pronunciation: Pronunciation?
    }
    struct Etymology: Decodable, Sendable {
        struct Part: Decodable, Sendable {
            let part: String
            let meaning: String
            let emphasis: String?
        }
        let parts: [Part]?
        let literalMeaning: String?
    }
    struct BannerSegment: Sendable {
        let text: String
        let emphasis: String?
    }
    let etymology: Etymology?
    var bannerSegments: [BannerSegment] {
        let parts = etymology?.parts ?? []
        var remainder = word.headword[...]
        var pieces: [String] = []
        for part in parts {
            let root = part.part.trimmingCharacters(in: CharacterSet(charactersIn: "-")).lowercased()
            let length = stride(from: min(root.count, remainder.count), through: 1, by: -1).first {
                remainder.prefix($0).lowercased() == String(root.prefix($0))
            }
            guard let length else { return [BannerSegment(text: word.headword, emphasis: nil)] }
            pieces.append(String(remainder.prefix(length)))
            remainder = remainder.dropFirst(length)
        }
        guard !pieces.isEmpty else { return [BannerSegment(text: word.headword, emphasis: nil)] }
        pieces[pieces.count - 1] += remainder
        let hasExplicitEmphasis = parts.contains { $0.emphasis != nil }
        return pieces.enumerated().map { i, text in
            let emphasis: String?
            if hasExplicitEmphasis {
                emphasis = ["stretch", "arrive", "release", "rise", "turn"].contains(parts[i].emphasis ?? "") ? parts[i].emphasis : nil
            } else {
                emphasis = i == 1 ? (pieces.count == 2 ? "arrive" : "stretch") : nil
            }
            return BannerSegment(text: text, emphasis: emphasis)
        }
    }
    struct Sentence: Decodable, Sendable { let german: String; let english: String }
    let word: Word
    let sampleSentences: [Sentence]
    let quiz: [Question]
    let memoryHook: String
}
struct Question: Decodable, Sendable {
    let id: String
    let type: String
    let prompt: String
    let options: [String]?
    let answer: String?
    let fullAnswer: String?
    let acceptedAnswers: [String]?
    let explanation: String?
    func accepts(_ input: String) -> Bool {
        ([answer, fullAnswer].compactMap { $0 } + (acceptedAnswers ?? [])).contains { Self.normalize($0) == Self.normalize(input) }
    }
    static func normalize(_ input: String) -> String {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .caseInsensitive, locale: Locale(identifier: "de_DE"))
            .replacingOccurrences(of: "[.!?]+$", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
enum WordSearch {
    static func fold(_ input: String) -> String {
        input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "^\\(sich\\)\\s*", with: "", options: .regularExpression)
            .replacingOccurrences(of: "ä|ae", with: "a", options: .regularExpression)
            .replacingOccurrences(of: "ö|oe", with: "o", options: .regularExpression)
            .replacingOccurrences(of: "ü|ue", with: "u", options: .regularExpression)
            .replacingOccurrences(of: "ß", with: "ss")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    /// Normalization and alphabetical ordering happen once, away from the UI thread.
    struct PreparedIndex: Sendable {
        private struct Record: Sendable {
            let entry: WordEntry
            let headword: String
            let forms: [String]
            let prefixes: [String]
            let formPrefixes: [String]
        }
        private let records: [Record]
        private let lookup: [String: [String]]
        init(_ index: LessonIndex) {
            lookup = index.lookup
            func prefixes(_ strings: [String]) -> [String] {
                strings.flatMap { [$0] + $0.split(separator: " ").map(String.init) }
            }
            records = index.entries.sorted {
                $0.headword.localizedCaseInsensitiveCompare($1.headword) == .orderedAscending
            }.map { entry in
                let forms = entry.forms.map(WordSearch.fold)
                return Record(entry: entry, headword: WordSearch.fold(entry.headword), forms: forms,
                              prefixes: prefixes(entry.searchKeys.map(WordSearch.fold) + [WordSearch.fold(entry.meaning)]),
                              formPrefixes: prefixes(forms))
            }
        }
        func results(_ query: String, level: String = "All", category: String = "All words") throws -> [WordEntry] {
            let q = WordSearch.fold(query)
            let exact = Set(lookup[q] ?? [])
            var buckets = [[WordEntry]](repeating: [], count: 4)
            for record in records {
                try Task.checkCancellation()
                let entry = record.entry
                guard (level == "All" || entry.level == level),
                      (category == "All words" || entry.kind + "s" == category) else { continue }
                let rank: Int
                if q.isEmpty || record.headword == q { rank = 0 }
                else if record.forms.contains(q) { rank = 1 }
                else if record.formPrefixes.contains(where: { $0.hasPrefix(q) }) { rank = 2 }
                else if exact.contains(entry.id) || record.prefixes.contains(where: { $0.hasPrefix(q) }) { rank = 3 }
                else { continue }
                buckets[rank].append(entry)
            }
            return buckets.flatMap { $0 }
        }
    }
    static func results(_ query: String, in index: LessonIndex) -> [WordEntry] {
        if fold(query).isEmpty { return index.entries }
        return (try? PreparedIndex(index).results(query)) ?? []
    }
}

/// Actor isolation keeps preparation, filtering and ranking off the main actor.
actor WordSearchEngine {
    private let index: LessonIndex
    private var prepared: WordSearch.PreparedIndex?
    init(index: LessonIndex) { self.index = index }
    func prepare() throws {
        try Task.checkCancellation()
        if prepared == nil { prepared = WordSearch.PreparedIndex(index) }
    }
    func results(_ query: String, level: String, category: String) throws -> [WordEntry] {
        try Task.checkCancellation()
        try prepare()
        return try prepared!.results(query, level: level, category: category)
    }
}

struct LibraryCatalog: Sendable {
    let index: LessonIndex
    let entriesByID: [String: WordEntry]
    init(index: LessonIndex) {
        self.index = index
        entriesByID = Dictionary(index.entries.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }
    func words(for ids: [String]) -> [WordEntry] { ids.compactMap { entriesByID[$0] } }
}

struct PracticeItem: Identifiable, Sendable {
    let id = UUID()
    let entry: WordEntry
    let question: Question?
}

/// All lesson I/O and decoding is isolated from the UI. Cache is bounded by count and raw JSON bytes.
actor LessonRepository {
    struct ReaderSource: Sendable {
        let template: String
        let json: String
    }
    private struct CachedLesson {
        let lesson: Lesson
        let json: String
        let bytes: Int
    }
    private let resourceRoot: URL
    private let cacheLimit: Int
    private let byteLimit: Int
    private var cache: [String: CachedLesson] = [:]
    private var recency: [String] = []
    private var cacheBytes = 0
    private var catalog: LibraryCatalog?
    private var template: String?
    init(resourceRoot: URL, cacheLimit: Int = 32, byteLimit: Int = 4 * 1024 * 1024) {
        self.resourceRoot = resourceRoot
        self.cacheLimit = max(0, cacheLimit)
        self.byteLimit = max(0, byteLimit)
    }
    func loadCatalog() throws -> LibraryCatalog {
        try Task.checkCancellation()
        if let catalog { return catalog }
        let data = try Data(contentsOf: resourceRoot.appendingPathComponent("lessons/index.json"))
        let value = LibraryCatalog(index: try JSONDecoder().decode(LessonIndex.self, from: data))
        try Task.checkCancellation()
        catalog = value
        return value
    }
    func lesson(_ entry: WordEntry) throws -> Lesson { try resource(entry).lesson }
    func readerSource(_ entry: WordEntry) throws -> ReaderSource {
        let loaded = try resource(entry)
        if template == nil {
            template = try String(contentsOf: resourceRoot.appendingPathComponent("lesson-template.html"), encoding: .utf8)
        }
        return ReaderSource(template: template!, json: loaded.json)
    }
    func practiceItems(_ entries: [WordEntry], quiz: Bool) throws -> [PracticeItem] {
        var items: [PracticeItem] = []
        for entry in entries.shuffled() {
            try Task.checkCancellation()
            if quiz {
                let value = try resource(entry).lesson
                items += value.quiz.map { PracticeItem(entry: entry, question: $0) }
            } else {
                // Flashcards load only the active card's lesson, not the entire deck.
                items.append(PracticeItem(entry: entry, question: nil))
            }
        }
        if quiz && Set(entries.map(\.id)).count > 1 { items.shuffle() }
        try Task.checkCancellation()
        return items
    }
    var cachedLessonCount: Int { cache.count }
    var cachedJSONBytes: Int { cacheBytes }
    func clearCache() { cache = [:]; recency = []; cacheBytes = 0 }
    private func resource(_ entry: WordEntry) throws -> CachedLesson {
        try Task.checkCancellation()
        if let value = cache[entry.id] {
            recency.removeAll { $0 == entry.id }
            recency.append(entry.id)
            return value
        }
        let data = try Data(contentsOf: resourceRoot.appendingPathComponent("lessons").appendingPathComponent(entry.file))
        let lesson = try JSONDecoder().decode(Lesson.self, from: data)
        guard let json = String(data: data, encoding: .utf8) else { throw CocoaError(.fileReadInapplicableStringEncoding) }
        try Task.checkCancellation()
        let value = CachedLesson(lesson: lesson, json: json, bytes: data.count)
        if cacheLimit > 0 && value.bytes <= byteLimit {
            cache[entry.id] = value
            recency.append(entry.id)
            cacheBytes += value.bytes
            while cache.count > cacheLimit || cacheBytes > byteLimit {
                let oldest = recency.removeFirst()
                if let removed = cache.removeValue(forKey: oldest) { cacheBytes -= removed.bytes }
            }
        }
        return value
    }
}

/// Calendar-day scheduling, independent of UI and storage.
struct ReviewProgress: Codable, Equatable, Sendable {
    static let intervals = [1, 3, 7, 14, 30]
    private(set) var stage = 0
    private(set) var nextReview: Date
    private(set) var lastPracticed: Date?

    init(due: Date) { nextReview = due }
    func isDue(at now: Date, calendar: Calendar = .current) -> Bool {
        nextReview <= calendar.startOfDay(for: now)
    }
    mutating func record(success: Bool, at now: Date, calendar: Calendar = .current) {
        let today = calendar.startOfDay(for: now)
        let practicedToday = lastPracticed.map { calendar.isDate($0, inSameDayAs: now) } ?? false
        if !success {
            stage = 0
            nextReview = calendar.date(byAdding: .day, value: 1, to: today)!
        } else if !practicedToday && isDue(at: now, calendar: calendar) {
            stage = min(stage + 1, Self.intervals.count)
            nextReview = calendar.date(byAdding: .day, value: Self.intervals[max(0, stage - 1)], to: today)!
        }
        // Early or repeated successes cannot move a word through several stages in one day.
        lastPracticed = now
    }
    func successHint(at now: Date, calendar: Calendar = .current) -> String {
        var projected = self
        projected.record(success: true, at: now, calendar: calendar)
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: projected.nextReview).day ?? 1
        return days <= 1 ? "Review tomorrow" : "In \(days) days"
    }
    static func migrate(_ history: [String: Bool], at now: Date, calendar: Calendar = .current) -> [String: Self] {
        // Old results have no dates or reliable stage information: review them today.
        history.mapValues { _ in Self(due: calendar.startOfDay(for: now)) }
    }
}

/// A local-calendar daily set. Its selection stays fixed until the next day.
struct DailyFive: Codable, Equatable {
    let day: String
    let level: String
    let wordIDs: [String]
    var outcomes: [String: Bool] = [:]
    var completedCount: Int { wordIDs.filter { outcomes[$0] != nil }.count }
    var isComplete: Bool { !wordIDs.isEmpty && completedCount == wordIDs.count }

    static func dayKey(_ date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.era, .year, .month, .day], from: date)
        return "\(parts.era ?? 0)-\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }

    /// Due words first (oldest first), then genuinely new words. Never bring future reviews forward.
    static func make(day: String, level: String, candidates: [WordEntry], reviews: [String: ReviewProgress],
                     now: Date = Date(), calendar: Calendar = .current) -> Self {
        let eligible = candidates.filter { $0.level == level }
        let due = eligible.filter { reviews[$0.id]?.isDue(at: now, calendar: calendar) == true }.sorted {
            let first = reviews[$0.id]!.nextReview, second = reviews[$1.id]!.nextReview
            return first == second ? $0.id < $1.id : first < second
        }
        let new = eligible.filter { reviews[$0.id] == nil }
        return Self(day: day, level: level, wordIDs: Array((due + new).prefix(5)).map(\.id))
    }

    mutating func record(_ id: String, success: Bool) {
        guard wordIDs.contains(id), outcomes[id] == nil else { return }
        outcomes[id] = success
    }
}
