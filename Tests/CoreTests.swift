import Foundation

@main struct CoreTests {
    static func main() async throws {
        let root = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? FileManager.default.currentDirectoryPath)
        let index = try JSONDecoder().decode(LessonIndex.self, from: Data(contentsOf: root.appendingPathComponent("lessons/index.json")))
        var checks = 0
        func check(_ test: @autoclosure () -> Bool, _ message: String) {
            precondition(test(), message)
            checks += 1
        }
        for (query, expected) in [("rufe", "anrufen"), ("aelter", "alt"), ("weiß", "kennen"), ("die tische", "tisch"), ("Äpfel", "apfel"), ("apple", "apfel")] {
            check(WordSearch.results(query, in: index).contains { $0.id == expected }, "Search \(query) should find \(expected)")
        }
        check(WordSearch.results("an", in: index).first?.id == "an", "Exact headword first")
        check(WordSearch.results("zzzzzz", in: index).isEmpty, "No false results")
        check(WordSearch.fold("  (sich)   ÄUSSERN  ") == "aussern", "Fold reflexive prefix, spaces, umlauts")
        check(WordSearch.results("", in: index).count == index.entries.count, "Empty query shows all")
        let prepared = WordSearch.PreparedIndex(index)
        let umlautMatches = try prepared.results("aelter")
        check(umlautMatches.contains { $0.id == "alt" }, "Prepared search supports German folding")
        let exactMatches = try prepared.results("an")
        check(exactMatches.first?.id == "an", "Prepared search preserves ranking")
        let a2Verbs = try prepared.results("a", level: "A2", category: "Verbs")
        check(!a2Verbs.isEmpty && a2Verbs.allSatisfy { $0.level == "A2" && $0.kind == "Verb" }, "Background search applies both filters")
        let b1Matches = try prepared.results("abheben", level: "B1")
        check(b1Matches.contains { $0.id == "abheben" }, "B1 lessons are searchable")
        check(WordSearch.results("Mittwoch", in: index).contains { $0.id == "wochentage" }, "Group member search finds its lesson")
        let noMatches = try prepared.results("zzzzzz")
        check(noMatches.isEmpty, "Prepared search rejects nonmatches")
        for entry in index.entries {
            check(!entry.file.hasPrefix("samples/"), "Samples excluded")
            let lesson = try JSONDecoder().decode(Lesson.self, from: Data(contentsOf: root.appendingPathComponent("lessons/" + entry.file)))
            check(lesson.word.headword == entry.headword, "Index and lesson agree")
            check(lesson.bannerSegments.map(\.text).joined() == entry.headword, "Animated segments preserve the headword")
            let rootParts = lesson.etymology?.parts ?? []
            for (i, segment) in lesson.bannerSegments.enumerated() {
                if let emphasis = segment.emphasis {
                    if rootParts.contains(where: { $0.emphasis != nil }) {
                        check(i < rootParts.count && rootParts[i].emphasis == emphasis, "Explicit animation settings take priority")
                    } else {
                        check(i == 1 && emphasis == (lesson.bannerSegments.count == 2 ? "arrive" : "stretch"), "Unmarked breakdowns use the default animation")
                    }
                }
            }
            if entry.id == "abholen" {
                check(lesson.bannerSegments.map(\.text) == ["ab", "holen"], "Abholen splits into prefix and root")
                check(lesson.bannerSegments.last?.emphasis == "arrive", "Unmarked two-part words animate")
            }
            if entry.id == "abfahren" {
                check(lesson.bannerSegments.map(\.text) == ["ab", "fahren"], "Abfahren splits correctly")
                check(lesson.bannerSegments.last?.emphasis == "release", "Abfahren uses its updated explicit release")
                let url = root.appendingPathComponent("lessons/" + entry.file)
                var json = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as! [String: Any]
                var etymology = json["etymology"] as! [String: Any]
                var parts = etymology["parts"] as! [[String: Any]]
                for setting in ["none", "future-animation"] {
                    parts[1].removeValue(forKey: "emphasis")
                    parts[0]["emphasis"] = setting
                    etymology["parts"] = parts
                    json["etymology"] = etymology
                    let explicit = try JSONDecoder().decode(Lesson.self, from: JSONSerialization.data(withJSONObject: json))
                    check(explicit.bannerSegments.allSatisfy { $0.emphasis == nil }, "None and unknown settings suppress the default")
                }
            }
            if entry.id == "entschuldigung" {
                check(lesson.bannerSegments.map(\.text) == ["Ent", "schuld", "ig", "ung"], "Release preserves each root")
                check(lesson.bannerSegments[1].emphasis == "release", "Guilt receives release animation")
            }
            if entry.id == "abheben" {
                check(lesson.bannerSegments.last?.emphasis == "rise", "B1 abheben rises")
            }
            if entry.id == "umsteigen" {
                check(lesson.bannerSegments.first?.emphasis == "turn", "Umsteigen turns")
            }
            if entry.id == "ankunft" {
                check(lesson.bannerSegments.map(\.text) == ["An", "kunft"], "Arrival splits at its root")
                check(lesson.bannerSegments.last?.emphasis == "arrive", "Arrival retains its slide animation")
            }
            for q in lesson.quiz {
                if let answer = q.answer {
                    check(q.accepts("  " + answer.uppercased() + "!  "), "Accept case, whitespace and punctuation")
                    check(!q.accepts("wrong-answer-12345"), "Reject incorrect answer")
                }
                if let answer = q.fullAnswer { check(q.accepts(answer), "Accept full answer") }
                for answer in q.acceptedAnswers ?? [] { check(q.accepts(answer), "Accept alternatives") }
            }
        }
        // Repository operations run on their actor; verify ordering, bounded caching and cancellation.
        let repository = LessonRepository(resourceRoot: root, cacheLimit: 2)
        let catalog = try await repository.loadCatalog()
        let first = index.entries[0], second = index.entries[1], third = index.entries[2]
        check(catalog.words(for: [third.id, "missing-id", first.id]).map(\.id) == [third.id, first.id], "Catalog preserves saved order and skips missing IDs")
        let cards = try await repository.practiceItems([first, second, third], quiz: false)
        check(Set(cards.map { $0.entry.id }) == Set([first.id, second.id, third.id]), "Flashcards preserve all words")
        let coldCount = await repository.cachedLessonCount
        check(coldCount == 0, "Flashcard preparation performs no lesson loading")
        _ = try await repository.lesson(first)
        _ = try await repository.lesson(second)
        _ = try await repository.lesson(first)
        _ = try await repository.lesson(third)
        let boundedCount = await repository.cachedLessonCount
        check(boundedCount == 2, "Lesson cache stays within its entry limit")
        let quiz = try await repository.practiceItems([first, second, third], quiz: true)
        let expectedQuestions = try [first, second, third].flatMap { entry in
            try JSONDecoder().decode(Lesson.self, from: Data(contentsOf: root.appendingPathComponent("lessons/" + entry.file))).quiz.map { entry.id + "/" + $0.id }
        }
        check(quiz.count == expectedQuestions.count && Set(quiz.map { $0.entry.id + "/" + $0.question!.id }) == Set(expectedQuestions), "Shuffled quiz retains every question exactly once")
        let afterQuizCount = await repository.cachedLessonCount
        check(afterQuizCount <= 2, "Large quiz preparation respects the cache bound")
        let noCache = LessonRepository(resourceRoot: root, byteLimit: 1)
        _ = try await noCache.lesson(first)
        let byteLimitedCount = await noCache.cachedLessonCount
        check(byteLimitedCount == 0, "Oversized lessons are not retained")
        await repository.clearCache()
        let clearedBytes = await repository.cachedJSONBytes
        check(clearedBytes == 0, "Cache eviction frees stored JSON")
        let fixtureRoot = FileManager.default.temporaryDirectory.appendingPathComponent("wortschatz-cache-test-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: fixtureRoot.appendingPathComponent("lessons"), withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: fixtureRoot) }
        for entry in [first, second, third] {
            let destination = fixtureRoot.appendingPathComponent("lessons/" + entry.file)
            try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: root.appendingPathComponent("lessons/" + entry.file), to: destination)
        }
        let templateURL = fixtureRoot.appendingPathComponent("lesson-template.html")
        try "__LESSON_JSON__".write(to: templateURL, atomically: true, encoding: .utf8)
        let lru = LessonRepository(resourceRoot: fixtureRoot, cacheLimit: 2)
        _ = try await lru.lesson(first)
        _ = try await lru.lesson(second)
        _ = try await lru.lesson(first)
        _ = try await lru.lesson(third)
        // Cached data must serve the reader even when the source file is no longer available.
        try FileManager.default.removeItem(at: fixtureRoot.appendingPathComponent("lessons/" + first.file))
        let reader = try await lru.readerSource(first)
        let readerLesson = try JSONDecoder().decode(Lesson.self, from: Data(reader.json.utf8))
        check(readerLesson.word.headword == first.headword, "Reader reuses cached JSON without another file read")
        try FileManager.default.removeItem(at: templateURL)
        let secondReader = try await lru.readerSource(first)
        check(secondReader.template == reader.template, "Reader template loads only once")
        try FileManager.default.removeItem(at: fixtureRoot.appendingPathComponent("lessons/" + second.file))
        do {
            _ = try await lru.lesson(second)
            check(false, "Least recently used lesson must have been evicted")
        } catch { check(true, "Recently used lessons survive LRU eviction") }
        let cancelled = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await repository.practiceItems(index.entries, quiz: true)
        }
        do {
            _ = try await cancelled.value
            check(false, "Cancelled preparation must not complete")
        } catch is CancellationError { check(true, "Preparation honors cancellation") }
        print("Passed \(checks) checks across \(index.entries.count) lessons.")
    }
}
