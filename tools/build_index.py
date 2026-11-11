"""Build lessons/index.json from every lesson file.

Usage:  python3 tools/build_index.py [lessons_dir]
Default lessons_dir: ../lessons relative to this script (or ./lessons).

For each lesson the index lists:
  - the headword as taught, plus the article form for nouns ("der Tisch")
  - every other form found in the lesson: the `forms` list, table cells,
    the hero cycle, labelled forms in commonMistakes, and words that point
    here from elsewhere (aliases)
  - related words from wordFamily, kept separate because they are different words
  - searchKeys: all of the above folded for search (lower case, umlauts and
    ß folded) so an app can match with a simple prefix test
It also writes a reverse `lookup` map: folded form -> lesson ids.
"""
import json, os, re, sys, glob, datetime

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = sys.argv[1] if len(sys.argv) > 1 else next(
    p for p in [os.path.join(HERE, "..", "lessons"), os.path.join(HERE, "lessons")] if os.path.isdir(p))
ROOT = os.path.abspath(ROOT)

# Words with no lesson of their own, taught inside another lesson. headword -> lesson id
ALIASES = {
    "ankommen": "ankunft",
    "der Anruf": "anrufen",
    "das Alter": "alt",
    "die Abfahrt": "abfahren",
    "das Angebot": "anbieten",
    "der Anfang": "anfangen",
    "die Anmeldung": "sich-anmelden",
    "die Antwort": "antworten",
    "die Arbeit": "arbeiten",
}
AUX = {"habe", "hast", "hat", "haben", "habt", "bin", "bist", "ist", "sind", "seid"}
ARTICLES = {"masculine": "der", "feminine": "die", "neuter": "das"}


def slug(head):
    s = head.lower()
    for a, b in (("ä", "ae"), ("ö", "oe"), ("ü", "ue"), ("ß", "ss")):
        s = s.replace(a, b)
    return re.sub(r"[^a-z0-9]+", "-", s).strip("-")


def fold(s):
    """Search folding. Apply the same function to the user's query."""
    s = s.lower().strip()
    s = re.sub(r"^\(sich\)\s*", "", s)
    for a, b in (("ä", "a"), ("ö", "o"), ("ü", "u"), ("ae", "a"), ("oe", "o"), ("ue", "u"), ("ß", "ss")):
        s = s.replace(a, b)
    return re.sub(r"\s+", " ", s)


def clean(s):
    return re.sub(r"\s+", " ", s.replace("|", "")).strip(" ,.;")


def table_forms(d):
    out = []
    for t in d.get("tables", []):
        for r in t.get("rows", []):
            for c in r.get("cells", []):
                c = c.replace("|", "")
                if "…" in c:
                    left, right = [x.strip() for x in c.split("…", 1)]
                    if not re.fullmatch(r"[A-Za-zÄÖÜäöüß-]{2,}", right):
                        continue
                    if left in AUX:
                        out.append(right)                       # habe … angerufen -> angerufen
                    elif re.fullmatch(r"[A-Za-zÄÖÜäöüß]+", left):
                        out.append(f"{left} {right}")           # rufe … an -> rufe an
                elif re.fullmatch(r"[A-Za-zÄÖÜäöüß-]+", c.strip()):
                    out.append(c.strip())                       # einen, weiß, älter
    return out


entries, seen = [], set()
LEVEL_DIRS = ["a1", "a2", "b1", "b2", "c1", "c2"]  # other folders (e.g. old samples) are ignored
for path in sorted(p for lv in LEVEL_DIRS for p in glob.glob(os.path.join(ROOT, lv, "*.json"))):
    d = json.load(open(path, encoding="utf-8"))
    w = d["word"]
    head = w["headword"]
    lid = slug(head)
    pos = w.get("partOfSpeech", "")
    gender = next((g for g in ARTICLES if pos.startswith("noun, " + g)), None)
    article = ARTICLES.get(gender)

    forms = [head]
    if article:
        forms.append(f"{article} {head}")
    for member in d.get("members", []):
        forms += [member["german"]]
        if member.get("plural"):
            forms.append(member["plural"])
    forms += d.get("forms", [])
    forms += w.get("cycle", [])
    forms += table_forms(d)
    for m in d.get("commonMistakes", []):
        f = m.get("forms")
        if isinstance(f, list):
            forms += [x["value"] for x in f]
        elif isinstance(f, dict):
            forms += list(f.values())
    aliases = [a for a, target in ALIASES.items() if target == lid]
    related = [x["german"] for x in d.get("wordFamily", [])]

    def uniq(xs):
        out, keys = [], set()
        for x in map(clean, xs):
            k = x.lower()
            if x and k not in keys and " und " not in x and len(x.split()) <= 3:
                keys.add(k); out.append(x)
        return out

    forms = uniq(forms + aliases)
    related = [r for r in uniq(related) if r.lower() not in {f.lower() for f in forms}]
    keys = sorted({fold(x) for x in forms + related} | {fold(re.sub(r"^(der|die|das) ", "", x)) for x in forms})

    if lid in seen:
        sys.exit(f"duplicate lesson id {lid} ({path})")
    seen.add(lid)
    entries.append({
        "id": lid,
        "headword": head,
        "file": os.path.relpath(path, ROOT).replace(os.sep, "/"),
        "level": d["level"],
        "lessonType": d["lessonType"],
        "partOfSpeech": pos,
        "gender": gender,
        "article": article,
        "meaning": w.get("meaning", ""),
        "forms": forms,
        "related": related,
        "searchKeys": keys,
    })

entries.sort(key=lambda e: (["A1", "A2", "B1", "B2", "C1", "C2"].index(e["level"]), fold(e["headword"])))
lookup = {}
for e in entries:
    for f in e["forms"]:
        k = fold(f)
        lookup.setdefault(k, [])
        if e["id"] not in lookup[k]:
            lookup[k].append(e["id"])

index = {
    "indexVersion": "1.0",
    "generatedAt": datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat(),
    "count": len(entries),
    "levels": {lv: sum(e["level"] == lv for e in entries) for lv in ["A1", "A2", "B1", "B2", "C1", "C2"] if any(e["level"] == lv for e in entries)},
    "folding": "lower case; strip a leading '(sich) '; ä/ae→a, ö/oe→o, ü/ue→u, ß→ss; collapse spaces",
    "entries": entries,
    "lookup": dict(sorted(lookup.items())),
}

out = os.path.join(ROOT, "index.json")
json.dump(index, open(out, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

schema_path = next((p for p in [os.path.join(HERE, "index.schema.json"), os.path.join(HERE, "..", "schema", "index.schema.json")] if os.path.exists(p)), None)
if schema_path:
    from jsonschema import Draft202012Validator
    errs = list(Draft202012Validator(json.load(open(schema_path))).iter_errors(index))
    for e in errs[:10]:
        print("INVALID:", "/".join(map(str, e.absolute_path)), e.message)
    if errs:
        sys.exit(1)
print(f"wrote {out}: {len(entries)} lessons, {sum(len(e['forms']) for e in entries)} forms, {len(lookup)} lookup keys")
