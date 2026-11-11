# Brief for the app: German vocabulary lessons

You'll be building an app that shows German vocabulary lessons. The lessons themselves are already written. Each one is a JSON file in a fixed format, and more are being added over time in exactly the same format. Your job is to read and display them, not to write or change them.

## Folder layout

```
GermanVocab/
  lessons/
    index.json     generated index of every lesson with all its forms (see "The index")
    a1/            one JSON file per word (A1 level), e.g. mit.json, tisch.json
    a2/            same for A2, and so on up to C2 as they're written
  schema/
    lesson.schema.json   JSON Schema (draft 2020-12) for one lesson file
    index.schema.json    JSON Schema for lessons/index.json
  tools/
    validate.py          checks lesson files against the schema plus extra rules
    build_index.py       rebuilds lessons/index.json and validates it
    a1_progress.json     which A1 words are done and which are still to come
  site/
    lesson-template.html working web renderer, use it as a reference
```

Only the level folders (`a1` … `c2`) count. Any other folder under `lessons/` (such as an old `samples/`) should be ignored.

- **One lesson per file.** The file name is the headword in lower case, with ä→ae, ö→oe, ü→ue, ß→ss and any other characters turned into hyphens: `Wohnung` → `wohnung.json`, `(sich) anziehen` → `sich-anziehen.json`, `all-` → `all.json`. The validator enforces this.
- **The level comes from the field, not the folder.** Use `level` (A1–C2) as the source of truth.
- **The index.** `lessons/index.json` lists every lesson. Use it for the word list and for search, and load a lesson file only when it's opened.

## Validating

```
pip install jsonschema
python3 tools/validate.py lessons/a1/*.json
```

The exit code is 0 if every file is valid. Run this in your build or tests. If a lesson fails, report it. Don't change the content to make it pass.

## The format at a glance

Every lesson has these header fields:

| Field | Meaning |
|---|---|
| `schemaVersion` | currently `"1.4"`. New fields only ever bump the minor number. |
| `language`, `explanationLanguage` | `"de"`, `"en"` |
| `level` | `"A1"` … `"C2"` |
| `levelSource` | e.g. `"Goethe-Zertifikat A1 Wortliste"` |
| `lessonType` | `"full"` (long lesson for tricky words) or `"card"` (short card for simple words) |

Then the content. Only `word`, `sampleSentences`, `quiz` and `memoryHook` are always present. **Every other section is optional: if it's missing, don't show it.**

| Section | What it is | Notes |
|---|---|---|
| `word` | headword, partOfSpeech, meaning, shortDefinition, pronunciation {respelling, ipa, notes}, optional `cycle` | For nouns the gender and article are in `partOfSpeech`, e.g. "noun, masculine (der Tisch)". |
| `intro` | title + paragraphs | Mainly in full lessons. |
| `etymology` | title, summary; `parts` (word split into pieces) and/or `cognates` (related words in other languages); `literalMeaning`; `bonus` box | |
| `tables` | form tables: title, intro, columns, rows {label, hint, cells}, notes | Conjugations, declensions, comparisons. |
| `wordFamily` | related words: german, english, literal, type | |
| `keyTrap` | the main mistake: wrong {german, verdict or actualMeaning}, correct [{german, literal, note}] | Show as a red crossed-out sentence, then the correct versions. |
| `commonMistakes` | list; each has a title and explanation plus one of `wrong`/`correct`, `examples`, or `forms` | |
| `sampleSentences` | german, english, optional `highlight` list | |
| `quiz` | **at least 5 questions** | See below. |
| `forms` | other forms of the word, for search only | Not displayed. |
| `memoryHook`, `signOff` | closing line and a short German send-off | |

The schema file has a description on every field. Treat it as the full reference.

## Rules you can't see in the schema

**Highlighted parts in table cells.** Table cells mark a highlighted part with pipes:
- `"ein|en"` → ein + **en**
- `"a|m| Tisch"` → a + **m** + " Tisch"
- `"|weiß"` → **weiß**

There are never more than two pipes. Don't display the pipes themselves.

**Sentence highlights.** `sampleSentences[].highlight` is a list of words to highlight in the German sentence. Match whole words, ignore case, and ignore trailing `. , ! ? …` on both sides.

**Example highlights.** `commonMistakes[].examples[].highlight` is a single string:
1. If the sentence contains the headword immediately followed by that string, highlight only the ending: `langweilig` + `er` in "ein langweiliger Film".
2. Otherwise highlight the whole word that equals it: `am` in "die Ankunft am Flughafen".

**Questions.** `quiz[].type` is one of three types:
- `choice`: show `options` as buttons. It's correct if it equals `answer`.
- `fill-in-the-blank`: the gap in `prompt` is written as `___`. Accept `answer`, `fullAnswer` or anything in `acceptedAnswers`.
- `open`: there's no automatic check. Show `acceptedAnswers` as model answers when the learner asks to see the answer.

To compare answers, trim spaces, ignore case and drop trailing `.!?`. `acceptedAnswers` already includes spellings without umlauts where they matter (ae for ä, and so on). After answering, show `explanation`, and `fullAnswer` if there is one.

**Word breakdowns (`etymology.parts`).** About 157 A1 lessons split the headword into parts:
- Separable and prefixed verbs: *ab + holen*, *ver + stehen*.
- Compounds: *Arbeit + s + platz*.
- Suffix words: *Lös + ung*, *glück + lich*.

Rules:
- Each part has a `meaning` and an optional `note`, and the lesson gives the `literalMeaning` of the whole.
- **The parts always spell the headword.** Matching ignores case, leading or trailing hyphens and a leading "(sich) ". One trailing letter of a part may drop: *Weile* matches *weil* in *langweilig*. `tools/validate.py` enforces this, so you can safely split the headword on screen using the parts.
- Where the spelling changes between the parts and the word (an umlaut, as in *Brot + -chen = Brötchen*), there's no `parts` list, only a text `summary`.

**Hero animation (optional, just nice to have):**
- Valid breakdowns with no explicit `emphasis` use a default animation: two parts slide the second part into place (`arrive`); three or more parts stretch the second part (`stretch`). A single part or unmatched breakdown stays still.
- If any part has an explicit `emphasis`, use only explicit supported animations. `"none"` and unknown values stay still and suppress the automatic default for that word.
- At most one part per word has an emphasis, and the animation plays once when the lesson opens. It never loops.
- Split the headword into pieces using `parts` (see the spelling rule above), and draw each piece as its own text run, so one piece can move without the others.
- The animation should show what the word means. Keep it small: the word must stay readable the whole time and end up in the same place it started.

| Value | Meaning it shows | Start | Motion | End | Example |
|---|---|---|---|---|---|
| `"stretch"` | Something that drags out or lasts long | Normal ink, normal letter spacing (about -0.02em) | Letter spacing widens to 0.32em (0.14em on narrow phones under ~480px). 2.6s, ease-in-out curve `cubic-bezier(.45,0,.2,1)`, after a 0.3s pause | Accent blue, still spread out | *lang**Weile**ig*: the boredom drags |
| `"arrive"` | Coming or reaching somewhere | Accent blue, shifted right by 1.1em | Slides left into place. 1.8s, ease-out curve `cubic-bezier(.15,.7,.2,1)`, after a 0.3s pause | Accent blue, in place | *An**kunft***: the coming arrives |
| `"release"` | Something taken away, so you're freed from it (mostly after *ent-*) | The piece in the red correction ink, slightly heavier (weight 600 against 500) | 1. At 0.5s the piece **before** it pulses to the accent blue and back over 0.8s (the prefix does the freeing). 2. At 1.2s the piece drains from red to normal ink, drops back to normal weight, and lifts about 0.06em then settles back. 1.5s, curve `cubic-bezier(.3,.7,.3,1)` | Normal ink and weight, like the rest of the word | *Ent**schuld**igung*: the guilt is lifted off you |
| `"rise"` | Going up | Accent blue, shifted down by 0.35em | Rises into place. 1.8s, ease-out curve `cubic-bezier(.15,.7,.2,1)`, after a 0.3s pause | Accent blue, in place | ***auf**stehen*: getting up |
| `"turn"` | Turning round, changing over (mostly *um-*) | Accent blue | Turns once round its vertical axis (rotateY 0 → 360°, with a little perspective). 1.6s, ease-in-out curve `cubic-bezier(.45,0,.2,1)`, after a 0.3s pause | Accent blue, facing front again | ***um**steigen*: changing over to another train |

- Colours are the lesson page tokens: ink `#18233A`, accent blue `#2340B0`, correction red `#C42B2B` (use the dark-mode versions in dark mode).
- If `"release"` is on the first piece, there's no piece before it, so skip step 1.
- **Reduced motion:** when the device is set to reduce motion, skip the motion and show the end state straight away. For `"release"`, the end state is plain, so the word just looks normal.
- New values may be added later. Treat an unknown `emphasis` value like `"none"`, so older apps don't break.
- `word.cycle` lists forms to step through before settling on the headword. Skip it as well when reduce motion is on.
- The reference page (`site/lesson-template.html`, `.seg.stretch`, `.seg.arrive`, `.seg.release` and `.seg.release-cue` in its CSS) does exactly this, if you want working code to copy.

**Group lessons.** A group lesson (`lessonType: "group"`) teaches a closed set in one go, because the pattern matters more than each word (all days take *am*, all months *im*). The headword is the set's German name (*Wochentage*, *Farben*), `partOfSpeech` starts with "word group", and there's no hero animation. Show `intro`, then `members`, then the usual sections. In the index, searching any member (*Mittwoch*, *lila*) finds the group.

**Search.** Use `lessons/index.json`, described in the next section, rather than opening every lesson.

**Unknown fields.** The schema rejects unknown fields so that typos in the content get caught. Your app should still **ignore unknown fields rather than crash**, so that older versions of the app keep working when a newer version of the format arrives.

## The index

`lessons/index.json` is generated, so don't edit it by hand. Rebuild and validate it whenever lessons are added or changed:

```
python3 tools/build_index.py
```

Its structure is described in `schema/index.schema.json`. Top level:

| Field | Meaning |
|---|---|
| `indexVersion` | currently `"1.0"` |
| `generatedAt` | when the index was built |
| `count` | total number of lessons |
| `levels` | number of lessons per level |
| `folding` | describes the folding rule below |
| `entries` | one per lesson, sorted by level then headword |
| `lookup` | a reverse map for exact matches |

One entry looks like this:

```json
{
  "id": "anrufen",
  "headword": "anrufen",
  "file": "a1/anrufen.json",
  "level": "A1",
  "lessonType": "full",
  "partOfSpeech": "separable verb",
  "gender": null,
  "article": null,
  "meaning": "to call (on the phone)",
  "forms": ["anrufen", "rufe an", "rufst an", "ruft an", "rufen an", "angerufen", "rief an", "der Anruf"],
  "related": ["der Anrufbeantworter", "zurückrufen", "rufen", "telefonieren"],
  "searchKeys": ["angerufen", "anruf", "anrufen", "der anruf", "…"]
}
```

What each field gives you:

- **`id`** is the file name without `.json`. Use it as the stable key for links, favourites and progress.
- **`headword`** is the original form as taught. **`forms`** starts with the headword, then lists every form of the same word found in the lesson, with umlauts as normally written:
  - the article form and plural for nouns (`der Tisch`, `die Tische`)
  - conjugated and split verb forms (`rufe an`), past participles (`angerufen`)
  - comparatives (`älter`) and declined forms (`einen`, `einem`)
  - words that are taught inside this lesson and have no lesson of their own, like `ankommen` inside *Ankunft* or `der Anruf` inside *anrufen*
- **`related`** lists different but related words from the word family. Rank them below matches in `forms`.
- **`gender`** and **`article`** are filled for nouns and `null` otherwise.
- **`searchKeys`** is every form and related word after folding, plus each noun form without its article.

**Folding.** Apply the same function to whatever the user types:

1. lower-case the text
2. strip a leading `(sich) `
3. replace ä or ae with a, ö or oe with o, ü or ue with u, and ß with ss
4. collapse repeated spaces

```js
const fold = s => s.toLowerCase().trim().replace(/^\(sich\)\s*/, "")
  .replace(/ä|ae/g, "a").replace(/ö|oe/g, "o").replace(/ü|ue/g, "u").replace(/ß/g, "ss").replace(/\s+/g, " ");
```

**Suggested search:**

1. Fold the query.
2. Look up exact matches in `lookup[foldedQuery]`.
3. Then find prefix matches: any entry with a `searchKey` that starts with the query, or that has any word starting with the query.
4. Rank exact headword matches first, then exact matches in `forms`, then prefix matches in `forms`, then matches in `related`.

So *rufe* finds *anrufen*, *aelter* finds *alt*, *weiß* finds *kennen*, and *die tische* finds *Tisch*.

**One form can belong to several lessons.** For example, *weiß* will belong to both *kennen* and *wissen*. That's why `lookup` values are lists. When there's more than one match, show all of them with their meaning.

The whole index is small (well under 1 MB even for all of A1), so load it once and keep it in memory.

## Suggested display order

Header (level, and whether it's a short card) → headword with meaning and pronunciation → intro → where it comes from → tables → word family → the big trap → common mistakes (titled "Good to know" when there's no `keyTrap`) → sample sentences (with a hide-translations toggle) → quiz → memory hook and sign-off.

`site/lesson-template.html` follows this order. Its JavaScript (`render()`) shows how each field is handled, so check it whenever this brief is unclear.

## What's not decided yet

These are open questions to raise with me rather than assume:
- audio and pronunciation recordings
- user accounts and progress tracking
- whether lessons ship inside the app or download by level
