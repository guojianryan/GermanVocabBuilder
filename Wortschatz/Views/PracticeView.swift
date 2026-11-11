import SwiftUI

enum PracticeMode: String, CaseIterable { case flashcards = "Flashcards", quiz = "Lesson quiz" }
struct PracticeHome: View {
    @Environment(\.appTheme) private var theme
    @Environment(AppStore.self) private var store
    let explore: () -> Void
    @State private var mode = PracticeMode.flashcards
    @State private var started = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    Eyebrow(text: "A moment for your German").padding(.top, 20)
                    Text("From familiar\nto unforgettable.").font(.system(size: 40, weight: .medium, design: .serif)).tracking(-1)
                    Image(systemName: "rectangle.on.rectangle.angled").font(.system(size: 80, weight: .ultraLight)).foregroundStyle(theme.accent)
                        .frame(maxWidth: .infinity).padding(.vertical, 32)
                    if store.isLoadingLibrary {
                        ProgressView("Loading your deck…").frame(maxWidth: .infinity)
                    } else if store.deckWords.isEmpty {
                        EmptyState(icon: "sparkles", title: "First, collect a few words", detail: "Add words to My Deck, then come back for a little practice.")
                        PrimaryButton(title: "Explore words", action: explore)
                    } else {
                        Text("Your deck, your pace.").font(.system(.title2, design: .serif))
                        Text("\(store.deckWords.count) words ready. A few quiet minutes can make a difference.").foregroundStyle(theme.muted)
                        Picker("Practice mode", selection: $mode) { ForEach(PracticeMode.allCases, id: \.self) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented)
                        Text(mode == .flashcards ? "Recall the meaning, reveal the card, then decide what needs another look." : "Practice the original lesson questions, with explanations after every answer.")
                            .font(.subheadline).foregroundStyle(theme.muted).frame(minHeight: 60, alignment: .top)
                        PrimaryButton(title: "Let’s practice", icon: "play.fill") { started = true }
                    }
                }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
            }.background(theme.paper).navigationTitle("Practice").navigationBarTitleDisplayMode(.inline)
                .fullScreenCover(isPresented: $started) { PracticeSession(entries: store.deckWords, mode: mode) }
        }
    }
}
struct PracticeSession: View {
    @Environment(\.appTheme) private var theme
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let entries: [WordEntry]
    let mode: PracticeMode
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
                            HStack { Eyebrow(text: mode.rawValue); Spacer(); Text("\(position + 1) / \(items.count)").font(.caption.monospacedDigit()).foregroundStyle(theme.muted) }
                            ProgressView(value: Double(position), total: Double(max(1, items.count))).tint(theme.accent)
                        }
                        if mode == .flashcards { flashcard(item) } else { questionCard(item) }
                    } else { ProgressView().padding(80) }
                }.padding(24).frame(maxWidth: 620).frame(maxWidth: .infinity)
            }.background(theme.paper).navigationTitle("A little practice").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarLeading) { Button { if finished || error != nil { dismiss() } else { confirmExit = true } } label: { Image(systemName: "xmark") }.accessibilityLabel("End practice") } }
                .confirmationDialog("End this practice?", isPresented: $confirmExit, titleVisibility: .visible) {
                    Button("End practice", role: .destructive) { dismiss() }
                    Button("Keep practicing", role: .cancel) {}
                } message: { Text("Your saved deck will stay as it is.") }
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
            let prepared = try await store.practiceItems(entries, quiz: mode == .quiz)
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
                Text(item.entry.displayWord).font(.system(size: 43, weight: .medium, design: .serif)).multilineTextAlignment(.center).minimumScaleFactor(0.6)
                if let p = currentLesson?.word.pronunciation?.ipa { Text("/\(p)/").foregroundStyle(theme.muted).font(.subheadline) }
                if revealed {
                    Divider().padding(.horizontal, 30)
                    Text(item.entry.meaning).font(.title3).multilineTextAlignment(.center)
                    if let sample = currentLesson?.sampleSentences.first {
                        VStack(spacing: 8) {
                            Text(sample.german).foregroundStyle(theme.accent)
                            Text(sample.english).font(.subheadline).foregroundStyle(theme.muted)
                        }.multilineTextAlignment(.center)
                    }
                } else { Text("What does it mean?").font(.subheadline).foregroundStyle(theme.muted).padding(.top, 20) }
                Spacer(minLength: 24)
            }.padding(24).frame(minHeight: 360).frame(maxWidth: .infinity).background(theme.surface, in: RoundedRectangle(cornerRadius: 28))
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(theme.line))
            if revealed {
                Text("How did you do?").font(.subheadline).foregroundStyle(theme.muted)
                HStack(spacing: 12) {
                    Button { advance(item, success: false) } label: { Label("Another look", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity).padding(18).background(theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 18)) }.buttonStyle(.plain)
                    Button { advance(item, success: true) } label: { Label("Got it", systemImage: "checkmark").frame(maxWidth: .infinity).padding(18).foregroundStyle(theme.onAction).background(theme.action, in: RoundedRectangle(cornerRadius: 18)) }.buttonStyle(.plain)
                }.font(.subheadline.weight(.semibold))
            } else { PrimaryButton(title: "Reveal meaning", icon: "arrow.turn.down.right") { revealed = true }.disabled(currentLesson == nil) }
        }
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
            Text("A little more\nyours.").font(.system(size: 43, weight: .medium, design: .serif)).multilineTextAlignment(.center)
            Text("\(score) of \(items.count) \(mode == .flashcards ? "words recalled" : "answers correct").").font(.title3)
            Text(missed.isEmpty ? "You gave every word a moment. That’s how it sticks." : "Some words need another meeting. Give them one more look.").multilineTextAlignment(.center).foregroundStyle(theme.muted)
            if !missed.isEmpty { PrimaryButton(title: "Review \(missed.count) again", icon: "arrow.counterclockwise") { items = missed.shuffled(); missed = []; position = 0; score = 0; reset() } }
            Button("Finish practice") { dismiss() }.font(.headline).padding(16)
        }
    }
    private func audio(_ text: String) -> some View {
        Button { store.speak(text) } label: { Image(systemName: "speaker.wave.2").frame(width: 44, height: 44).background(theme.accent.opacity(0.07), in: Circle()) }.accessibilityLabel("Hear German pronunciation")
    }
    private func check(_ q: Question) { correct = q.accepts(input); revealed = true }
    private func reset() { revealed = false; input = ""; correct = false; currentLesson = nil }
    private func advance(_ item: PracticeItem, success: Bool) {
        if success { score += 1 } else { missed.append(item) }
        store.stopAudio(); reset(); position += 1
    }
}
