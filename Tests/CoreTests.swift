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
        var reviewCalendar = Calendar(identifier: .gregorian)
        reviewCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let reviewToday = reviewCalendar.startOfDay(for: Date(timeIntervalSince1970: 1_700_006_400))
        func day(_ offset: Int, from date: Date = Date(timeIntervalSince1970: 1_700_006_400)) -> Date {
            reviewCalendar.date(byAdding: .day, value: offset, to: reviewCalendar.startOfDay(for: date))!
        }
        var scheduled = ReviewProgress(due: reviewToday)
        var practiced = reviewToday
        for (i, interval) in ReviewProgress.intervals.enumerated() {
            check(scheduled.isDue(at: practiced, calendar: reviewCalendar), "Scheduled word is due on its review day")
            scheduled.record(success: true, at: practiced, calendar: reviewCalendar)
            check(scheduled.stage == i + 1 && scheduled.nextReview == day(interval, from: practiced), "Successful recall advances to interval \(interval)")
            let unchanged = scheduled.nextReview
            scheduled.record(success: true, at: practiced.addingTimeInterval(100), calendar: reviewCalendar)
            check(scheduled.stage == i + 1 && scheduled.nextReview == unchanged, "Repeated same-day success cannot advance the schedule")
            practiced = scheduled.nextReview
        }
        scheduled.record(success: true, at: practiced, calendar: reviewCalendar)
        check(scheduled.stage == 5 && scheduled.nextReview == day(30, from: practiced), "Mature words retain the 30-day interval")
        scheduled.record(success: false, at: practiced, calendar: reviewCalendar)
        check(scheduled.stage == 0 && scheduled.nextReview == day(1, from: practiced), "A lapse resets the word for tomorrow")
        scheduled.record(success: true, at: practiced.addingTimeInterval(300), calendar: reviewCalendar)
        check(scheduled.stage == 0 && scheduled.nextReview == day(1, from: practiced), "Immediate retry after a lapse does not promote the word")
        scheduled.record(success: true, at: day(1, from: practiced), calendar: reviewCalendar)
        check(scheduled.stage == 1, "A later successful recall restarts the interval ladder")
        var early = ReviewProgress(due: day(7))
        early.record(success: true, at: reviewToday, calendar: reviewCalendar)
        check(early.stage == 0 && early.nextReview == day(7), "Early extra practice does not bring a future review forward")
        check(early.successHint(at: reviewToday, calendar: reviewCalendar) == "In 7 days", "Button hint matches the saved next review")
        let decodedSchedule = try JSONDecoder().decode(ReviewProgress.self, from: JSONEncoder().encode(scheduled))
        check(decodedSchedule == scheduled, "Review dates, stages, and last practice survive persistence")
        let a1 = index.entries.filter { $0.level == "A1" }
        let failed = a1[0].id, familiar = a1[1].id
        let migrated = ReviewProgress.migrate([failed: false, familiar: true], at: reviewToday, calendar: reviewCalendar)
        check(migrated.count == 2 && migrated.values.allSatisfy { $0.stage == 0 && $0.lastPracticed == nil && $0.isDue(at: reviewToday, calendar: reviewCalendar) }, "Old recall history migrates to due-today records without invented stages")
        let dueReviews = [failed: ReviewProgress(due: day(-3)), familiar: ReviewProgress(due: day(-1))]
        let daily = DailyFive.make(day: "today", level: "A1", candidates: index.entries,
                                   reviews: dueReviews, now: reviewToday, calendar: reviewCalendar)
        check(daily.wordIDs.count == 5 && Set(daily.wordIDs).count == 5, "Daily set has five unique words")
        check(daily.wordIDs[0] == failed && daily.wordIDs[1] == familiar, "Daily review starts with the most overdue words")
        check(daily.wordIDs.dropFirst(2).allSatisfy { dueReviews[$0] == nil }, "Remaining daily slots contain new words")
        let fresh = DailyFive.make(day: "today", level: "A1", candidates: index.entries, reviews: [:], now: reviewToday)
        check(fresh.wordIDs.count == 5 && fresh.wordIDs.allSatisfy { id in a1.contains { $0.id == id } }, "Daily set works without a deck and stays at the chosen level")
        let allScheduled = Dictionary(uniqueKeysWithValues: a1.map { ($0.id, ReviewProgress(due: day(3))) })
        let notDue = DailyFive.make(day: "today", level: "A1", candidates: a1, reviews: allScheduled, now: reviewToday)
        check(notDue.wordIDs.isEmpty, "Daily set does not bring scheduled future words forward")
        let backlog = Dictionary(uniqueKeysWithValues: a1.prefix(7).enumerated().map { ($0.element.id, ReviewProgress(due: day(-10 + $0.offset))) })
        let dueOnly = DailyFive.make(day: "today", level: "A1", candidates: index.entries.reversed(), reviews: backlog, now: reviewToday)
        check(dueOnly.wordIDs == Array(a1.prefix(5)).map(\.id), "All five daily slots prioritize due words, leaving overflow for optional review")
        let small = DailyFive.make(day: "today", level: "A1", candidates: Array(a1.prefix(3)), reviews: [:])
        check(small.wordIDs.count == 3, "Small catalogs never duplicate daily words")
        let empty = DailyFive.make(day: "today", level: "missing", candidates: index.entries, reviews: [:])
        check(empty.wordIDs.isEmpty && !empty.isComplete, "Empty sets are not marked complete")
        var berlin = Calendar(identifier: .gregorian)
        berlin.timeZone = TimeZone(identifier: "Europe/Berlin")!
        let beforeDST = berlin.date(from: DateComponents(year: 2026, month: 3, day: 29, hour: 22))!
        var dstReview = ReviewProgress(due: berlin.startOfDay(for: beforeDST))
        dstReview.record(success: true, at: beforeDST, calendar: berlin)
        let dueParts = berlin.dateComponents([.day, .hour], from: dstReview.nextReview)
        check(dueParts.day == 30 && dueParts.hour == 0 && dstReview.nextReview.timeIntervalSince(berlin.startOfDay(for: beforeDST)) == 23 * 3600, "Intervals follow local calendar days across daylight-saving changes")
        var progress = daily
        progress.record("unknown", success: true)
        check(progress.completedCount == 0, "Unrelated practice does not advance a daily set")
        progress.record(failed, success: false)
        progress.record(failed, success: true)
        check(progress.completedCount == 1 && progress.outcomes[failed] == false, "Daily progress counts an attempt once, including missed recalls")
        let restored = try JSONDecoder().decode(DailyFive.self, from: JSONEncoder().encode(progress))
        check(restored == progress, "Daily selection and partial progress survive persistence")
        for id in daily.wordIDs { progress.record(id, success: true) }
        check(progress.isComplete && progress.completedCount == 5, "All attempted words finish the day regardless of score")
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(secondsFromGMT: 0)!
        let midnight = Date(timeIntervalSince1970: 1_700_006_400)
        let start = utc.startOfDay(for: midnight)
        check(DailyFive.dayKey(start, calendar: utc) != DailyFive.dayKey(start.addingTimeInterval(-1), calendar: utc), "Daily key changes at local midnight")
        check(DailyFive.dayKey(start, calendar: utc) == DailyFive.dayKey(start.addingTimeInterval(60), calendar: utc), "Daily key stays fixed within the day")
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
