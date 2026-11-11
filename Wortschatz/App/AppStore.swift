import SwiftUI
import AVFoundation

@MainActor @Observable final class AppStore {
    var theme: AppTheme { didSet { defaults.set(theme.rawValue, forKey: "appearance.theme.v1") } }
    var studyLevel: StudyLevel { didSet { defaults.set(studyLevel.rawValue, forKey: "studyLevel.v1"); refreshDailyFive() } }
    private(set) var searchEngine: WordSearchEngine?
    private(set) var index: LessonIndex?
    private(set) var isLoadingLibrary = true
    var loadError: String?
    var deck: [String] {
        didSet {
            deckIDs = Set(deck)
            refreshDeckWords()
            defaults.set(deck, forKey: "studyDeck.v1")
        }
    }
    private(set) var dailyFive: DailyFive?
    private(set) var reviews: [String: ReviewProgress] = [:]
    private(set) var reviewClock = Date()
    var dailyWords: [WordEntry] { catalog?.words(for: dailyFive?.wordIDs ?? []) ?? [] }
    var dailyRemainingWords: [WordEntry] { dailyWords.filter { dailyFive?.outcomes[$0.id] == nil } }
    private(set) var deckWords: [WordEntry] = []
    private(set) var deckIDs: Set<String>
    /// Deck words marked for removal; they stay in the deck until the user confirms on leaving My Deck.
    private(set) var pendingRemoval: Set<String> = []
    @ObservationIgnored let readerPool = LessonWebViewPool()
    @ObservationIgnored private var catalog: LibraryCatalog?
    @ObservationIgnored private var loading = false
    @ObservationIgnored private let repository: LessonRepository
    private let defaults: UserDefaults
    private let speaker = AVSpeechSynthesizer()
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: "dailyFive.v1") {
            dailyFive = try? JSONDecoder().decode(DailyFive.self, from: data)
        }
        if let data = defaults.data(forKey: "reviewSchedule.v1"),
           let saved = try? JSONDecoder().decode([String: ReviewProgress].self, from: data) {
            reviews = saved
        } else {
            let old = defaults.data(forKey: "recallHistory.v1").flatMap { try? JSONDecoder().decode([String: Bool].self, from: $0) } ?? [:]
            let migrated = ReviewProgress.migrate(old, at: Date())
            reviews = migrated
            if let data = try? JSONEncoder().encode(migrated) { defaults.set(data, forKey: "reviewSchedule.v1") }
        }
        theme = AppTheme(rawValue: defaults.string(forKey: "appearance.theme.v1") ?? "") ?? .warm
        studyLevel = StudyLevel(rawValue: defaults.string(forKey: "studyLevel.v1") ?? "") ?? .a1
        let savedDeck = defaults.stringArray(forKey: "studyDeck.v1") ?? []
        deck = savedDeck
        deckIDs = Set(savedDeck)
        repository = LessonRepository(resourceRoot: Bundle.main.resourceURL ?? Bundle.main.bundleURL)
    }
    func loadLibrary() async {
        guard index == nil && !loading else { return }
        loading = true
        isLoadingLibrary = true
        loadError = nil
        defer { loading = false; isLoadingLibrary = false }
        do {
            let loaded = try await repository.loadCatalog()
            try Task.checkCancellation()
            catalog = loaded
            index = loaded.index
            refreshDeckWords()
            refreshDailyFive()
            Task { @MainActor [weak self] in
                await Task.yield()
                self?.readerPool.prepare()
            }
            let engine = WordSearchEngine(index: loaded.index)
            searchEngine = engine
            Task { try? await engine.prepare() }
        } catch is CancellationError {
            return
        } catch { loadError = "The lesson library couldn’t be opened. \(error.localizedDescription)" }
    }
    func refreshDailyFive(now: Date = Date()) {
        reviewClock = now
        guard let index else { return }
        let day = DailyFive.dayKey(now)
        if let dailyFive, dailyFive.day == day, !dailyFive.wordIDs.isEmpty,
           dailyFive.level == studyLevel.rawValue || dailyFive.completedCount > 0 { return }
        dailyFive = DailyFive.make(day: day, level: studyLevel.rawValue,
                                   candidates: index.entries.shuffled(), reviews: reviews, now: now)
        persistDailyFive()
    }
    private func persistDailyFive() {
        if let dailyFive, let data = try? JSONEncoder().encode(dailyFive) {
            defaults.set(data, forKey: "dailyFive.v1")
        }
    }
    func dueWords(level: String) -> [WordEntry] {
        let ids = reviews.keys.filter { reviews[$0]!.isDue(at: reviewClock) }.sorted {
            let first = reviews[$0]!.nextReview, second = reviews[$1]!.nextReview
            return first == second ? $0 < $1 : first < second
        }
        return (catalog?.words(for: ids) ?? []).filter { $0.level == level }
    }
    func reviewHint(_ entry: WordEntry) -> String {
        (reviews[entry.id] ?? ReviewProgress(due: Calendar.current.startOfDay(for: reviewClock))).successHint(at: reviewClock)
    }
    func recordRecall(_ entry: WordEntry, success: Bool, dailyDay: String? = nil) {
        let now = Date()
        reviewClock = now
        var progress = reviews[entry.id] ?? ReviewProgress(due: Calendar.current.startOfDay(for: now))
        progress.record(success: success, at: now)
        reviews[entry.id] = progress
        if let data = try? JSONEncoder().encode(reviews) { defaults.set(data, forKey: "reviewSchedule.v1") }
        if let dailyDay, dailyFive?.day == dailyDay {
            dailyFive?.record(entry.id, success: success)
            persistDailyFive()
        }
    }
    private func refreshDeckWords() { deckWords = catalog?.words(for: deck) ?? [] }
    func contains(_ e: WordEntry) -> Bool { deckIDs.contains(e.id) }
    func toggle(_ e: WordEntry) {
        if contains(e) { deck.removeAll { $0 == e.id } } else { deck.append(e.id) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    func isMarkedForRemoval(_ e: WordEntry) -> Bool { pendingRemoval.contains(e.id) }
    func toggleRemovalMark(_ e: WordEntry) {
        if !pendingRemoval.insert(e.id).inserted { pendingRemoval.remove(e.id) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    func commitRemovals() {
        let ids = pendingRemoval
        pendingRemoval = []
        deck.removeAll { ids.contains($0) }
    }
    func discardRemovals() { pendingRemoval = [] }
    func lesson(_ e: WordEntry) async throws -> Lesson { try await repository.lesson(e) }
    func readerSource(_ e: WordEntry) async throws -> LessonRepository.ReaderSource { try await repository.readerSource(e) }
    func practiceItems(_ entries: [WordEntry], quiz: Bool) async throws -> [PracticeItem] {
        try await repository.practiceItems(entries, quiz: quiz)
    }
    func clearLessonCache() async { readerPool.clear(); await repository.clearCache() }
    func speak(_ text: String) {
        speaker.stopSpeaking(at: .immediate)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        utterance.rate = 0.43
        speaker.speak(utterance)
    }
    func stopAudio() { speaker.stopSpeaking(at: .immediate) }
}

@main struct WortschatzApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var store: AppStore
    init() {
        var defaults = UserDefaults.standard
        #if DEBUG
        if let suite = ProcessInfo.processInfo.environment["WORTSCHATZ_TEST_DEFAULTS"],
           suite.hasPrefix("Wortschatz.UITests."), let isolated = UserDefaults(suiteName: suite) {
            if ProcessInfo.processInfo.environment["WORTSCHATZ_TEST_REVIEWS"] == "legacyDue",
               isolated.data(forKey: "reviewSchedule.v1") == nil,
               isolated.data(forKey: "recallHistory.v1") == nil {
                let legacy = Dictionary(uniqueKeysWithValues: ["apfel", "haus", "tisch", "buch", "hund", "brot", "wasser"].map { ($0, true) })
                isolated.set(try? JSONEncoder().encode(legacy), forKey: "recallHistory.v1")
            }
            defaults = isolated
        }
        #endif
        _store = State(initialValue: AppStore(defaults: defaults))
    }
    var body: some Scene {
        WindowGroup { RootView().environment(store).environment(\.appTheme, store.theme)
            .foregroundStyle(store.theme.ink)
            .preferredColorScheme(store.theme.scheme).tint(store.theme.accent)
            .task { await store.loadLibrary() }
            .onChange(of: scenePhase) { _, phase in if phase == .active { store.refreshDailyFive() } }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                store.refreshDailyFive()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                Task { await store.clearLessonCache() }
            }
        }
    }
}
