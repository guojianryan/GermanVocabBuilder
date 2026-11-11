"""Check every lesson, then build the preview page and a progress file."""
import json, glob, os, sys

problems = []
lessons = []
for p in sorted(glob.glob("/home/claude/a1/lessons/*.json")):
    d = json.load(open(p))
    w = d.get("word", {}).get("headword", os.path.basename(p))
    for key in ["level", "lessonType", "word", "sampleSentences", "quiz", "memoryHook"]:
        if key not in d:
            problems.append(f"{w}: missing {key}")
    q = d.get("quiz", [])
    if len(q) < 5:
        problems.append(f"{w}: only {len(q)} questions")
    for x in q:
        if x["type"] == "choice" and x["answer"] not in x["options"]:
            problems.append(f"{w}: answer '{x['answer']}' not among options")
        if x["type"] == "fill-in-the-blank" and "___" not in x["prompt"]:
            problems.append(f"{w}: fill-in prompt has no blank: {x['prompt']}")
    ids = [x["id"] for x in q]
    if len(set(ids)) != len(ids):
        problems.append(f"{w}: duplicate question ids")
    lessons.append(d)

a1 = [d for d in lessons if d.get("level") == "A1"]
a1.sort(key=lambda d: d["word"]["headword"].lower().lstrip("(").replace("sich) ", ""))
s = json.dumps(a1, ensure_ascii=False).replace("</", "<\\/")
html = open("/home/claude/lesson-template.html").read().replace("__LESSON_JSON__", s)
html = html.replace("<title>langweilig Lesson</title>", "<title>A1 Lessons</title>")
open("/home/claude/a1/a1-lessons.html", "w").write(html)

plan = json.load(open("/home/claude/a1/a1_plan.json"))
print(f"{len(lessons)} lessons ({len(a1)} A1), {sum(len(d['quiz']) for d in lessons)} questions")
print("problems:", problems or "none")
sys.exit(1 if problems else 0)
