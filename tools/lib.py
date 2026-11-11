"""Helpers for writing A1 lessons compactly. Every lesson ends up as plain JSON
in the lesson schema; these functions only save typing."""
import json, os, re

OUT = "/home/claude/a1/lessons"
os.makedirs(OUT, exist_ok=True)
ART = {"m": "der", "f": "die", "n": "das"}
GENDER = {"m": "masculine", "f": "feminine", "n": "neuter"}


def slug(head):
    s = head.lower()
    for a, b in (("ä", "ae"), ("ö", "oe"), ("ü", "ue"), ("ß", "ss")):
        s = s.replace(a, b)
    return re.sub(r"[^a-z0-9]+", "-", s).strip("-")


def q_choice(prompt, options, answer, explanation=""):
    return {"type": "choice", "prompt": prompt, "options": options, "answer": answer, "explanation": explanation}


def q_fill(prompt, answer, full="", explanation="", accept=None):
    d = {"type": "fill-in-the-blank", "prompt": prompt, "answer": answer, "fullAnswer": full, "explanation": explanation}
    if accept:
        d["acceptedAnswers"] = accept
    return d


def q_open(prompt, answers, explanation=""):
    return {"type": "open", "prompt": prompt, "acceptedAnswers": answers, "explanation": explanation}


def s(de, en, hl=None):
    d = {"german": de, "english": en}
    if hl:
        d["highlight"] = hl
    return d


def finish(d, quiz):
    for i, q in enumerate(quiz):
        q["id"] = "q%d" % (i + 1)
    d["quiz"] = quiz
    assert len(quiz) >= 5, d["word"]["headword"] + " has fewer than 5 questions"
    path = os.path.join(OUT, slug(d["word"]["headword"]) + ".json")
    json.dump(d, open(path, "w"), ensure_ascii=False, indent=2)
    return d


def header(kind):
    return {"schemaVersion": "1.4", "language": "de", "explanationLanguage": "en",
            "level": "A1", "levelSource": "Goethe-Zertifikat A1 Wortliste", "lessonType": kind}


def noun(word, g, plural, resp, ipa, meaning, sentences, quiz, hook, tip=None, ety=None,
         family=None, note="", forms=None, sign="Gut gemacht!"):
    """A short card for a noun. Adds two questions automatically: gender and plural.
    plural: the plural form without article, or None if there isn't one."""
    art = ART[g]
    pl = ("Plural: die %s." % plural) if plural else "Usually no plural."
    d = header("card")
    d["word"] = {"headword": word, "partOfSpeech": "noun, %s (%s %s)" % (GENDER[g], art, word),
                 "pronunciation": {"respelling": resp, "ipa": ipa, "notes": (note + " " + pl).strip()},
                 "meaning": meaning, "shortDefinition": meaning[:1].upper() + meaning[1:] + "."}
    if ety:
        d["etymology"] = {"title": "Where it comes from", **ety}
    if family:
        d["wordFamily"] = family
    mistakes = [{"title": "Gender and plural", "explanation": "%s %s%s." % (art.capitalize(), word, (", plural die " + plural) if plural else ", usually no plural"),
                 "forms": [{"label": "One", "value": "%s %s" % (art, word)}] +
                          ([{"label": "More than one", "value": "die " + plural}] if plural else [])}]
    if tip:
        mistakes.append(tip)
    d["commonMistakes"] = mistakes
    d["sampleSentences"] = sentences
    auto = [q_choice("___ %s" % word, ["der", "die", "das"], art, "%s is %s." % (word, GENDER[g]))]
    if plural:
        auto.append(q_fill("ein %s, zwei ___" % word, plural, "ein %s, zwei %s" % (word, plural),
                           "The plural is %s." % plural,
                           accept=[plural.replace("ä", "ae").replace("ö", "oe").replace("ü", "ue")]))
    d["forms"] = forms or ([plural] if plural else [])
    d["memoryHook"] = hook
    d["signOff"] = sign
    return finish(d, auto + quiz)


def card(word, pos, resp, ipa, meaning, sentences, quiz, hook, tip=None, ety=None, family=None,
         note="", forms=None, table=None, sign="Gut gemacht!"):
    """A short card for anything that isn't a noun (verbs, adjectives, adverbs, phrases)."""
    d = header("card")
    d["word"] = {"headword": word, "partOfSpeech": pos,
                 "pronunciation": {"respelling": resp, "ipa": ipa, "notes": note},
                 "meaning": meaning, "shortDefinition": meaning[:1].upper() + meaning[1:] + "."}
    if ety:
        d["etymology"] = {"title": "Where it comes from", **ety}
    if table:
        d["tables"] = [table]
    if family:
        d["wordFamily"] = family
    if tip:
        d["commonMistakes"] = tip if isinstance(tip, list) else [tip]
    d["sampleSentences"] = sentences
    d["forms"] = forms or []
    d["memoryHook"] = hook
    d["signOff"] = sign
    return finish(d, quiz)


def present(stem_forms, perfekt=None, title="Present tense", note=None):
    """stem_forms: six strings like 'mach|e' for ich, du, er, wir, ihr, sie."""
    labels = ["ich", "du", "er, sie, es", "wir", "ihr", "sie, Sie"]
    cols = ["present"]
    rows = []
    for i, f in enumerate(stem_forms):
        rows.append({"label": labels[i], "cells": [f]})
    t = {"title": title, "columns": cols, "rows": rows}
    notes = []
    if perfekt:
        notes.append("Past (Perfekt): " + perfekt)
    if note:
        notes.append(note)
    if notes:
        t["notes"] = notes
    return t


def full(d, quiz):
    """A full lesson written out as a dict (same shape as the pilot lessons)."""
    base = header("full")
    base.update(d)
    return finish(base, quiz)
