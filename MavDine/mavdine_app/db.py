"""Oracle connections + reading the MavDine schema from Oracle's data dictionary.

The schema (columns, types, primary/foreign keys, CHECK rules) is read live from
USER_TAB_COLUMNS / USER_CONSTRAINTS, so the app always matches what is really in the database.
"""
import re, secrets, threading
from dataclasses import dataclass, field
from datetime import date, datetime
from decimal import Decimal, InvalidOperation

import oracledb

oracledb.defaults.fetch_decimals = True          # NUMBER -> Decimal (no 3.8500000001 surprises)

PREFIX = "DASC5306_FALL26_S001_T4_"

# Nice names, levels and descriptions for the known tables (anything else still works).
META = {
    "USER":            ("User", 0, "Every registered user (student)."),
    "MERCHANT":        ("Merchant", 0, "Every registered merchant (grocery company)."),
    "HOMECOOK":        ("Homecook", 1, "Users who are home cooks."),
    "CHEF":            ("Chef", 1, "Users who are chefs."),
    "CAMPAIGN":        ("Campaign", 1, "Ad campaigns run by merchants."),
    "COOKBOOK":        ("Cookbook", 2, "Cookbooks owned by chefs."),
    "FOLLOW_UNFOLLOW": ("Follow_Unfollow", 2, "Which homecook follows which chef."),
    "SUBSCRIBE":       ("Subscribe", 3, "Which homecook subscribes to which cookbook."),
    "RECIPE":          ("Recipe", 3, "Recipes, numbered from 1 inside each cookbook."),
    "LIKE_DISLIKE":    ("Like_Dislike", 4, "A homecook's single reaction to a recipe."),
    "READ":            ("Read", 4, "Each reading session of a recipe by a homecook."),
    "DISPLAY_ON":      ("Display_On", 4, "Which campaign (ad) is shown on which recipe, and its cost."),
}

# Business rules enforced by triggers (from projectDBcreate.sql), shown on the forms.
TRIGGER_NOTES = {
    "User": ["User must be at least 18 years old (T1).", "Enrollment date can't be in the future (T1)."],
    "Cookbook": ["Creation date can't be in the future (T2)."],
    "Recipe": ["Publish date can't be in the future, or before the cookbook was created (T3)."],
    "Read": ["Start time can't be in the future, or before the recipe was published (T4)."],
    "Like_Dislike": ["The homecook must have read the recipe at least once (T5)."],
}

# How to show a row of a parent table inside a dropdown. Columns must use the real key names;
# the text shown is the LABEL column.
OPTION_SQL = {
    "User": "SELECT MAV_ID, MAV_ID || ' - ' || first_name || ' ' || last_name AS LABEL "
            "FROM {P}USER ORDER BY MAV_ID",
    "Homecook": "SELECT h.HOMECOOK_MAV_ID, h.HOMECOOK_MAV_ID || ' - ' || u.first_name || ' ' || u.last_name AS LABEL "
                "FROM {P}HOMECOOK h JOIN {P}USER u ON u.MAV_ID = h.HOMECOOK_MAV_ID ORDER BY 1",
    "Chef": "SELECT c.CHEF_MAV_ID, c.CHEF_MAV_ID || ' - ' || u.first_name || ' ' || u.last_name "
            "|| ' (chef ' || c.chef_id || ')' AS LABEL "
            "FROM {P}CHEF c JOIN {P}USER u ON u.MAV_ID = c.CHEF_MAV_ID ORDER BY 1",
    "Merchant": "SELECT REGISTRATION_NUMBER, REGISTRATION_NUMBER || ' - ' || merchant_name AS LABEL "
                "FROM {P}MERCHANT ORDER BY 1",
    "Campaign": "SELECT c.MERCHANT_REGISTRATION_NUMBER, c.CAMPAIGN_NUMBER, m.merchant_name || ' #' "
                "|| c.CAMPAIGN_NUMBER || ' - ' || c.advertised_grocery_item_name AS LABEL "
                "FROM {P}CAMPAIGN c JOIN {P}MERCHANT m ON m.REGISTRATION_NUMBER = c.MERCHANT_REGISTRATION_NUMBER "
                "ORDER BY m.merchant_name, c.CAMPAIGN_NUMBER",
    "Cookbook": "SELECT COOKBOOK_ID, COOKBOOK_ID || ' - ' || cookbook_name AS LABEL FROM {P}COOKBOOK ORDER BY 1",
    "Recipe": "SELECT r.COOKBOOK_ID, r.RECIPE_NUMBER, 'Cookbook ' || r.COOKBOOK_ID || ' #' || r.RECIPE_NUMBER "
              "|| ' - ' || r.title AS LABEL "
              "FROM {P}RECIPE r ORDER BY r.COOKBOOK_ID, r.RECIPE_NUMBER",
}


# ----------------------------------------------------------------------------- schema model

@dataclass
class Column:
    name: str
    data_type: str          # VARCHAR2, CHAR, NUMBER, DATE, TIMESTAMP(6) ...
    length: int
    precision: int | None
    scale: int | None
    nullable: bool
    options: list = field(default_factory=list)     # from CHECK (col IN (...))
    checks: list = field(default_factory=list)      # CHECK conditions on this column only

    @property
    def kind(self):
        t = self.data_type
        if t.startswith("TIMESTAMP"):
            return "timestamp"
        if t == "DATE":
            return "date"
        if t in ("NUMBER", "FLOAT", "INTEGER", "BINARY_DOUBLE", "BINARY_FLOAT"):
            return "number"
        return "text"

    @property
    def type_label(self):
        t = self.data_type
        if t in ("VARCHAR2", "CHAR", "NVARCHAR2", "NCHAR"):
            return f"{t}({self.length})"
        if t == "NUMBER" and self.precision:
            return f"NUMBER({self.precision},{self.scale})" if self.scale else f"NUMBER({self.precision})"
        return t

    @property
    def step(self):
        return "1" if not self.scale else str(Decimal(1).scaleb(-self.scale))


@dataclass
class ForeignKey:
    name: str
    columns: list           # child columns, in order
    ref_table: str          # parent table label
    ref_columns: list       # parent columns, same order
    cascade: bool


@dataclass
class Table:
    name: str               # real Oracle name
    label: str
    level: int
    description: str
    columns: list
    pk: list = field(default_factory=list)
    uniques: list = field(default_factory=list)
    fks: list = field(default_factory=list)
    table_checks: list = field(default_factory=list)   # CHECKs over several columns
    triggers: list = field(default_factory=list)

    def col(self, name):
        return next(c for c in self.columns if c.name == name)

    def fk_for(self, colname):
        return next((f for f in self.fks if colname in f.columns), None)


@dataclass
class Constraint:
    name: str
    type: str               # P, U, R, C
    table: str              # label
    columns: list
    condition: str | None


class Schema:
    def __init__(self, tables, constraints):
        self.tables = tables                    # label -> Table
        self.constraints = constraints          # constraint name -> Constraint
        self.by_name = {t.name: t for t in tables.values()}

    def ordered(self):
        return sorted(self.tables.values(), key=lambda t: (t.level, t.label))

    def children_of(self, label):
        """(child table, fk) for every foreign key that points at `label`."""
        return [(t, f) for t in self.tables.values() for f in t.fks if f.ref_table == label]


def _label_for(name):
    suffix = name[len(PREFIX):] if name.startswith(PREFIX) else name
    if suffix in META:
        return META[suffix]
    return (suffix.title(), 9, "")


def load_schema(conn):
    cur = conn.cursor()
    cur.execute("""
        SELECT table_name, column_name, data_type, char_length, data_precision, data_scale, nullable
        FROM   user_tab_columns
        WHERE  table_name LIKE :p ESCAPE '\\'
        AND    table_name IN (SELECT table_name FROM user_tables)
        ORDER  BY table_name, column_id""", p=PREFIX.replace("_", "\\_") + "%")
    tables = {}
    for tname, cname, dtype, clen, prec, scale, nullable in cur:
        label, level, desc = _label_for(tname)
        t = tables.setdefault(tname, Table(tname, label, level, desc, []))
        t.columns.append(Column(cname, dtype, clen or 0, prec, scale, nullable == "Y"))

    cur.execute("""
        SELECT c.constraint_name, c.constraint_type, c.table_name, c.r_constraint_name,
               c.delete_rule, cc.column_name
        FROM   user_constraints c
        LEFT   JOIN user_cons_columns cc ON cc.constraint_name = c.constraint_name
        WHERE  c.table_name LIKE :p ESCAPE '\\'
        ORDER  BY c.constraint_name, cc.position""", p=PREFIX.replace("_", "\\_") + "%")
    raw = {}
    for cname, ctype, tname, rname, drule, col in cur:
        r = raw.setdefault(cname, {"type": ctype, "table": tname, "r": rname, "rule": drule, "cols": []})
        if col:
            r["cols"].append(col)

    # LONG column, so it gets its own query
    cur.execute("""SELECT constraint_name, search_condition FROM user_constraints
                   WHERE constraint_type = 'C' AND table_name LIKE :p ESCAPE '\\'""",
                p=PREFIX.replace("_", "\\_") + "%")
    conds = {n: (c or "").strip() for n, c in cur}

    cur.execute("""SELECT trigger_name, table_name, triggering_event FROM user_triggers
                   WHERE table_name LIKE :p ESCAPE '\\' ORDER BY trigger_name""",
                p=PREFIX.replace("_", "\\_") + "%")
    for trg, tname, event in cur:
        if tname in tables:
            tables[tname].triggers.append(f"{trg} ({event.strip()})")

    constraints = {}
    for cname, r in raw.items():
        t = tables.get(r["table"])
        if not t:
            continue
        cond = conds.get(cname)
        constraints[cname] = Constraint(cname, r["type"], t.label, r["cols"], cond)
        if r["type"] == "P":
            t.pk = r["cols"]
        elif r["type"] == "U":
            t.uniques.append(r["cols"])
        elif r["type"] == "R":
            parent = raw.get(r["r"])
            if parent and parent["table"] in tables:
                t.fks.append(ForeignKey(cname, r["cols"], tables[parent["table"]].label,
                                        parent["cols"], r["rule"] == "CASCADE"))
        elif r["type"] == "C" and cond:
            if re.fullmatch(r'"?\w+"?\s+IS\s+NOT\s+NULL', cond, re.I):
                continue                                    # plain NOT NULL
            m = re.fullmatch(r'\s*"?(\w+)"?\s+IN\s*\((.*)\)\s*', cond, re.I | re.S)
            if m and len(r["cols"]) == 1:
                t.col(r["cols"][0]).options = [v.replace("''", "'")
                                               for v in re.findall(r"'((?:[^']|'')*)'", m.group(2))]
            if len(r["cols"]) == 1:
                t.col(r["cols"][0]).checks.append(" ".join(cond.split()))
            else:
                t.table_checks.append(" ".join(cond.split()))

    return Schema({t.label: t for t in tables.values()}, constraints)


# ----------------------------------------------------------------------------- values

def to_db(col, raw):
    """Turn a form string into the Python value Oracle expects for this column."""
    if raw is None:
        return None
    raw = raw.strip()
    if raw == "":
        return None
    k = col.kind
    if k == "number":
        try:
            return Decimal(raw)
        except InvalidOperation:
            raise ValueError(f"{col.name}: '{raw}' is not a number")
    if k == "date":
        try:
            return datetime.fromisoformat(raw[:10])
        except ValueError:
            raise ValueError(f"{col.name}: '{raw}' is not a date (YYYY-MM-DD)")
    if k == "timestamp":
        try:
            return datetime.fromisoformat(raw.replace(" ", "T"))
        except ValueError:
            raise ValueError(f"{col.name}: '{raw}' is not a date and time")
    return raw


def to_form(col, value):
    """Value as an HTML <input> wants it."""
    if value is None:
        return ""
    if col.kind == "date" and isinstance(value, (date, datetime)):
        return value.strftime("%Y-%m-%d")
    if col.kind == "timestamp" and isinstance(value, datetime):
        return value.strftime("%Y-%m-%dT%H:%M:%S")
    return str(value).rstrip() if col.data_type == "CHAR" else str(value)


def show(value):
    """Value as text in a results grid."""
    if value is None:
        return ""
    if isinstance(value, datetime):
        if value.hour == value.minute == value.second == value.microsecond == 0:
            return value.strftime("%Y-%m-%d")
        return value.strftime("%Y-%m-%d %H:%M:%S")
    if isinstance(value, date):
        return value.strftime("%Y-%m-%d")
    if isinstance(value, Decimal):
        return format(value.normalize(), "f") if value == value.to_integral() else str(value)
    if isinstance(value, oracledb.LOB):
        return value.read()
    return str(value)


def key_str(col, value):
    """Stable text form of a key value (used in URLs and dropdown values)."""
    if value is None:
        return ""
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, Decimal):
        return show(value)
    return str(value).rstrip() if col.data_type == "CHAR" else str(value)


# ----------------------------------------------------------------------------- sessions

class Session:
    """One logged-in connection (a small pool, so the web server's threads can share it)."""

    def __init__(self, profile, user, host, port, service, password, tcps=False):
        self.profile, self.user, self.host, self.port, self.service = profile, user, host, port, service
        self.dsn = f"{host}:{port}/{service}"
        # TCPS = encrypted connection (needed for Oracle cloud databases like UTA's oracleacademicdb)
        dsn = f"tcps://{self.dsn}?ssl_server_dn_match=true&retry_count=3&retry_delay=2" if tcps else self.dsn
        self.pool = oracledb.create_pool(user=user, password=password, dsn=dsn,
                                         min=1, max=4, increment=1)
        self._schema = None
        self._lock = threading.Lock()

    def conn(self):
        return self.pool.acquire()

    def schema(self, refresh=False):
        with self._lock:
            if refresh or self._schema is None:
                with self.conn() as c:
                    self._schema = load_schema(c)
            return self._schema

    def close(self):
        try:
            self.pool.close(force=True)
        except oracledb.Error:
            pass


SESSIONS = {}


def open_session(**kw):
    s = Session(**kw)
    with s.conn() as c:                       # fail fast if the login is wrong
        c.ping()
    token = secrets.token_urlsafe(24)
    SESSIONS[token] = s
    return token


def close_session(token):
    s = SESSIONS.pop(token, None)
    if s:
        s.close()
