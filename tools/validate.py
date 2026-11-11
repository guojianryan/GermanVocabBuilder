"""Validate lesson files against schema/lesson.schema.json, plus checks a schema can't express.

Usage:  python3 validate.py lessons/a1/*.json
Exit code 1 if anything fails.
"""
import json, sys, os, re
from jsonschema import Draft202012Validator

HERE = os.path.dirname(os.path.abspath(__file__))
SCHEMA = os.path.join(HERE, "lesson.schema.json")
if not os.path.exists(SCHEMA):
    SCHEMA = os.path.join(HERE, "..", "schema", "lesson.schema.json")
validator = Draft202012Validator(json.load(open(SCHEMA)))


def slug(head):
    s = head.lower()
    for a, b in (("ä", "ae"), ("ö", "oe"), ("ü", "ue"), ("ß", "ss")):
        s = s.replace(a, b)
    return re.sub(r"[^a-z0-9]+", "-", s).strip("-")


def extra_checks(d, path):
    out = []
    for q in d.get("quiz", []):
        if q.get("type") == "choice" and q.get("answer") not in q.get("options", []):
            out.append(f"{q.get('id')}: answer is not one of the options")
    ids = [q.get("id") for q in d.get("quiz", [])]
    if len(ids) != len(set(ids)):
        out.append("quiz ids are not unique")
    for t in d.get("tables", []):
        for r in t.get("rows", []):
            if len(r.get("cells", [])) != len(t.get("columns", [])):
                out.append(f"table '{t.get('title')}', row '{r.get('label')}': cell count doesn't match columns")
            for c in r.get("cells", []):
                if c.count("|") > 2:
                    out.append(f"table cell has more than two pipes: {c}")
    expected = slug(d["word"]["headword"]) + ".json"
    if os.path.basename(path) != expected:
        out.append(f"file name should be {expected}")
    return out


failed = 0
files = sys.argv[1:]
for path in files:
    try:
        d = json.load(open(path, encoding="utf-8"))
    except Exception as e:
        print(f"FAIL {path}: not valid JSON ({e})"); failed += 1; continue
    errs = []
    for e in validator.iter_errors(d):
        where = '/'.join(map(str, e.absolute_path)) or '(root)'
        msg = f"has {len(e.instance)} items, needs at least {e.validator_value}" if e.validator == 'minItems' else e.message
        errs.append(f"{where}: {msg}")
    if not errs:
        errs = extra_checks(d, path)
    if errs:
        failed += 1
        print(f"FAIL {path}")
        for e in errs[:10]:
            print("   ", e)
print(f"{len(files) - failed}/{len(files)} lessons valid")
sys.exit(1 if failed else 0)
