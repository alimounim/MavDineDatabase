"""Split SQL*Plus-style scripts (like projectDBcreate.sql) into statements a driver can run.

Handles:
  - normal SQL ending with ';'   (a ';' inside quotes or comments doesn't count)
  - PL/SQL blocks (CREATE TRIGGER / BEGIN / DECLARE ...) that end with a '/' line
  - SQL*Plus-only commands (SET, COLUMN, SPOOL, ...) which the database itself doesn't understand
  - '--' and '/* ... */' comments between statements
"""
import re

SQLPLUS_RE = re.compile(
    r"^(SET|COLUMN|COL|SPOOL|PROMPT|REM|REMARK|CLEAR|TTITLE|BTITLE|BREAK|COMPUTE|EXIT|QUIT|"
    r"WHENEVER|SHOW|DESC|DESCRIBE|START|DEFINE|UNDEFINE|PAUSE|ACCEPT|EXEC|EXECUTE)\b|^@",
    re.I)
PLSQL_RE = re.compile(
    r"^(CREATE\s+(OR\s+REPLACE\s+)?(EDITIONABLE\s+|NONEDITIONABLE\s+)?"
    r"(TRIGGER|PROCEDURE|FUNCTION|PACKAGE|TYPE)\b|DECLARE\b|BEGIN\b)", re.I)


def _find_terminator(line, state):
    """Return the index of a ';' that ends the statement, or -1.
    `state` carries quote / block-comment state across lines."""
    i, n = 0, len(line)
    while i < n:
        ch = line[i]
        if state["block"]:
            if line.startswith("*/", i):
                state["block"] = False
                i += 2
                continue
        elif state["quote"]:
            if ch == "'":
                if i + 1 < n and line[i + 1] == "'":   # '' = escaped quote
                    i += 2
                    continue
                state["quote"] = False
        else:
            if line.startswith("--", i):
                return -1
            if line.startswith("/*", i):
                state["block"] = True
                i += 2
                continue
            if ch == "'":
                state["quote"] = True
            elif ch == ";":
                return i
        i += 1
    return -1


def split_script(text):
    """Yield (kind, statement_text, line_number). kind is 'sql', 'plsql' or 'sqlplus'."""
    stmts = []
    mode, buf, start, in_comment = None, [], 0, False
    state = {"quote": False, "block": False}
    for no, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if mode is None:
            if in_comment:
                if "*/" in s:
                    in_comment = False
                continue
            if not s or s.startswith("--") or s == "/":
                continue
            if s.startswith("/*"):
                if "*/" not in s[2:]:
                    in_comment = True
                continue
            if SQLPLUS_RE.match(s):
                stmts.append(("sqlplus", s, no))
                continue
            mode = "plsql" if PLSQL_RE.match(s) else "sql"
            buf, start = [], no
            state = {"quote": False, "block": False}
        if mode == "plsql":
            if s == "/":
                stmts.append(("plsql", "\n".join(buf).rstrip(), start))
                mode = None
            else:
                buf.append(line)
            continue
        end = _find_terminator(line, state)
        if end >= 0:
            buf.append(line[:end])
            stmts.append(("sql", "\n".join(buf).strip(), start))
            mode = None
        else:
            buf.append(line)
    if mode and "".join(buf).strip():          # last statement without ';'
        stmts.append((mode, "\n".join(buf).strip(), start))
    return stmts


def first_keyword(sql):
    """First real word of a statement, skipping leading comments."""
    s = re.sub(r"^\s*(--[^\n]*\n|/\*.*?\*/\s*)*", "", sql, flags=re.S)
    m = re.match(r"\s*([A-Za-z]+)", s)
    return m.group(1).upper() if m else ""


def short(sql, width=90):
    """One-line preview of a statement for logs."""
    s = " ".join(re.sub(r"--[^\n]*", "", sql).split())
    return s if len(s) <= width else s[:width - 3] + "..."
