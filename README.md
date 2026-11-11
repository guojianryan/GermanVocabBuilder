# Wortschatz

An iPhone and iPad German vocabulary app built with SwiftUI, for iOS 18 or later. Explore 4,405 bundled lessons, save a personal study deck, and practice with flashcards or the original lesson quizzes.

## Run

Open `Wortschatz.xcodeproj` in Xcode, choose the **Wortschatz** scheme and an iPhone simulator, then Run. To install on an iPhone, select your signing team in the app target’s Signing & Capabilities settings.

No API keys, packages, account, or server are required. The deck is stored locally with UserDefaults. Practice results last for the current session; missed items can be reviewed immediately.

## Features

- Search headwords, conjugations, plurals, related words, and English meanings. German folding and ranking follow `AGENT_BRIEF.md`.
- Explore shows words after searching or selecting a word type, with results displayed in batches of 10 as you scroll. Changing a query or word type resets pagination.
- Add/remove words from Explore, a lesson, or My Deck.
- Banners animate valid root breakdowns by default: two parts slide together; longer breakdowns stretch the second part. Explicit `stretch`, `arrive`, `release`, `rise`, or `turn` settings take priority; `none` and unknown values suppress the default. Release pulses the preceding prefix, then lifts and clears the red root. Tap an animated lesson banner to replay; Reduce Motion keeps it static.
- The index loads asynchronously at startup. Lesson reads and decoding run on a background actor, with an LRU cache capped at 32 lessons and 4 MB of raw JSON. The reader reuses the cached JSON and template. The supplied HTML renderer lives in WKWebView with an offline, app-matched reading style, all optional lesson sections, translation toggle, and interactive quizzes.
- My Deck renders rows lazily and resolves saved IDs through a cached dictionary. Flashcards load only the active lesson, reveal meanings and examples; self-assess recall and review missed cards.
- Lesson quiz mode supports choices, fill-in answers, and manually assessed open responses. Multi-word sessions prepare and shuffle questions in the background once at the start, without retaining every full lesson. Explanations and completed sentences follow answers.
- German pronunciation uses Apple’s on-device `AVSpeechSynthesizer` for headwords and example sentences. This is Apple speech synthesis, rather than an Apple Intelligence audio-generation service. Voice quality depends on German voices installed on the device; audio should be checked on a real iPhone.
- Settings with Twilines Dark, Dusk, Warm, and Cool palettes, plus dark forest Green and midnight Blue. The chosen theme is saved locally and applies to Explore, My Deck, Practice, and the lesson reader. Warm is the default.
- Settings offers a saved current German level (A1, A2, B1, B2, or C1; A1 by default). Explore suggests only words at that level outside the study deck, with an empty state when that level has no lessons or all its words are saved. All six theme swatches appear in a three-column, two-row grid.
- Native navigation, VoiceOver labels, reduced-motion support in the lesson reader, and layouts for iPhone and iPad.

## Lesson content

Lesson JSON provides the content and root breakdowns; `site/lesson-template.html` renders the lessons. Xcode copies the `lessons` folder while preserving its paths. Only entries in `lessons/index.json` appear in the app; `samples` is never indexed or displayed. Header level values in the index are used for filtering.

After adding lessons:

```sh
python3 tools/build_index.py
python3 tools/validate.py lessons/a1/*.json lessons/a2/*.json lessons/b1/*.json
```

The validator requires `jsonschema`. Add other level folders to the validation command as needed. Rebuilding the app picks up new indexed lesson files without code changes.

## Verification

Core search, all lesson decoding, and quiz answer normalization:

```sh
swiftc -module-cache-path /tmp/wortschatz-swift-cache Wortschatz/Core/Lessons.swift Tests/CoreTests.swift -o /tmp/wortschatz-core-tests
/tmp/wortschatz-core-tests
```

Build:

```sh
xcodebuild -project Wortschatz.xcodeproj -scheme Wortschatz -sdk iphonesimulator -derivedDataPath /tmp/WortschatzBuild CODE_SIGNING_ALLOWED=NO build
```

Run the UI test from Xcode’s Test action (⌘U). It verifies search, deck persistence across relaunch, lesson rendering, flashcards, and quiz feedback on a simulator. UI tests use isolated preferences in Debug builds, so practice and persistence checks do not change the simulator’s normal deck.

`tools/create_xcode_project.py` regenerates the Xcode project and shared scheme if source files are added. `tools/draw_icon.swift` draws the app icon with macOS AppKit.

## Screenshots

[Explore](docs/screenshots/explore.png) · [Flashcards](docs/screenshots/flashcards.png) · [Settings](docs/screenshots/settings-dusk.png)
