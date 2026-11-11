import SwiftUI
import AVFoundation

@MainActor @Observable final class AppStore {
    var theme: AppTheme { didSet { defaults.set(theme.rawValue, forKey: "appearance.theme.v1") } }
    var studyLevel: StudyLevel { didSet { defaults.set(studyLevel.rawValue, forKey: "studyLevel.v1") } }
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
    private(set) var deckWords: [WordEntry] = []
    private(set) var deckIDs: Set<String>
    @ObservationIgnored private var catalog: LibraryCatalog?
    @ObservationIgnored private var loading = false
    @ObservationIgnored private let repository: LessonRepository
    private let defaults: UserDefaults
    private let speaker = AVSpeechSynthesizer()
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
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
            let engine = WordSearchEngine(index: loaded.index)
            searchEngine = engine
            Task { try? await engine.prepare() }
        } catch is CancellationError {
            return
        } catch { loadError = "The lesson library couldn’t be opened. \(error.localizedDescription)" }
    }
    private func refreshDeckWords() { deckWords = catalog?.words(for: deck) ?? [] }
    func contains(_ e: WordEntry) -> Bool { deckIDs.contains(e.id) }
    func toggle(_ e: WordEntry) {
        if contains(e) { deck.removeAll { $0 == e.id } } else { deck.append(e.id) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    func lesson(_ e: WordEntry) async throws -> Lesson { try await repository.lesson(e) }
    func readerSource(_ e: WordEntry) async throws -> LessonRepository.ReaderSource { try await repository.readerSource(e) }
    func practiceItems(_ entries: [WordEntry], quiz: Bool) async throws -> [PracticeItem] {
        try await repository.practiceItems(entries, quiz: quiz)
    }
    func clearLessonCache() async { await repository.clearCache() }
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
    @State private var store: AppStore
    init() {
        var defaults = UserDefaults.standard
        #if DEBUG
        if let suite = ProcessInfo.processInfo.environment["WORTSCHATZ_TEST_DEFAULTS"],
           suite.hasPrefix("Wortschatz.UITests."), let isolated = UserDefaults(suiteName: suite) {
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
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                Task { await store.clearLessonCache() }
            }
        }
    }
}
