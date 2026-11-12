import SwiftUI
import UIKit

struct RootView: View {
    @Environment(AppStore.self) private var store
    @State private var tab = 0
    var body: some View {
        TabView(selection: $tab) {
            Tab("Explore", systemImage: "square.grid.2x2", value: 0) { LibraryView() }
            Tab("My Deck", systemImage: "rectangle.on.rectangle", value: 1) { DeckView { tab = 0 } }
            Tab("Practice", systemImage: "sparkles", value: 2) { PracticeHome { tab = 0 } }
            Tab("Settings", systemImage: "gearshape", value: 3) { SettingsView() }
        }
        .onChange(of: store.showPractice, initial: true) { _, show in
            if show { tab = 2; store.showPractice = false }
        }
    }
}
struct LibraryView: View {
    @Environment(\.appTheme) private var theme
    @Environment(AppStore.self) private var store
    @State private var search = ""
    @ScaledMetric(relativeTo: .body) private var searchFieldHeight = 22
    @State private var category = "All words"
    @State private var featuredWord: WordEntry?
    @State private var visibleCount = 10
    private var hasSearch: Bool { !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var hasResultsRequest: Bool { hasSearch || category != "All words" }
    private let categories = ["All words", "Nouns", "Verbs", "Adjectives"]
    private struct SearchRequest: Hashable {
        let query: String
        let category: String
        let libraryReady: Bool
    }
    @State private var results: [WordEntry] = []
    @State private var completedRequest: SearchRequest?
    private var searchRequest: SearchRequest { SearchRequest(query: search, category: category, libraryReady: store.index != nil) }
    private var isSearching: Bool { hasResultsRequest && completedRequest != searchRequest }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    HStack {
                        Label("WORTSCHATZ", systemImage: "leaf").font(.system(.caption, design: .monospaced).weight(.semibold)).tracking(2)
                        Spacer()
                        Text("DE / EN").font(.system(.caption2, design: .monospaced)).foregroundStyle(theme.muted)
                    }.foregroundStyle(theme.accent).padding(.top, 12)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("A little German.\nA little every day.").font(.system(size: 39, weight: .medium, design: .serif)).tracking(-1).fixedSize(horizontal: false, vertical: true)
                        Text("Find a word. Make it yours.").font(.subheadline).foregroundStyle(theme.muted)
                    }
                    if !hasResultsRequest { discoveryCard }
                    VStack(spacing: 16) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass").foregroundStyle(theme.accent)
                            GermanTextField(text: $search, placeholder: "Search German or English", identifier: "wordSearch", returnKey: .search)
                                .frame(height: searchFieldHeight)
                                .accessibilityIdentifier("wordSearch").disabled(store.index == nil)
                            if !search.isEmpty { Button { search = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(theme.muted) }.accessibilityLabel("Clear search") }
                        }.padding(16).background(theme.surface, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(theme.line))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categories, id: \.self) { c in
                                    Button { category = c } label: {
                                        Text(c).font(.subheadline.weight(.medium)).padding(.horizontal, 16).padding(.vertical, 10)
                                            .foregroundStyle(category == c ? theme.onAction : .primary)
                                            .background(category == c ? theme.action : theme.ink.opacity(0.04), in: Capsule())
                                    }.buttonStyle(.plain).accessibilityAddTraits(category == c ? .isSelected : [])
                                }
                            }
                        }
                    }
                    if results.contains(where: { $0.nounGender != nil }) { NounGenderKey() }
                    if hasResultsRequest || store.loadError != nil {
                    VStack(spacing: 6) {
                        HStack {
                            Eyebrow(text: hasSearch ? "Search results" : "Filtered words")
                            Spacer()
                        }.padding(.bottom, 6)
                        HStack { Text(isSearching ? "Finding words…" : "Showing \(min(visibleCount, results.count)) of \(results.count) words").font(.caption).foregroundStyle(theme.muted); Spacer() }
                        if let error = store.loadError { EmptyState(icon: "exclamationmark.triangle", title: "Library unavailable", detail: error) }
                        else if isSearching { ProgressView().frame(maxWidth: .infinity).padding() }
                        else if results.isEmpty { EmptyState(icon: "magnifyingglass", title: "No words found", detail: "Try another form, an English meaning, or a different filter.") }
                        else {
                            LazyVStack(spacing: 0) {
                                ForEach(results.prefix(visibleCount)) { e in
                                    WordRow(entry: e)
                                    Divider().overlay(theme.line)
                                }
                                if visibleCount < results.count {
                                    ProgressView()
                                        .frame(maxWidth: .infinity).padding()
                                        .id(visibleCount)
                                        .onAppear {
                                            guard completedRequest == searchRequest else { return }
                                            visibleCount = min(visibleCount + 10, results.count)
                                        }
                                }
                            }.id(searchRequest)
                        }
                    }
                    }
                    Text("Small steps. Lasting words.").font(.system(.subheadline, design: .serif).italic()).foregroundStyle(theme.muted).frame(maxWidth: .infinity).padding(.vertical, 15)
                }.padding(.horizontal, 24).padding(.bottom, 20).frame(maxWidth: 720)
                    .frame(maxWidth: .infinity)
            }.background(theme.paper).toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: WordEntry.self) { LessonView(entry: $0) }
                .scrollDismissesKeyboard(.interactively)
                .onAppear { pickFeaturedWord() }
                .onChange(of: store.index != nil) { _, ready in if ready { pickFeaturedWord() } }
                .onChange(of: store.studyLevel) { _, _ in pickFeaturedWord() }
                .onChange(of: store.deck) { _, _ in
                    if featuredWord == nil || featuredWord.map(store.contains) == true { pickFeaturedWord() }
                }
                .task(id: searchRequest) {
                    let request = searchRequest
                    visibleCount = 10
                    guard hasResultsRequest else {
                        results = []
                        completedRequest = request
                        return
                    }
                    do {
                        try await Task.sleep(for: .milliseconds(150))
                        guard let engine = store.searchEngine else { return }
                        let matches = try await engine.results(request.query, level: "All", category: request.category)
                        try Task.checkCancellation()
                        guard request == searchRequest else { return }
                        results = matches
                        completedRequest = request
                    } catch is CancellationError {
                        // A newer request owns the results now.
                    } catch {
                        results = []
                        completedRequest = request
                    }
                }
                .onChange(of: search) { _, _ in visibleCount = 10 }
                .onChange(of: category) { _, _ in visibleCount = 10 }
        }
    }
    private func pickFeaturedWord() {
        let candidates = (store.index?.entries ?? []).filter { $0.level == store.studyLevel.rawValue && !store.contains($0) }
        let alternatives = candidates.filter { $0.id != featuredWord?.id }
        featuredWord = (alternatives.isEmpty ? candidates : alternatives).randomElement()
    }
    @ViewBuilder private var discoveryCard: some View {
        if store.isLoadingLibrary { ProgressView("Loading words…").frame(maxWidth: .infinity).padding() }
        else if let e = featuredWord, e.level == store.studyLevel.rawValue, !store.contains(e) {
            NavigationLink(value: e) {
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(e.level) · FEATURED WORD").font(.system(size: 10, weight: .medium, design: .monospaced)).tracking(1.8).foregroundStyle(theme.onAction.opacity(0.7))
                        FeaturedWordBanner(entry: e).id(e.id)
                        Text(e.meaning).font(.subheadline).foregroundStyle(theme.onAction.opacity(0.8)).lineLimit(2)
                        Label("Discover the word", systemImage: "arrow.up.right").font(.caption.weight(.semibold)).padding(.top, 8)
                    }
                    Spacer(minLength: 0)
                }.foregroundStyle(theme.onAction).padding(24).frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.action, in: RoundedRectangle(cornerRadius: 25))
            }.buttonStyle(.plain).accessibilityIdentifier("featuredWord").accessibilityValue(e.level)
        } else if store.index != nil {
            if store.index?.entries.contains(where: { $0.level == store.studyLevel.rawValue }) == true {
                EmptyState(icon: "checkmark.seal", title: "Every \(store.studyLevel.rawValue) word is in your deck", detail: "Head to Practice to keep learning, or choose another level in Settings.")
            } else {
                EmptyState(icon: "books.vertical", title: "No \(store.studyLevel.rawValue) words yet", detail: "Choose another level in Settings while lessons for this level are being added.")
            }
        }
    }
}
private struct FeaturedWordBanner: View {
    @Environment(AppStore.self) private var store
    @Environment(\.appTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let entry: WordEntry
    @State private var lesson: Lesson?
    @State private var assembled = false
    @State private var releaseAmount: Double = 0
    @State private var cueActive = false
    @State private var releaseLift: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                if let gender = entry.nounGender {
                    Text(gender.article).font(.system(.subheadline, design: .serif).weight(.semibold))
                        .foregroundStyle(theme.nounColor(gender))
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .background(theme.surface, in: RoundedRectangle(cornerRadius: 8))
                        .padding(.trailing, 8)
                } else if let article = entry.article { Text(article + " ") }
                if let lesson {
                    ForEach(Array(lesson.bannerSegments.enumerated()), id: \.offset) { i, segment in
                        Text(segment.text)
                            .fontWeight(segment.emphasis == "release" && releaseAmount < 1 ? .semibold : .medium)
                            .offset(y: segment.emphasis == "release" ? releaseLift : (segment.emphasis == "rise" && !assembled ? 10.5 : 0))
                            .rotation3DEffect(.degrees(segment.emphasis == "turn" && assembled && !reduceMotion ? 360 : 0), axis: (x: 0, y: 1, z: 0), perspective: 1 / 6)
                            .tracking(segment.emphasis == "stretch" && assembled ? 4 : 0)
                            .offset(x: segment.emphasis == "arrive" && !assembled ? 30 : 0)
                            .foregroundStyle(segmentColor(segment, at: i))
                            .animation(segmentAnimation(segment), value: assembled)
                    }
                } else { Text(entry.headword) }
            }
            .font(.system(size: 30, weight: .medium, design: .serif))
            .lineLimit(1).minimumScaleFactor(0.45)
            .accessibilityElement(children: .ignore).accessibilityLabel(entry.displayWord)

        }
        .task(id: "\(entry.id)-\(reduceMotion)") {
            do {
                let value = try await store.lesson(entry)
                try Task.checkCancellation()
                lesson = value
            } catch { return }
            assembled = reduceMotion
            releaseAmount = reduceMotion ? 1 : 0
            cueActive = false
            releaseLift = 0
            guard !reduceMotion else { return }
            do {
                try await Task.sleep(for: .milliseconds(300))
                assembled = true
                guard lesson?.bannerSegments.contains(where: { $0.emphasis == "release" }) == true else { return }
                try await Task.sleep(for: .milliseconds(200))
                withAnimation(.easeInOut(duration: 0.4)) { cueActive = true }
                try await Task.sleep(for: .milliseconds(400))
                withAnimation(.easeInOut(duration: 0.4)) { cueActive = false }
                try await Task.sleep(for: .milliseconds(300))
                withAnimation(.timingCurve(0.3, 0.7, 0.3, 1, duration: 1.5)) { releaseAmount = 1 }
                withAnimation(.easeOut(duration: 0.75)) { releaseLift = -1.8 }
                try await Task.sleep(for: .milliseconds(750))
                withAnimation(.easeInOut(duration: 0.75)) { releaseLift = 0 }
            } catch { return }
        }
        .onChange(of: reduceMotion) { _, reduced in if reduced { assembled = true; releaseAmount = 1; releaseLift = 0; cueActive = false } }
    }
    private func segmentAnimation(_ segment: Lesson.BannerSegment) -> Animation? {
        guard !reduceMotion else { return nil }
        if segment.emphasis == "stretch" || segment.emphasis == "turn" {
            return .timingCurve(0.45, 0, 0.2, 1, duration: segment.emphasis == "turn" ? 1.6 : 2.6)
        }
        return .timingCurve(0.15, 0.7, 0.2, 1, duration: 1.8)
    }
    private func segmentColor(_ segment: Lesson.BannerSegment, at index: Int) -> Color {
        if reduceMotion { return theme.onAction }
        if segment.emphasis == "release" {
            return theme.correction.mix(with: theme.onAction, by: releaseAmount)
        }
        let segments = lesson?.bannerSegments ?? []
        if index + 1 < segments.count && segments[index + 1].emphasis == "release" {
            return cueActive ? theme.secondaryAccent : theme.onAction
        }
        return theme.onAction
    }
}
struct DeckView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.appTheme) private var theme
    @Environment(AppStore.self) private var store
    let explore: () -> Void
    @State private var practice = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Eyebrow(text: "Your personal collection").padding(.top, 20)
                    Text("Words worth\nkeeping.").font(.system(size: 40, weight: .medium, design: .serif)).tracking(-1)
                    HStack { Label("\(store.deckWords.count) words", systemImage: "rectangle.on.rectangle"); Spacer(); Text("Saved on this device") }.font(.caption).foregroundStyle(theme.muted)
                    if store.isLoadingLibrary {
                        ProgressView("Loading your deck…").frame(maxWidth: .infinity)
                    } else if store.deckWords.isEmpty {
                        EmptyState(icon: "rectangle.stack.badge.plus", title: "Your deck starts here", detail: "Tap + beside any word in Explore. Your collection will be ready whenever you are.")
                        PrimaryButton(title: "Find your first words", action: explore)
                    } else {
                        PrimaryButton(title: "Practice my deck", icon: "play.fill") { practice = true }
                        if store.deckWords.contains(where: { $0.nounGender != nil }) { NounGenderKey() }
                        LazyVStack(spacing: 0) {
                            ForEach(store.deckWords) { e in
                                VStack(spacing: 0) {
                                    WordRow(entry: e, removalPending: store.pendingRemoval.contains(e.id),
                                            onRemove: { store.toggleRemoval(e) })
                                    Divider()
                                }
                                    .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.97)))
                            }
                        }
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: store.deckWords.map(\.id))
                        Text("Tap a checkmark to remove a word. Tap Undo within 5 seconds to keep it.").font(.caption).foregroundStyle(theme.muted)
                    }
                }.padding(24).frame(maxWidth: 720).frame(maxWidth: .infinity)
            }.background(theme.paper).navigationTitle("My Deck").navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: WordEntry.self) { LessonView(entry: $0) }
                .fullScreenCover(isPresented: $practice) { PracticeSession(entries: store.deckWords.filter { !store.pendingRemoval.contains($0.id) }, mode: .flashcards) }
        }
    }
}
