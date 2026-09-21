#!/usr/bin/env python3
"""Link-check docs/doctor-qrh.md: every (#anchor) link must resolve, and the
Outline by Domain must match the real chapter/category/procedure structure.

Anchors are recomputed the way GitHub does it (lowercase, punctuation dropped,
spaces to hyphens, duplicate headings auto-numbered -1, -2, ...). Procedure
titles resolve via their <a id="..."></a> anchors.

Usage: scripts/check-qrh-links.py [path/to/doctor-qrh.md]
Exit status is 0 only if every check passes.
"""
import re
import sys
from pathlib import Path

path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "docs" / "doctor-qrh.md"
text = path.read_text(encoding="utf-8")
lines = text.split("\n")
failures = []


def slugify(t):
    return re.sub(r"[^\w \-]", "", t.lower()).replace(" ", "-")


TITLE = re.compile(r'^<a id="([^"]+)"></a>\*\*([A-Z][A-Z0-9 ]+)\*\*$')

# Headings (outside fences), GitHub duplicate numbering, chapter context.
heads, seen, in_fence, chapter = {}, {}, False, None
for ln in lines:
    if ln.startswith("```"):
        in_fence = not in_fence
        continue
    m = None if in_fence else re.match(r"^(#{1,6}) (.+)$", ln)
    if not m:
        continue
    level, title = len(m.group(1)), m.group(2)
    base = slugify(title)
    n = seen.get(base, 0)
    seen[base] = n + 1
    slug = base if n == 0 else f"{base}-{n}"
    if level == 2:
        chapter = title
    heads[slug] = (level, title, chapter)

# Procedure titles: anchor, and the (chapter, category) each really sits under.
anchors, real = {}, {}
in_fence, ch, cat = False, None, None
for ln in lines:
    if ln.startswith("```"):
        in_fence = not in_fence
        continue
    if in_fence:
        continue
    if ln.startswith("## "):
        ch = ln[3:]
    elif ln.startswith("### "):
        cat = ln[4:]
    else:
        m = TITLE.match(ln)
        if m:
            anchors[m.group(1)] = m.group(2)
            real[m.group(2)] = (ch, cat)
            if m.group(1) != slugify(m.group(2)):
                failures.append(f"anchor id != slug of title: {m.group(1)!r}")

for a in set(anchors) & set(heads):
    failures.append(f"anchor collides with a heading slug: {a}")

# Every in-doc link resolves, and its text matches its target.
links = re.findall(r"\[([^\]]+)\]\(#([^)]+)\)", text)
for label, a in links:
    if a not in heads and a not in anchors:
        failures.append(f"unresolved link: [{label}](#{a})")
        continue
    target = heads[a][1] if a in heads else anchors[a]
    if label != target and label not in ("Outline by Domain", "Procedure Index", "Deliberately Absent"):
        failures.append(f"link text {label!r} != target {target!r} (#{a})")

# Outline structure: chapter -> category -> procedure nesting is real.
try:
    o0, o1 = lines.index("## Outline by Domain"), lines.index("## GENERIC")
except ValueError:
    failures.append("missing '## Outline by Domain' or '## GENERIC'")
    o0 = o1 = 0
outline_titles, cur_ch, cur_cat = [], None, None
for ln in lines[o0:o1]:
    m = re.match(r"^( *)- \[([^\]]+)\]\(#([^)]+)\)$", ln)
    if not m:
        continue
    indent, label, a = len(m.group(1)), m.group(2), m.group(3)
    if indent == 0:
        cur_ch = label
        if a not in heads or heads[a][:2] != (2, label):
            failures.append(f"outline chapter does not match a ## heading: {label} (#{a})")
    elif indent == 2:
        cur_cat = label
        if a not in heads or heads[a] != (3, label, cur_ch):
            failures.append(f"outline category not under its chapter: {cur_ch} / {label} (#{a})")
    else:
        outline_titles.append(label)
        if real.get(label) != (cur_ch, cur_cat):
            failures.append(f"outline places {label} under {cur_ch} / {cur_cat}, real: {real.get(label)}")
if sorted(outline_titles) != sorted(real):
    failures.append("outline does not list every procedure title exactly once")

# Procedure Index: complete, sorted, one per line.
try:
    i0 = lines.index("## Procedure Index")
    index = [re.match(r"- \[([^\]]+)\]", ln).group(1) for ln in lines[i0:] if ln.startswith("- [")]
    if index != sorted(index) or sorted(index) != sorted(real):
        failures.append("index is not the complete A-Z list of procedure titles")
except ValueError:
    failures.append("missing '## Procedure Index'")

# PROC: cross-references resolve (blockquote line wraps folded first).
flat = re.sub(r"\n> ", " ", text)
for ref in sorted({m.strip() for m in re.findall(r"PROC: ([A-Z][A-Z0-9 ]+?)(?=[\.\)\n]| and PROC| \(|$)", flat)}):
    if ref not in real:
        failures.append(f"unresolved PROC: reference: {ref}")

print(f"{len(real)} procedures, {len(links)} links checked")
for f in failures:
    print("FAIL:", f)
print("OK" if not failures else f"{len(failures)} failure(s)")
sys.exit(1 if failures else 0)
