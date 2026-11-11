import XCTest

final class StudyFlowTests: XCTestCase {
    @MainActor func testKellerReaderLoadsOnFirstAndRepeatOpen() throws {
        let app = makeApp()
        app.launch()
        let search = app.textFields["wordSearch"]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        search.tap()
        search.typeText("keller")
        let result = app.staticTexts["Keller"]
        XCTAssertTrue(result.waitForExistence(timeout: 5))
        for attempt in 1...2 {
            let start = Date()
            result.tap()
            XCTAssertTrue(app.webViews.staticTexts["cellar, basement"].waitForExistence(timeout: 10))
            print("Keller reader attempt \(attempt): \(Date().timeIntervalSince(start)) seconds from tap to visible meaning")
            attach(app, "Keller reader \(attempt)")
            app.navigationBars.buttons.element(boundBy: 0).tap()
            XCTAssertTrue(result.waitForExistence(timeout: 5))
        }
        app.buttons["Clear search"].tap()
        search.tap()
        search.typeText("apple")
        let apple = app.staticTexts["Apfel"]
        XCTAssertTrue(apple.waitForExistence(timeout: 5))
        apple.tap()
        XCTAssertTrue(app.webViews.staticTexts["apple"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.webViews.staticTexts["cellar, basement"].exists, "Reused reader must replace the previous lesson")
    }

    @MainActor func testDailyFiveResumesAndCompletesWithoutDeck() throws {
        let app = makeApp()
        app.launch()
        app.buttons["Practice"].tap()
        let start = app.buttons["startDailyFive"]
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts["dailyProgress"].label, "0 of 5 complete")
        attach(app, "Today’s five ready")
        start.tap()
        let reveal = app.buttons["Reveal meaning"]
        XCTAssertTrue(reveal.waitForExistence(timeout: 10))
        let ready = expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: reveal)
        wait(for: [ready], timeout: 10)
        reveal.tap()
        app.buttons["Another look"].tap()
        XCTAssertTrue(app.staticTexts["2 / 5"].waitForExistence(timeout: 5))
        app.terminate()
        app.launch()
        app.buttons["Practice"].tap()
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        XCTAssertEqual(start.label, "Continue today’s five")
        XCTAssertEqual(app.staticTexts["dailyProgress"].label, "1 of 5 complete")
        start.tap()
        for number in 2...5 {
            XCTAssertTrue(app.staticTexts["\(number) / 5"].waitForExistence(timeout: 10))
            XCTAssertTrue(reveal.waitForExistence(timeout: 10))
            let ready = expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: reveal)
            wait(for: [ready], timeout: 10)
            reveal.tap()
            app.buttons["Got it"].tap()
        }
        XCTAssertTrue(app.staticTexts["Today’s words,\ndone."].waitForExistence(timeout: 5))
        attach(app, "Today’s five complete")
        app.buttons["Finish practice"].tap()
        XCTAssertTrue(app.staticTexts["Today’s five complete"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["dailyProgress"].label, "5 of 5 complete")
        XCTAssertFalse(start.exists)
        app.terminate()
        app.launch()
        app.buttons["Practice"].tap()
        XCTAssertTrue(app.staticTexts["Today’s five complete"].waitForExistence(timeout: 10))
    }

    @MainActor func testSearchDeckLessonAndPractice() throws {
        let app = makeApp()
        app.launch()
        let search = app.textFields["wordSearch"]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        search.tap()
        search.typeText("aelter")
        XCTAssertTrue(app.staticTexts["alt"].waitForExistence(timeout: 5))
        app.buttons["Clear search"].tap()
        search.tap()
        search.typeText("apple")
        XCTAssertTrue(app.staticTexts["Apfel"].waitForExistence(timeout: 5))
        if app.buttons["Add Apfel to deck"].exists { app.buttons["Add Apfel to deck"].tap() }
        XCTAssertTrue(app.buttons["Remove Apfel from deck"].exists)
        app.buttons["My Deck"].tap()
        XCTAssertTrue(app.staticTexts["Apfel"].waitForExistence(timeout: 5))
        app.terminate()
        app.launch()
        app.buttons["My Deck"].tap()
        XCTAssertTrue(app.staticTexts["Apfel"].waitForExistence(timeout: 5), "Deck survives relaunch")
        app.staticTexts["Apfel"].tap()
        XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(app.webViews.staticTexts["apple"].waitForExistence(timeout: 10))
        attach(app, "Lesson")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["Practice my deck"].tap()
        XCTAssertTrue(app.buttons["Reveal meaning"].waitForExistence(timeout: 5))
        app.buttons["Reveal meaning"].tap()
        XCTAssertTrue(app.staticTexts["apple"].waitForExistence(timeout: 5))
        attach(app, "Flashcard")
        app.buttons["Got it"].tap()
        XCTAssertTrue(app.staticTexts["A little more\nyours."].waitForExistence(timeout: 5))
        app.buttons["Finish practice"].tap()
        app.buttons["Practice"].tap()
        let flashcards = app.buttons["startFlashcards"]
        for _ in 0..<3 where !flashcards.isHittable { app.swipeUp() }
        XCTAssertTrue(flashcards.waitForExistence(timeout: 5))
        flashcards.tap()
        XCTAssertTrue(app.buttons["Reveal meaning"].waitForExistence(timeout: 5))
        let flashcardReady = expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: app.buttons["Reveal meaning"])
        wait(for: [flashcardReady], timeout: 10)
        app.buttons["Reveal meaning"].tap()
        app.buttons["Got it"].tap()
        XCTAssertTrue(app.buttons["Finish practice"].waitForExistence(timeout: 5))
        app.buttons["Finish practice"].tap()
        let quiz = app.buttons["startLessonQuiz"]
        for _ in 0..<3 where !quiz.isHittable { app.swipeUp() }
        XCTAssertTrue(quiz.waitForExistence(timeout: 5))
        attach(app, "Practice choices")
        quiz.tap()
        XCTAssertTrue(app.staticTexts["___ Apfel"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["der Apfel"].exists, "Quiz heading must not reveal the noun article")
        app.buttons["der"].tap()
        XCTAssertTrue(app.staticTexts["Richtig!"].waitForExistence(timeout: 5))
        attach(app, "Quiz")
        app.buttons["Continue"].tap()
        let input = app.textFields["Your answer"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.tap()
        input.typeText("wrong")
        app.buttons["Check answer"].tap()
        XCTAssertTrue(app.staticTexts["Keep learning"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["ein Apfel, zwei Äpfel"].exists)
    }
    @MainActor func testMultiWordFlashcardsLoadIncrementally() throws {
        let app = makeApp()
        app.launch()
        let search = app.textFields["wordSearch"]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        for (query, headword) in [("apple", "Apfel"), ("abfahren", "abfahren")] {
            if app.buttons["Clear search"].exists { app.buttons["Clear search"].tap() }
            search.tap()
            search.typeText(query)
            let add = app.buttons["Add " + headword + " to deck"]
            XCTAssertTrue(add.waitForExistence(timeout: 5))
            add.tap()
        }
        app.buttons["My Deck"].tap()
        app.buttons["Practice my deck"].tap()
        for index in 1...2 {
            XCTAssertTrue(app.staticTexts["\(index) / 2"].waitForExistence(timeout: 10))
            let reveal = app.buttons["Reveal meaning"]
            XCTAssertTrue(reveal.waitForExistence(timeout: 5))
            let enabled = expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: reveal)
            wait(for: [enabled], timeout: 10)
            reveal.tap()
            app.buttons["Got it"].tap()
        }
        XCTAssertTrue(app.staticTexts["A little more\nyours."].waitForExistence(timeout: 5))
    }
    @MainActor func testExploreShowsWordsOnlyAfterSearching() throws {
        let app = makeApp()
        app.launch()
        let search = app.textFields["wordSearch"]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["SEARCH RESULTS"].exists)
        XCTAssertFalse(app.segmentedControls["exploreLevelFilter"].exists)
        XCTAssertFalse(app.buttons["Add Apfel to deck"].exists)
        search.tap()
        search.typeText("a")
        XCTAssertTrue(app.staticTexts["SEARCH RESULTS"].waitForExistence(timeout: 5))
        for _ in 0..<4 { app.swipeUp() }
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "to deck")).count > 10,
                      "Scrolling reveals additional search results")
        for _ in 0..<5 { app.swipeDown() }
        app.buttons["Clear search"].tap()
        XCTAssertFalse(app.staticTexts["SEARCH RESULTS"].exists)
    }
    @MainActor func testAbfahrenHasDefaultBreakdownAnimation() throws {
        let app = makeApp()
        app.launch()
        let search = app.textFields["wordSearch"]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        search.tap()
        search.typeText("abfahren")
        app.staticTexts["abfahren"].firstMatch.tap()
        let replay = app.webViews.buttons["abfahren word banner"]
        XCTAssertTrue(replay.waitForExistence(timeout: 10))
        replay.tap()
        XCTAssertFalse(app.webViews.buttons["Replay word animation"].exists)
        XCTAssertTrue(replay.exists)
    }
    @MainActor func testEntschuldigungHasReplayableReleaseAnimation() throws {
        let app = makeApp()
        app.launch()
        let search = app.textFields["wordSearch"]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        search.tap()
        search.typeText("entschuldigung")
        app.staticTexts["Entschuldigung"].firstMatch.tap()
        let replay = app.webViews.buttons["Entschuldigung word banner"]
        XCTAssertTrue(replay.waitForExistence(timeout: 10))
        replay.tap()
        XCTAssertFalse(app.webViews.buttons["Replay word animation"].exists)
        XCTAssertTrue(replay.exists)
    }
    @MainActor func testFeaturedWordExcludesDeck() throws {
        let app = makeApp()
        app.launch()
        let featured = app.buttons["featuredWord"]
        XCTAssertTrue(featured.waitForExistence(timeout: 10))
        let original = featured.label
        featured.tap()
        XCTAssertTrue(app.buttons["Add to deck"].waitForExistence(timeout: 10))
        app.buttons["Add to deck"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(featured.waitForExistence(timeout: 10))
        XCTAssertNotEqual(featured.label, original)
        featured.tap()
        XCTAssertTrue(app.buttons["Add to deck"].waitForExistence(timeout: 10), "Next suggestion is also outside the deck")
    }
    @MainActor func testRiseTurnAndGroupLessons() throws {
        let app = makeApp()
        app.launch()
        for (query, banner) in [("abheben", "abheben word banner"), ("umsteigen", "umsteigen word banner")] {
            let search = app.textFields["wordSearch"]
            XCTAssertTrue(search.waitForExistence(timeout: 10))
            if app.buttons["Clear search"].exists { app.buttons["Clear search"].tap() }
            search.tap()
            search.typeText(query)
            let word = app.staticTexts[query].firstMatch
            XCTAssertTrue(word.waitForExistence(timeout: 5))
            word.tap()
            let hero = app.webViews.buttons[banner]
            XCTAssertTrue(hero.waitForExistence(timeout: 10))
            hero.tap()
            attach(app, query + " animation")
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        app.buttons["Clear search"].tap()
        let search = app.textFields["wordSearch"]
        search.tap()
        search.typeText("Mittwoch")
        app.staticTexts["Wochentage"].firstMatch.tap()
        XCTAssertTrue(app.webViews.staticTexts["The whole set"].waitForExistence(timeout: 10))
    }
    @MainActor func testStudyLevelPersistsAndFiltersFeaturedWord() throws {
        let app = makeApp()
        app.launch()
        app.buttons["Settings"].tap()
        let picker = app.segmentedControls["studyLevelPicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 10))
        picker.buttons["B1"].tap()
        app.buttons["Explore"].tap()
        XCTAssertTrue(app.buttons["featuredWord"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["featuredWord"].value as? String, "B1")
        app.buttons["Settings"].tap()
        picker.buttons["A2"].tap()
        app.buttons["Explore"].tap()
        let featured = app.buttons["featuredWord"]
        XCTAssertTrue(featured.waitForExistence(timeout: 5))
        XCTAssertEqual(featured.value as? String, "A2")
        featured.tap()
        XCTAssertTrue(app.buttons["Add to deck"].waitForExistence(timeout: 10))
        app.terminate()
        app.launch()
        app.buttons["Settings"].tap()
        XCTAssertTrue(picker.buttons["A2"].isSelected)
        attach(app, "Theme row and study level")
        picker.buttons["A1"].tap()
    }
    @MainActor func testThemeSelectionPersists() throws {
        let app = makeApp()
        app.launch()
        app.buttons["Settings"].tap()
        for name in ["Dark", "Dusk", "Warm", "Cool", "Green", "Blue"] {
            let option = app.buttons[name + " theme"]
            XCTAssertTrue(option.waitForExistence(timeout: 5))
            if !option.isHittable { app.swipeUp() }
            option.tap()
            XCTAssertEqual(option.value as? String, "Selected")
            attach(app, name + " theme")
        }
        app.buttons["Dusk theme"].tap()
        app.terminate()
        app.launch()
        app.buttons["Settings"].tap()
        XCTAssertEqual(app.buttons["Dusk theme"].value as? String, "Selected")
        app.buttons["Explore"].tap()
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Discover the word")).firstMatch.tap()
        XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Add to deck"].waitForExistence(timeout: 5), "Featured word is outside the deck")
        attach(app, "Dusk lesson")
        app.buttons["Settings"].tap()
        app.buttons["Warm theme"].tap()
    }
    @MainActor private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["WORTSCHATZ_TEST_DEFAULTS"] = "Wortschatz.UITests." + UUID().uuidString
        return app
    }
    @MainActor private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
