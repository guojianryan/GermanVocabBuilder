import SwiftUI

enum PracticeMode: String, CaseIterable, Identifiable {
    case flashcards = "Flashcards", quiz = "Lesson quiz"
    var id: String { rawValue }
}
struct PracticeHome: View {
    @Environment(\.appTheme) private var theme
    @Environment(AppStore.self) private var store
    let explore: () -> Void
    @State private var selectedMode: PracticeMode?
    @State private var dailyRun: DailyPracticeRun?
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    Eyebrow(text: "A moment for your German").padding(.top, 20)
                    Text("From familiar\nto unforgettable.").font(.system(size: 40, weight: .medium, design: .serif)).tracking(-1)
                    TodayFiveCard {
                        store.refreshDailyFive()
                        if let daily = store.dailyFive, !store.dailyRemainingWords.isEmpty {
                            dailyRun = DailyPracticeRun(id: daily.day, entries: store.dailyRemainingWords,
                                                        completed: daily.completedCount, total: daily.wordIDs.count,
                                                        recalled: daily.outcomes.values.filter { $0 }.count)
                        }
                    }
                    if store.isLoadingLibrary {
                        ProgressView("Loading your deck…").frame(maxWidth: .infinity)
                    } else if store.deckWords.isEmpty {
                        EmptyState(icon: "sparkles", title: "Build your own deck", detail: "Save words from today’s set or Explore for extra practice whenever you like.")
                        PrimaryButton(title: "Explore words", action: explore)
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("Practice your way").font(.system(.title2, design: .serif).weight(.medium))
                                Spacer()
                                Text("\(store.deckWords.count) saved \(store.deckWords.count == 1 ? "word" : "words")").font(.caption).foregroundStyle(theme.muted)
                            }
                            PracticeModeCard(mode: .flashcards) { selectedMode = .flashcards }
                            PracticeModeCard(mode: .quiz) { selectedMode = .quiz }
                        }

                    }
                }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
            }.background(theme.paper).navigationTitle("Practice").navigationBarTitleDisplayMode(.inline)
                .fullScreenCover(item: $selectedMode) { mode in PracticeSession(entries: store.deckWords, mode: mode) }
                .fullScreenCover(item: $dailyRun) { run in
                    PracticeSession(entries: run.entries, mode: .flashcards, dailyRun: run)
                }
                .onAppear { store.refreshDailyFive() }
        }
    }
}

private struct PracticeModeCard: View {
    @Environment(\.appTheme) private var theme
    let mode: PracticeMode
    let start: () -> Void
    private var isFlashcards: Bool { mode == .flashcards }
    var body: some View {
        Button(action: start) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: isFlashcards ? "rectangle.on.rectangle.angled" : "text.badge.checkmark")
                    .font(.system(size: 24, weight: .light)).foregroundStyle(theme.accent)
                    .frame(width: 50, height: 54)
                    .background(theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 15))
                VStack(alignment: .leading, spacing: 8) {
                    Text(mode.rawValue).font(.system(.title3, design: .serif).weight(.semibold))
                        .foregroundStyle(theme.ink)
                    Text(isFlashcards ? "Recall the meaning, then reveal it. Go at your own pace." : "Choose or write an answer, then see why it works.")
                        .font(.subheadline).foregroundStyle(theme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 6) {
                        Text(isFlashcards ? "Start recalling" : "Take a quiz")
                        Image(systemName: "arrow.right").font(.caption.weight(.semibold))
                    }.font(.subheadline.weight(.semibold)).foregroundStyle(theme.accent).padding(.top, 4)
                }
                Spacer(minLength: 0)
            }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.surface, in: RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(theme.line))
                .contentShape(RoundedRectangle(cornerRadius: 22))
        }.buttonStyle(PracticeCardButtonStyle())
            .accessibilityLabel(isFlashcards ? "Start flashcards" : "Start lesson quiz")
            .accessibilityHint(isFlashcards ? "Recall meanings from your saved words." : "Answer questions from your saved lessons.")
            .accessibilityIdentifier(isFlashcards ? "startFlashcards" : "startLessonQuiz")
    }
}

private struct PracticeCardButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct DailyPracticeRun: Identifiable {
    let id: String
    let entries: [WordEntry]
    let completed: Int
    let total: Int
    let recalled: Int
}

private struct TodayFiveCard: View {
    @Environment(\.appTheme) private var theme
    @Environment(AppStore.self) private var store
    let start: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("TODAY’S FIVE", systemImage: "sun.max")
                    .font(.system(.caption, design: .monospaced).weight(.semibold)).tracking(1.5)
                Spacer()
                if let daily = store.dailyFive { Text(daily.level).font(.caption.weight(.semibold)) }
            }.foregroundStyle(theme.accent)
            if store.isLoadingLibrary {
                ProgressView("Choosing your words…")
            } else if let daily = store.dailyFive, !daily.wordIDs.isEmpty {
                Text(daily.isComplete ? "A little German, done." : "Five words. One small step.")
                    .font(.system(.title2, design: .serif).weight(.medium))
                Text(daily.isComplete ? "You’ve met all \(daily.wordIDs.count) words. A fresh set arrives tomorrow." : "A mix of new words and familiar ones when you have them. Your place is saved as you go.")
                    .font(.subheadline).foregroundStyle(theme.muted)
                HStack(spacing: 8) {
                    ForEach(daily.wordIDs, id: \.self) { id in
                        Image(systemName: daily.outcomes[id] == nil ? "circle" : "checkmark.circle.fill")
                            .font(.title2).foregroundStyle(theme.accent)
                            .accessibilityHidden(true)
                    }
                    Spacer()
                    Text("\(daily.completedCount) of \(daily.wordIDs.count) complete")
                        .font(.caption.monospacedDigit()).foregroundStyle(theme.muted)
                        .accessibilityIdentifier("dailyProgress")
                }
                if daily.level != store.studyLevel.rawValue {
                    Text("Today’s set stays at \(daily.level). Tomorrow’s will use \(store.studyLevel.rawValue).")
                        .font(.caption).foregroundStyle(theme.muted)
                }
                if !daily.isComplete {
                    PrimaryButton(title: daily.completedCount == 0 ? "Start today’s five" : "Continue today’s five", icon: "play.fill", action: start)
                        .accessibilityIdentifier("startDailyFive")
                } else {
                    Label("Today’s five complete", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.semibold)).foregroundStyle(theme.accent)
                }
            } else {
                Text(store.loadError ?? "No words at this level yet. Choose another level in Settings to get started.")
                    .font(.subheadline).foregroundStyle(theme.muted)
            }
        }.padding(22).frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: 25))
            .overlay(RoundedRectangle(cornerRadius: 25).stroke(theme.line))
    }
}

struct PracticeSession: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.appTheme) private var theme
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let entries: [WordEntry]
    let mode: PracticeMode
    var dailyRun: DailyPracticeRun? = nil
    @State private var currentLesson: Lesson?
    @State private var preparing = false
    @State private var items: [PracticeItem] = []
    @State private var position = 0
    @State private var revealed = false
    @State private var input = ""
    @State private var correct = false
    @State private var missed: [PracticeItem] = []
    @State private var score = 0
    @State private var error: String?
    @State private var confirmExit = false
    @State private var loaded = false
    private var finished: Bool { loaded && position >= items.count && error == nil }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 26) {
                    if let error {
                        EmptyState(icon: "exclamationmark.triangle", title: "Practice couldn’t load", detail: error)
                        PrimaryButton(title: "Back to deck") { dismiss() }
                    } else if finished {
                        summary
                    } else if items.indices.contains(position) {
                        let item = items[position]
                        VStack(spacing: 10) {
                            HStack { Eyebrow(text: dailyRun == nil ? mode.rawValue : "Today’s five"); Spacer(); Text("\((dailyRun?.completed ?? 0) + position + 1) / \(dailyRun?.total ?? items.count)").font(.caption.monospacedDigit()).foregroundStyle(theme.muted) }
                            ProgressView(value: Double((dailyRun?.completed ?? 0) + position), total: Double(max(1, dailyRun?.total ?? items.count))).tint(theme.accent)
                                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: position)
                        }
                        ZStack {
                            Group {
                                if mode == .flashcards { flashcard(item) } else { questionCard(item) }
                            }
                            .id(item.id)
                            .transition(reduceMotion ? .identity : .asymmetric(
                                insertion: .opacity.combined(with: .offset(x: 24)),
                                removal: .opacity.combined(with: .offset(x: -24))))
                        }
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: position)
                    } else { ProgressView().padding(80) }
                }.padding(24).frame(maxWidth: 620).frame(maxWidth: .infinity)
            }.background(theme.paper).navigationTitle(dailyRun == nil ? "A little practice" : "Today’s five").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarLeading) { Button { if finished || error != nil { dismiss() } else { confirmExit = true } } label: { Image(systemName: "xmark") }.accessibilityLabel("End practice") } }
                .confirmationDialog("End this practice?", isPresented: $confirmExit, titleVisibility: .visible) {
                    Button("End practice", role: .destructive) { dismiss() }
                    Button("Keep practicing", role: .cancel) {}
                } message: { Text(dailyRun == nil ? "Your saved deck will stay as it is." : "Your progress is saved. Come back to finish today’s words.") }
        }.task { await prepare() }
            .task(id: items.indices.contains(position) ? items[position].id : nil) {
                currentLesson = nil
                guard mode == .flashcards, items.indices.contains(position) else { return }
                do {
                    let value = try await store.lesson(items[position].entry)
                    try Task.checkCancellation()
                    currentLesson = value
                } catch is CancellationError { return }
                catch { self.error = error.localizedDescription }
            }
            .onDisappear { store.stopAudio() }
    }
    private func prepare() async {
        guard !loaded && !preparing else { return }
        preparing = true
        defer { preparing = false }
        do {
            let prepared: [PracticeItem]
            if dailyRun != nil {
                prepared = entries.map { PracticeItem(entry: $0, question: nil) }
            } else {
                prepared = try await store.practiceItems(entries, quiz: mode == .quiz)
            }
            try Task.checkCancellation()
            items = prepared
            if items.isEmpty { error = "Add a word to your deck to begin." }
        } catch is CancellationError {
            return
        } catch { self.error = error.localizedDescription }
        loaded = true
    }
    private func flashcard(_ item: PracticeItem) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 22) {
                HStack { Text(item.entry.level + " · " + item.entry.kind).font(.caption).foregroundStyle(theme.muted); Spacer(); audio(item.entry.displayWord) }
                Spacer(minLength: 24)
                Text(item.entry.displayWord).font(.system(size: 43, weight: .medium, design: .serif))
                    .foregroundStyle(theme.wordColor(item.entry))
                    .multilineTextAlignment(.center).minimumScaleFactor(0.6)
                    .accessibilityHint(item.entry.nounGender.map { "\($0.rawValue) noun" } ?? "")
                if let p = currentLesson?.word.pronunciation?.ipa { Text("/\(p)/").foregroundStyle(theme.muted).font(.subheadline) }
                if revealed {
                    Divider().padding(.horizontal, 30)
                    Text(item.entry.meaning).font(.title3).multilineTextAlignment(.center)
                        .transition(.opacity)
                    if let sample = currentLesson?.sampleSentences.first {
                        VStack(spacing: 8) {
                            Text(sample.german).foregroundStyle(theme.accent)
                            Text(sample.english).font(.subheadline).foregroundStyle(theme.muted)
                        }.multilineTextAlignment(.center)
                    }
                } else { Text("What does it mean?").font(.subheadline).foregroundStyle(theme.muted).padding(.top, 20) }
                if dailyRun != nil {
                    Button { store.toggle(item.entry) } label: {
                        Label(store.contains(item.entry) ? "Saved to My Deck" : "Save to My Deck",
                              systemImage: store.contains(item.entry) ? "checkmark.circle.fill" : "plus.circle")
                            .font(.subheadline)
                    }.buttonStyle(.bordered)
                }
                Spacer(minLength: 24)
            }.padding(24).frame(minHeight: 360).frame(maxWidth: .infinity).background(theme.surface, in: RoundedRectangle(cornerRadius: 28))
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(theme.line))
            if revealed {
                Text("How did you do?").font(.subheadline).foregroundStyle(theme.muted)
                HStack(spacing: 12) {
                    Button { advance(item, success: false) } label: { Label("Another look", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity).padding(18).background(theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 18)) }.buttonStyle(.plain)
                    Button { advance(item, success: true) } label: { Label("Got it", systemImage: "checkmark").frame(maxWidth: .infinity).padding(18).foregroundStyle(theme.onAction).background(theme.action, in: RoundedRectangle(cornerRadius: 18)) }.buttonStyle(.plain)
                }.font(.subheadline.weight(.semibold))
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 8)))
            } else { PrimaryButton(title: "Reveal meaning", icon: "arrow.turn.down.right") { revealed = true }.disabled(currentLesson == nil) }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: revealed)
    }
    @ViewBuilder private func questionCard(_ item: PracticeItem) -> some View {
        if let q = item.question {
            VStack(alignment: .leading, spacing: 24) {
                HStack { Text(item.entry.headword).font(.system(.title3, design: .serif)); Spacer(); audio(item.entry.headword) }
                Text(q.prompt).font(.system(.title2, design: .serif)).fixedSize(horizontal: false, vertical: true)
                if q.type == "choice" {
                    ForEach(q.options ?? [], id: \.self) { option in
                        Button { input = option; check(q) } label: {
                            HStack { Text(option); Spacer(); if revealed && input == option { Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill") } }
                                .padding(18).frame(maxWidth: .infinity, alignment: .leading)
                                .background(input == option ? theme.accent.opacity(0.12) : theme.ink.opacity(0.04), in: RoundedRectangle(cornerRadius: 15))
                        }.buttonStyle(.plain).disabled(revealed)
                    }
                } else if q.type == "fill-in-the-blank" {
                    TextField("Your answer", text: $input).textInputAutocapitalization(.never).autocorrectionDisabled().padding(18)
                        .background(theme.ink.opacity(0.04), in: RoundedRectangle(cornerRadius: 15)).disabled(revealed).onSubmit { if !input.trimmingCharacters(in: .whitespaces).isEmpty { check(q) } }
                    if !revealed { PrimaryButton(title: "Check answer", icon: "checkmark") { check(q) }.disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) }
                } else if !revealed {
                    Text("Say your answer, then compare it with the examples.").font(.subheadline).foregroundStyle(theme.muted)
                    PrimaryButton(title: "Show model answers", icon: "eye") { revealed = true }
                }
                if revealed {
                    VStack(alignment: .leading, spacing: 12) {
                        if q.type != "open" { Label(correct ? "Richtig!" : "Keep learning", systemImage: correct ? "checkmark.circle" : "arrow.counterclockwise").font(.headline).foregroundStyle(theme.accent) }
                        if let answer = q.fullAnswer ?? q.answer { Text(answer).font(.headline) }
                        if q.type == "open" { ForEach(q.acceptedAnswers ?? [], id: \.self) { Text($0) } }
                        if let explanation = q.explanation { Text(explanation).font(.subheadline).foregroundStyle(theme.muted) }
                    }.padding(18).frame(maxWidth: .infinity, alignment: .leading).background(theme.accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 18)).accessibilityElement(children: .combine)
                    if q.type == "open" {
                        Text("How close was your answer?").font(.subheadline).foregroundStyle(theme.muted)
                        HStack {
                            Button("Needs practice") { advance(item, success: false) }.buttonStyle(.bordered)
                            Button("Got it") { advance(item, success: true) }.buttonStyle(.borderedProminent)
                        }
                    } else { PrimaryButton(title: "Continue") { advance(item, success: correct) } }
                }
            }.padding(24).background(theme.surface, in: RoundedRectangle(cornerRadius: 26)).id(item.id)
        }
    }
    private var summary: some View {
        VStack(spacing: 24) {
            Image(systemName: "sun.max").font(.system(size: 72, weight: .ultraLight)).foregroundStyle(theme.accent).padding(.top, 40)
            Eyebrow(text: "Gut gemacht")
            Text(dailyRun == nil ? "A little more\nyours." : "Today’s words,\ndone.").font(.system(size: 43, weight: .medium, design: .serif)).multilineTextAlignment(.center)
            Text("\(score + (dailyRun?.recalled ?? 0)) of \(dailyRun?.total ?? items.count) \(mode == .flashcards ? "words recalled" : "answers correct").").font(.title3)
            if dailyRun != nil {
                Text("You gave every word a moment. Come back tomorrow for a fresh set.")
                    .multilineTextAlignment(.center).foregroundStyle(theme.muted)
            } else {
                Text(missed.isEmpty ? "You gave every word a moment. That’s how it sticks." : "Some words need another meeting. Give them one more look.").multilineTextAlignment(.center).foregroundStyle(theme.muted)
                if !missed.isEmpty { PrimaryButton(title: "Review \(missed.count) again", icon: "arrow.counterclockwise") { items = missed.shuffled(); missed = []; position = 0; score = 0; reset() } }
            }
            Button("Finish practice") { dismiss() }.font(.headline).padding(16)
        }
    }
    private func audio(_ text: String) -> some View {
        Button { store.speak(text) } label: { Image(systemName: "speaker.wave.2").frame(width: 44, height: 44).background(theme.accent.opacity(0.07), in: Circle()) }.accessibilityLabel("Hear German pronunciation")
    }
    private func check(_ q: Question) { correct = q.accepts(input); revealed = true }
    private func reset() { revealed = false; input = ""; correct = false; currentLesson = nil }
    private func advance(_ item: PracticeItem, success: Bool) {
        store.recordRecall(item.entry, success: success, dailyDay: dailyRun?.id)
        if success { score += 1 } else { missed.append(item) }
        store.stopAudio(); reset(); position += 1
    }
}
