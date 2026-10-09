"""Turn Oracle errors into plain-English messages (the raw ORA- text is kept as detail)."""
import re

import oracledb


def friendly(exc, schema=None):
    """Return (message, detail) for any exception."""
    if not isinstance(exc, oracledb.Error):
        return str(exc), ""
    err = exc.args[0] if exc.args else None
    raw = getattr(err, "message", str(exc)).strip()
    code = getattr(err, "code", 0) or 0
    first = raw.splitlines()[0]

    m = re.search(r"\(([A-Z0-9_$#]+)\.([A-Z0-9_$#]+)\)", first)
    cons = schema.constraints.get(m.group(2)) if (schema and m) else None
    cname = m.group(2) if m else ""

    if 20000 <= code <= 20999:                          # RAISE_APPLICATION_ERROR in a trigger
        text = re.sub(r"^ORA-\d+:\s*", "", first)
        return f"Business rule: {text}", raw
    if code == 1:
        cols = ", ".join(cons.columns) if cons else cname
        what = "primary key" if cons and cons.type == "P" else "unique value"
        return f"Duplicate {what}: another row in {cons.table if cons else 'this table'} already has this {cols}.", raw
    if code == 2290:
        rule = cons.condition if cons and cons.condition else cname
        return f"Value not allowed. The rule {cname} requires: {rule}", raw
    if code == 2291:
        if cons and schema:
            t = schema.tables.get(cons.table)
            fk = next((f for f in t.fks if f.name == cname), None) if t else None
            if fk:
                return (f"{', '.join(fk.columns)} must match an existing row in {fk.ref_table} "
                        f"(foreign key {cname}). Add that {fk.ref_table} first."), raw
        return f"The referenced parent row doesn't exist (foreign key {cname}).", raw
    if code == 2292:
        if cons:
            return (f"Can't delete: rows in {cons.table} still point to this row, and foreign key "
                    f"{cname} has no ON DELETE CASCADE. Delete or change those {cons.table} rows first."), raw
        return f"Can't delete: child rows still reference this row ({cname}).", raw
    if code in (1400, 1407):
        col = re.findall(r'"([^"]+)"', first)
        return f"{col[-1] if col else 'A required column'} can't be empty.", raw
    if code == 12899:
        col = re.findall(r'"([^"]+)"', first)
        size = re.search(r"\(actual: (\d+), maximum: (\d+)\)", first)
        extra = f" ({size.group(1)} characters, max {size.group(2)})" if size else ""
        return f"Value too long for {col[-1] if col else 'a column'}{extra}.", raw
    if code == 1438:
        return "Number too large for this column's NUMBER(p,s) size.", raw
    if code in (1843, 1847, 1858, 1861):
        return "Date/time value isn't valid.", raw
    if code == 942:
        return "Table or view does not exist. (Run projectDBcreate.sql on the Scripts page?)", raw
    if code in (1017,):
        return "Wrong username or password.", raw
    if code == 4091:
        return "A trigger tried to read the table it is changing (mutating table).", raw
    if "DPY-3010" in raw or "DPY-3015" in raw:
        return ("This database is too old for the driver's thin mode. Install Oracle Instant Client "
                "and set \"instant_client_dir\" in config.json, then restart the app."), raw
    if "DPY-6005" in raw or "DPY-4011" in raw or "DPY-6000" in raw or "TNS" in raw:
        return "Can't reach the database. Check host/port/service, and the VPN for Omega.", raw
    return first, raw if raw != first else ""
