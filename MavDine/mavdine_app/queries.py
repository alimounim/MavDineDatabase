"""Read the business queries straight from projectDBqueries.sql (one source of truth)."""
import re
from dataclasses import dataclass

from sqlscript import split_script


@dataclass
class Query:
    number: int
    title: str              # e.g. "Business Goal 6, added in Phase 1"
    english: str
    sql: str
    expected_before: str
    expected_after: str


HEADER = re.compile(r"^-- Query (\d+) \(([^)]*)\)\s*$", re.M)


def load_queries(path):
    text = open(path, encoding="utf-8").read()
    heads = list(HEADER.finditer(text))
    out = []
    for i, h in enumerate(heads):
        part = text[h.start(): heads[i + 1].start() if i + 1 < len(heads) else len(text)]
        lines = part.splitlines()[1:]
        english = []
        for l in lines:
            if l.startswith("-- ="):
                break
            english.append(re.sub(r"^--\s*(English:)?\s*", "", l))
        stmts = [s for k, s, _ in split_script(part) if k == "sql"]
        expected = dict(re.findall(r"/\* Expected output \((before update|after [^)]*)\):\s*\n(.*?)\*/", part, re.S))
        before = expected.get("before update", "")
        after = next((v for k, v in expected.items() if k.startswith("after")), "")
        out.append(Query(int(h.group(1)), h.group(2), " ".join(english).strip(),
                         stmts[0] if stmts else "", before.rstrip(), after.rstrip()))
    return out
