# MavDine Manager

A small web interface for the MavDine Oracle database, built with the help of Claude (Anthropic's AI assistant): browse and edit tables with forms,
run the 7 business queries, use a SQL console, and run the project scripts. It works without
writing SQL.

## Start it

Double-click **`run.bat`**, or run:

```
cd mavdine_app
pip install -r requirements.txt
python app.py
```

It opens http://127.0.0.1:5000 in your browser. Only your own computer can reach it.

## Connect

The login page has two profiles:

| Profile | When | Settings |
|---|---|---|
| **Omega (UTA Oracle)** | The real course database | Host, port and service name of the database SQL*Plus on Omega uses (see below), your Oracle username and password, **Encrypted connection (TCPS)** ticked. |
| **Local practice copy** | Practise without touching the course database | `localhost`, `1521`, `FREEPDB1`, user `mavdine`, password `mavdine` |

"Remember" saves host/port/service/username in `config.json`, which is git-ignored. The password is
never saved: it is only kept in memory while the app is running.

### Finding the course database settings

The course database is an Oracle cloud database that only accepts encrypted (TCPS) connections.
Log in to Omega and print the connection entries SQL*Plus uses:

```
cat $ORACLE_HOME/network/admin/tnsnames.ora
```

From the entry you use with `sqlplus <username>@<alias>`, copy `host`, `port` and `service_name`
into the login page.

### Local practice copy (needs Docker Desktop)

1. Install Docker Desktop: https://www.docker.com/products/docker-desktop/
2. In this folder: `docker compose up -d` (the first time downloads about 1 GB).
3. Log in with the Local profile, open **Scripts** and click **Run reset** (drop → create → insert).

`docker compose down` stops it (the data is kept); `docker compose down -v` wipes it.
The passwords in `docker-compose.yml` only protect this throwaway local copy.

### If the database says it is too old (DPY-3010 / DPY-3015)

The driver's default "thin" mode needs Oracle 12.1 or newer. For older servers, install
Oracle Instant Client and put its folder in `config.json`:
`"instant_client_dir": "C:\\oracle\\instantclient_21_13"`, then restart the app.

## Pages

- **Dashboard**: every table by level with its row count, keys and foreign keys.
- **Tables** (sidebar): search, sort (click a column), add, edit, delete.
  - Foreign keys are dropdowns showing names, not just IDs (e.g. `1001000009 - Fatima Ali`).
  - CHECK `IN (...)` lists become dropdowns; dates and timestamps get pickers.
  - "Structure" shows each column's type, keys, CHECK rules and triggers, read live from Oracle.
  - Delete shows **what else will be deleted** by ON DELETE CASCADE, and warns when a
    foreign key without cascade will block it.
  - Errors are explained in plain English (which rule, which column), with Oracle's message underneath.
- **Business queries**: Q1 to Q7, read live from `projectDBqueries.sql`, with the expected output to compare.
- **SQL console**: run any SQL (several statements, triggers with `/`). Ctrl+Enter runs it.
  It stops at the first error and rolls back that run.
- **Scripts**: run `projectDBdrop/create/insert/update/queries.sql` like SQL*Plus, or **Reset**.
  The app finds them in `../MavDine_DatabaseScripts/` (or the folder set as `scripts_dir` in `config.json`).
  On Omega it asks for confirmation first.

## Files

| File | What it does |
|---|---|
| `app.py` | Web pages and routes (Flask) |
| `db.py` | Connections, reading the schema from Oracle, value conversion |
| `errors.py` | Oracle error → plain-English message |
| `queries.py` | Reads the business queries from `projectDBqueries.sql` |
| `sqlscript.py` | Splits SQL*Plus scripts into statements |
| `templates/`, `static/` | HTML, CSS, JavaScript |
