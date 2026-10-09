"""MavDine Manager: a small web interface for the MavDine Oracle database.

Run:  python app.py      then open http://127.0.0.1:5000
"""
import base64, json, os, time, webbrowser
from functools import wraps
from pathlib import Path

import oracledb
from flask import Flask, abort, flash, redirect, render_template, request, session, url_for

import db
from errors import friendly
from queries import load_queries
from sqlscript import first_keyword, short, split_script

HERE = Path(__file__).parent
CONFIG_FILE = HERE / "config.json"
DEFAULT_CONFIG = {
    "scripts_dir": "..",
    "instant_client_dir": None,
    "profiles": {
        "omega": {"label": "Omega (UTA Oracle)", "host": "", "port": 1522, "service": "", "user": "",
                  "tcps": True},
        "local": {"label": "Local practice copy (Docker)", "host": "localhost", "port": 1521,
                  "service": "FREEPDB1", "user": "mavdine"},
    },
}
MAX_ROWS = 2000


def load_config():
    if not CONFIG_FILE.exists():
        CONFIG_FILE.write_text(json.dumps(DEFAULT_CONFIG, indent=2))
    return json.loads(CONFIG_FILE.read_text())


CONFIG = load_config()
if CONFIG.get("instant_client_dir"):
    oracledb.init_oracle_client(lib_dir=CONFIG["instant_client_dir"])   # thick mode for old databases
SCRIPTS_DIR = (HERE / CONFIG.get("scripts_dir", "..")).resolve()

app = Flask(__name__)
app.secret_key = os.urandom(24)


# ----------------------------------------------------------------------------- helpers

def current():
    return db.SESSIONS.get(session.get("token"))


def login_required(view):
    @wraps(view)
    def wrapper(*a, **kw):
        if not current():
            return redirect(url_for("login"))
        return view(*a, **kw)
    return wrapper


@app.context_processor
def inject():
    s = current()
    schema = None
    if s:
        try:
            schema = s.schema()
        except oracledb.Error:
            schema = None
    return {"sess": s, "schema": schema, "show": db.show}


def get_table(label):
    t = current().schema().tables.get(label)
    if not t:
        abort(404)
    return t


def encode_key(t, row):
    vals = [db.key_str(t.col(c), row[c]) for c in t.pk]
    return base64.urlsafe_b64encode(json.dumps(vals).encode()).decode()


def decode_key(t, k):
    try:
        vals = json.loads(base64.urlsafe_b64decode(k.encode()))
        return [db.to_db(t.col(c), v) for c, v in zip(t.pk, vals)]
    except Exception:
        abort(400)


def pk_where(t):
    return " AND ".join(f"{c} = :k{i}" for i, c in enumerate(t.pk))


def pk_binds(vals):
    return {f"k{i}": v for i, v in enumerate(vals)}


def fetch_dicts(cur, sql, binds=None, limit=None):
    cur.execute(sql, binds or {})
    cols = [d[0] for d in cur.description]
    rows = cur.fetchmany(limit) if limit else cur.fetchall()
    return cols, [dict(zip(cols, r)) for r in rows]


def fk_options(cur, schema, fk):
    """[(value, label)] for a foreign key dropdown. value = parent key columns joined by '|'."""
    parent = schema.tables[fk.ref_table]
    sql = db.OPTION_SQL.get(parent.label)
    rows = None
    if sql:
        try:
            cols, rows = fetch_dicts(cur, sql.format(P=db.PREFIX))
            if not all(c in cols for c in fk.ref_columns):
                rows = None
        except oracledb.Error:
            rows = None
    if rows is None:
        cols = ", ".join(fk.ref_columns)
        _, rows = fetch_dicts(cur, f"SELECT {cols} FROM {parent.name} ORDER BY {cols}")
    out = []
    for r in rows:
        value = "|".join(db.key_str(parent.col(c), r[c]) for c in fk.ref_columns)
        out.append((value, r.get("LABEL") or value.replace("|", " / ")))
    return out


def build_fields(t, schema, cur, row=None, editing=False):
    """Form fields for a table. Each foreign key becomes ONE dropdown, even when it has 2 columns."""
    fields, done = [], set()
    for c in t.columns:
        if c.name in done:
            continue
        fk = t.fk_for(c.name)
        in_pk = c.name in t.pk
        if fk and all(t.fk_for(x) is fk for x in fk.columns):
            done.update(fk.columns)
            cols = [t.col(x) for x in fk.columns]
            value = "|".join(db.key_str(x, row.get(x.name)) for x in cols) if row else ""
            fields.append({
                "kind": "fk", "name": "fk__" + fk.name, "fk": fk,
                "label": " + ".join(fk.columns), "ref": fk.ref_table,
                "type": " + ".join(x.type_label for x in cols),
                "options": fk_options(cur, schema, fk), "value": value if value.strip("|") else "",
                "required": any(not x.nullable for x in cols),
                "readonly": editing and any(x in t.pk for x in fk.columns),
                "pk": any(x in t.pk for x in fk.columns), "checks": [],
            })
            continue
        done.add(c.name)
        fields.append({
            "kind": "select" if c.options else c.kind, "name": c.name, "col": c, "label": c.name,
            "type": c.type_label, "options": [(o, o) for o in c.options],
            "value": db.to_form(c, row.get(c.name)) if row else "",
            "required": not c.nullable, "readonly": editing and in_pk, "pk": in_pk,
            "checks": [x for x in c.checks if not c.options],
        })
    return fields


def read_form(t, fields, form):
    """Form -> {column: python value}. Raises ValueError on bad input."""
    values = {}
    for f in fields:
        if f["kind"] == "fk":
            fk = f["fk"]
            raw = form.get(f["name"], "")
            parts = raw.split("|") if raw else [""] * len(fk.columns)
            for col, v in zip(fk.columns, parts):
                values[col] = db.to_db(t.col(col), v)
        else:
            values[f["name"]] = db.to_db(f["col"], form.get(f["name"]))
    return values


def deletion_impact(cur, schema, t, rows, depth=0):
    """What else a delete touches: cascaded child rows (recursively) and blocking child rows."""
    nodes = []
    if depth > 6 or not rows:
        return nodes
    for child, fk in schema.children_of(t.label):
        found, seen = [], set()
        for r in rows[:300]:
            where = " AND ".join(f"{c} = :v{i}" for i, c in enumerate(fk.columns))
            binds = {f"v{i}": r[rc] for i, rc in enumerate(fk.ref_columns)}
            _, crs = fetch_dicts(cur, f"SELECT * FROM {child.name} WHERE {where}", binds)
            for cr in crs:
                key = tuple(db.key_str(child.col(c), cr[c]) for c in (child.pk or list(cr)))
                if key not in seen:
                    seen.add(key)
                    found.append(cr)
        if found:
            nodes.append({"table": child.label, "fk": fk.name, "cascade": fk.cascade, "count": len(found),
                          "children": deletion_impact(cur, schema, child, found, depth + 1)
                          if fk.cascade else []})
    return nodes


def any_blocked(nodes):
    return any((not n["cascade"]) or any_blocked(n["children"]) for n in nodes)


def run_statements(conn, stmts, stop_on_error=False, max_rows=MAX_ROWS):
    """Execute split statements; return a log entry per statement."""
    cur = conn.cursor()
    log = []
    for kind, sql, line in stmts:
        entry = {"kind": kind, "line": line, "preview": short(sql), "sql": sql, "ok": True,
                 "msg": "", "detail": "", "cols": None, "rows": None, "rowcount": None, "ms": 0}
        if kind == "sqlplus":
            entry["msg"] = "SQL*Plus command, skipped (only SQL*Plus understands it)"
            entry["skipped"] = True
            log.append(entry)
            continue
        t0 = time.perf_counter()
        try:
            cur.execute(sql)
            kw = first_keyword(sql)
            if cur.description:
                entry["cols"] = [d[0] for d in cur.description]
                rows = cur.fetchmany(max_rows + 1)
                entry["truncated"] = len(rows) > max_rows
                entry["rows"] = rows[:max_rows]
                entry["msg"] = f"{len(entry['rows'])} row(s)" + (" (first %d shown)" % max_rows
                                                                    if entry["truncated"] else "")
            elif kw in ("INSERT", "UPDATE", "DELETE", "MERGE"):
                entry["rowcount"] = cur.rowcount
                entry["msg"] = f"{cur.rowcount} row(s) {kw.lower()}{'d' if kw.endswith('E') else 'ed'}"
            elif kw == "COMMIT":
                entry["msg"] = "Committed"
            elif kw == "ROLLBACK":
                entry["msg"] = "Rolled back"
            else:
                entry["msg"] = "Done"
        except oracledb.Error as e:
            entry["ok"] = False
            entry["msg"], entry["detail"] = friendly(e, current().schema() if current() else None)
            if "ORA-00942" in entry["detail"] and first_keyword(sql) == "DROP":
                entry["warn"] = True
                entry["msg"] = "Table didn't exist (normal on a fresh database)"
        entry["ms"] = round((time.perf_counter() - t0) * 1000)
        log.append(entry)
        if stop_on_error and not entry["ok"]:
            break
    return log


# ----------------------------------------------------------------------------- login

@app.route("/login", methods=["GET", "POST"])
def login():
    profiles = CONFIG["profiles"]
    chosen = request.values.get("profile") or ("omega" if profiles["omega"]["host"] else "local")
    p = dict(profiles.get(chosen, profiles["local"]))
    error = detail = ""
    if request.method == "POST":
        for k in ("host", "port", "service", "user"):
            p[k] = request.form.get(k, "").strip()
        p["tcps"] = bool(request.form.get("tcps"))
        try:
            token = db.open_session(profile=p.get("label", chosen), user=p["user"], host=p["host"],
                                    port=int(p["port"] or 1521), service=p["service"],
                                    password=request.form.get("password", ""), tcps=p["tcps"])
        except (oracledb.Error, ValueError) as e:
            error, detail = friendly(e)
        else:
            old = session.get("token")
            if old:
                db.close_session(old)
            session["token"] = token
            if request.form.get("remember"):
                profiles[chosen].update({k: p[k] for k in ("host", "service", "user", "tcps")})
                profiles[chosen]["port"] = int(p["port"] or 1521)
                CONFIG_FILE.write_text(json.dumps(CONFIG, indent=2))
            return redirect(url_for("dashboard"))
    return render_template("login.html", profiles=profiles, chosen=chosen, p=p, error=error, detail=detail)


@app.route("/logout")
def logout():
    db.close_session(session.pop("token", None))
    return redirect(url_for("login"))


# ----------------------------------------------------------------------------- dashboard

@app.route("/")
@login_required
def dashboard():
    s = current()
    schema = s.schema(refresh=request.args.get("refresh") == "1")
    counts = {}
    with s.conn() as conn:
        cur = conn.cursor()
        for t in schema.ordered():
            cur.execute(f"SELECT COUNT(*) FROM {t.name}")
            counts[t.label] = cur.fetchone()[0]
    return render_template("dashboard.html", counts=counts)


# ----------------------------------------------------------------------------- tables

@app.route("/t/<label>")
@login_required
def table_view(label):
    s = current()
    schema = s.schema()
    t = get_table(label)
    with s.conn() as conn:
        cur = conn.cursor()
        order = ", ".join(t.pk) or "1"
        cols, rows = fetch_dicts(cur, f"SELECT * FROM {t.name} ORDER BY {order}")
        fk_labels = {}
        for fk in t.fks:
            fk_labels[fk.name] = dict(fk_options(cur, schema, fk))
    hints = {}          # column -> fk shown under it (the last column of each fk)
    for fk in t.fks:
        hints[fk.columns[-1]] = fk
    out = []
    for r in rows:
        labels = {}
        for col, fk in hints.items():
            key = "|".join(db.key_str(t.col(c), r[c]) for c in fk.columns)
            labels[col] = fk_labels[fk.name].get(key, "")
        out.append({"key": encode_key(t, r) if t.pk else None, "values": r, "labels": labels})
    editable = bool(set(c.name for c in t.columns) - set(t.pk))
    return render_template("table.html", t=t, cols=cols, rows=out, editable=editable,
                           hl=request.args.get("hl"))


@app.route("/t/<label>/new", methods=["GET", "POST"])
@login_required
def row_new(label):
    s = current()
    schema = s.schema()
    t = get_table(label)
    error = detail = ""
    with s.conn() as conn:
        cur = conn.cursor()
        row = None
        if request.method == "POST":
            fields = build_fields(t, schema, cur)
            try:
                values = read_form(t, fields, request.form)
                cols = list(values)
                cur.execute(f"INSERT INTO {t.name} ({', '.join(cols)}) VALUES "
                            f"({', '.join(':' + str(i + 1) for i in range(len(cols)))})",
                            [values[c] for c in cols])
                conn.commit()
                flash(f"Added a new row to {t.label}.", "ok")
                return redirect(url_for("table_view", label=label, hl=encode_key(t, values)))
            except (oracledb.Error, ValueError) as e:
                conn.rollback()
                error, detail = friendly(e, schema)
                row = {}
                for f in fields:
                    if f["kind"] == "fk":
                        for col, v in zip(f["fk"].columns, (request.form.get(f["name"]) or "").split("|")):
                            row[col] = v
                    else:
                        row[f["name"]] = request.form.get(f["name"])
        fields = build_fields(t, schema, cur, row)
        if row:     # keep what the user typed (strings) after an error
            for f in fields:
                f["value"] = request.form.get(f["name"], "")
    return render_template("form.html", t=t, fields=fields, mode="new", error=error, detail=detail,
                           notes=db.TRIGGER_NOTES.get(t.label, []))


@app.route("/t/<label>/edit", methods=["GET", "POST"])
@login_required
def row_edit(label):
    s = current()
    schema = s.schema()
    t = get_table(label)
    k = request.args.get("k", "")
    keyvals = decode_key(t, k)
    error = detail = ""
    with s.conn() as conn:
        cur = conn.cursor()
        _, found = fetch_dicts(cur, f"SELECT * FROM {t.name} WHERE {pk_where(t)}", pk_binds(keyvals))
        if not found:
            flash("That row no longer exists.", "err")
            return redirect(url_for("table_view", label=label))
        row = found[0]
        fields = build_fields(t, schema, cur, row, editing=True)
        if request.method == "POST":
            try:
                values = read_form(t, [f for f in fields if not f["readonly"]], request.form)
                sets = [c for c in values if c not in t.pk]
                binds = {f"s{i}": values[c] for i, c in enumerate(sets)}
                binds.update(pk_binds(keyvals))
                cur.execute(f"UPDATE {t.name} SET {', '.join(f'{c} = :s{i}' for i, c in enumerate(sets))} "
                            f"WHERE {pk_where(t)}", binds)
                conn.commit()
                flash(f"Saved changes to {t.label}.", "ok")
                return redirect(url_for("table_view", label=label, hl=k))
            except (oracledb.Error, ValueError) as e:
                conn.rollback()
                error, detail = friendly(e, schema)
                for f in fields:
                    if not f["readonly"]:
                        f["value"] = request.form.get(f["name"], "")
    return render_template("form.html", t=t, fields=fields, mode="edit", error=error, detail=detail,
                           notes=db.TRIGGER_NOTES.get(t.label, []), k=k)


@app.route("/t/<label>/delete", methods=["GET", "POST"])
@login_required
def row_delete(label):
    s = current()
    schema = s.schema()
    t = get_table(label)
    k = request.args.get("k", "")
    keyvals = decode_key(t, k)
    with s.conn() as conn:
        cur = conn.cursor()
        _, found = fetch_dicts(cur, f"SELECT * FROM {t.name} WHERE {pk_where(t)}", pk_binds(keyvals))
        if not found:
            flash("That row no longer exists.", "err")
            return redirect(url_for("table_view", label=label))
        if request.method == "POST":
            try:
                cur.execute(f"DELETE FROM {t.name} WHERE {pk_where(t)}", pk_binds(keyvals))
                conn.commit()
                flash(f"Deleted 1 row from {t.label} (plus any cascaded child rows).", "ok")
                return redirect(url_for("table_view", label=label))
            except oracledb.Error as e:
                conn.rollback()
                msg, detail = friendly(e, schema)
                flash(msg, "err")
                return redirect(url_for("row_delete", label=label, k=k))
        impact = deletion_impact(cur, schema, t, found)
    return render_template("delete.html", t=t, row=found[0], impact=impact, blocked=any_blocked(impact), k=k)


# ----------------------------------------------------------------------------- business queries

def all_queries():
    path = SCRIPTS_DIR / "projectDBqueries.sql"
    return load_queries(path) if path.exists() else []


@app.route("/queries")
@login_required
def queries_list():
    return render_template("queries.html", queries=all_queries())


@app.route("/queries/<int:n>")
@login_required
def query_run(n):
    q = next((q for q in all_queries() if q.number == n), None)
    if not q:
        abort(404)
    with current().conn() as conn:
        result = run_statements(conn, [("sql", q.sql, 0)])[0]
    return render_template("query.html", q=q, r=result, queries=all_queries())


# ----------------------------------------------------------------------------- SQL console

@app.route("/sql", methods=["GET", "POST"])
@login_required
def sql_console():
    text = request.form.get("sql", request.args.get("sql", ""))
    commit = request.form.get("commit", "on" if request.method == "GET" else "") == "on"
    log = None
    if request.method == "POST" and text.strip():
        stmts = split_script(text)
        with current().conn() as conn:
            log = run_statements(conn, stmts, stop_on_error=True)
            if all(e["ok"] for e in log):
                conn.commit() if commit else conn.rollback()
            else:
                conn.rollback()
        if any(first_keyword(e["sql"]) in ("CREATE", "DROP", "ALTER") for e in log):
            current().schema(refresh=True)
    return render_template("sql.html", text=text, log=log, commit=commit)


# ----------------------------------------------------------------------------- scripts

SCRIPT_ORDER = ["projectDBdrop.sql", "projectDBcreate.sql", "projectDBinsert.sql",
                "projectDBupdate.sql", "projectDBqueries.sql"]
SCRIPT_INFO = {
    "projectDBdrop.sql": "Drops all 12 tables (children first).",
    "projectDBcreate.sql": "Creates the 12 tables, their constraints and the 5 triggers.",
    "projectDBinsert.sql": "Fills every table with the sample data (741 rows).",
    "projectDBupdate.sql": "The inserts/updates/deletes that change the query results.",
    "projectDBqueries.sql": "Runs the 7 business queries.",
}


@app.route("/scripts", methods=["GET", "POST"])
@login_required
def scripts():
    available = [f for f in SCRIPT_ORDER if (SCRIPTS_DIR / f).exists()]
    log, ran = None, None
    if request.method == "POST":
        which = request.form.get("script")
        if "omega" in current().profile.lower() and not request.form.get("confirm"):
            flash("Tick the confirmation box: this changes the real Omega database.", "err")
            return redirect(url_for("scripts"))
        files = ["projectDBdrop.sql", "projectDBcreate.sql", "projectDBinsert.sql"] if which == "__reset__" \
            else [which] if which in available else []
        log = []
        with current().conn() as conn:
            for f in files:
                stmts = split_script((SCRIPTS_DIR / f).read_text(encoding="utf-8"))
                for e in run_statements(conn, stmts, max_rows=200):
                    e["file"] = f
                    log.append(e)
            conn.commit()
        current().schema(refresh=True)
        ran = "Reset (drop + create + insert)" if which == "__reset__" else which
    summary = None
    if log is not None:
        summary = {"ok": sum(1 for e in log if e["ok"] and not e.get("skipped")),
                   "err": sum(1 for e in log if not e["ok"] and not e.get("warn")),
                   "warn": sum(1 for e in log if e.get("warn")),
                   "skipped": sum(1 for e in log if e.get("skipped"))}
    return render_template("scripts.html", available=available, info=SCRIPT_INFO, log=log, ran=ran,
                           summary=summary, folder=str(SCRIPTS_DIR))


@app.errorhandler(oracledb.Error)
def db_error(e):
    msg, detail = friendly(e, None)
    return render_template("error.html", msg=msg, detail=detail), 500


if __name__ == "__main__":
    if not os.environ.get("WERKZEUG_RUN_MAIN"):
        webbrowser.open("http://127.0.0.1:5000")
    app.run(host="127.0.0.1", port=5000, debug=False, threaded=True)
