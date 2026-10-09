# MavDine: A Digital Cookbook Platform Database

**DASC 5306-001, Fall 2026 · Project 1**
*Data Management System Development for a Data Intensive Application*

MavDine is a database for an online cookbook platform for UTA students. Students sign up as
**home cooks** (who subscribe to cookbooks, read recipes, follow chefs and like or dislike recipes) and
as **chefs** (who publish cookbooks and recipes). Grocery **merchants** pay to show **campaigns** (ads)
on recipes.

The project took the business owner's plain-English description of that platform all the way to a working
Oracle database. It was done in the four phases the course defines, each one building on the last:

```
Phase 0             Phase 1            Phase 2                 Phase 3
Problem statement → EER diagram     →  Relations, keys, FDs →  BCNF + Oracle database + SQL (demo)
(what the owner     (entities and      (tables, primary and    (DDL, constraints, triggers, data,
 wants)              relationships)     foreign keys)           7 business queries)
```

On top of the graded work, the repository also includes **MavDine Manager**, a web interface for the
database ([`mavdine_app/`](MavDine/mavdine_app/)).

---

## Contents

1. [How the project was set up](#1-how-the-project-was-set-up)
2. [Phase 0: The problem](#2-phase-0-the-problem)
3. [Phase 1: EER modeling](#3-phase-1-eer-modeling)
4. [Phase 2: Mapping to relations](#4-phase-2-mapping-to-relations)
5. [Phase 3: Building the database in Oracle](#5-phase-3-building-the-database-in-oracle)
6. [How to run the scripts](#6-how-to-run-the-scripts)
7. [MavDine Manager (web interface)](#7-mavdine-manager-web-interface)
8. [Skills I learned](#8-skills-i-learned)
9. [Repository structure](#9-repository-structure)

---

## 1. How the project was set up

Project 1 is worth 24% of the course grade and is graded in phases. The graded phases carry 8% each.
Every phase is submitted on Canvas as one zipped folder with a phase and version number in its name
(`…_phaseX_versionY.zip`), with Y going up by one on each resubmission.

| Phase | Weight | What was done | Deliverable |
|---|---|---|---|
| **0** Problem statement | (given) | Read the owner's description, added details and assumptions, and added 2 new business goals | Revised problem description |
| **1** EER modeling | 8% | Drew the Extended Entity-Relationship diagram in the course's notation | EER diagram |
| **2** Mapping to relations | 8% | Converted the EER diagram into relations, with every primary key, foreign key, candidate key and functional dependency | Relational schema with keys and FDs |
| **3** Database + SQL (demo) | 8% | Normalized to BCNF, built the database in Oracle, and wrote the 5 scripts | `projectDBcreate/insert/update/drop/queries.sql` |

Rules from the assignment that shaped the design:

- **Table names:** every table carries the course prefix, so `User` is `DASC5306_Fall26_S001_T4_User`.
- **Database:** Oracle RDBMS, used through SQL*Plus on UTA's Omega server.
- **Normalization:** every relation must be in **BCNF** before writing the DDL.
- **Constraints and triggers:** every constraint has to be enforced in the database, using triggers
  where a constraint can't express the rule.
- **Test data:** about 20 to 25 realistic rows per table, consistent with every primary and foreign key.
- **Update script:** the update script has to **change the results** of the queries.
- **Query format:** at least 7 queries, each with its English version, the SQL, and the expected output.
  No `SELECT * FROM table`.
- **Demo:** run the queries, run the update script, then run the **same** queries again and explain the
  differences.

---

## 2. Phase 0: The problem

> Document: [Final problem description](MavDine/MavDine_BusinessProblem/Final_Problem_Description.pdf)

The owner (UTA) wants to track users, home cooks, chefs, cookbooks, recipes, merchants and campaigns,
and how they all interact:

- Every user is a UTA student with a unique MavID. A user can be a **home cook, a chef, or both**.
- A **chef** creates cookbooks. Each cookbook has one primary cuisine from a fixed list (Chinese,
  French, Greek, Indian, Italian, Japanese, Korean, Mediterranean, Mexican, Spanish, Thai).
- A **recipe** belongs to exactly one cookbook and is numbered 1, 2, 3, … inside it. It has one meal
  type (breakfast, brunch, lunch, snacks, dinner or dessert) and three main ingredients. Deleting a
  cookbook deletes its recipes.
- A **home cook** subscribes to cookbooks, follows chefs, likes or dislikes recipes, and reads
  recipes. Each reading session is logged with start and end time and location, and the same recipe can
  be read many times.
- A **merchant** runs **campaigns**, numbered per merchant. A campaign is displayed on individual
  recipes, each placement has its own display cost, and the platform pays the merchant cashback per read.

### The 7 business goals

The owner listed 5 reports. Phase 1 required 2 more that use the merchant and campaign data
(goals 6 and 7 were added):

| # | Report | Why the owner wants it |
|---|---|---|
| 1 | Average reading minutes per day of the week | Chefs pick the best day to publish |
| 2 | Top 10 chefs by average likes per recipe published in 2025 | Find trending chefs; adjust ad pricing |
| 3 | Most popular meal type per birth year, with average cooking time | Show each age group relevant content |
| 4 | Cookbooks read **only** by CSE students enrolled after July 2024 | Spot what's trending in one group |
| 5 | Subscribers who read **every** recipe of the Indian/Korean "campfire kitchen" cookbooks | Find enthusiasts for menu-design teams |
| 6 | Arlington merchants with at least one campaign *(added)* | Highlight local deals to students |
| 7 | Display cost vs. cashback owed per merchant *(added)* | Find placements where the platform pays out more than it earns, so it can renegotiate them |

### Assumptions added

- Username and email are unique, so they become **candidate keys**.
- Age, follower counts, subscriber counts and read/like totals are **derived**: queries calculate them,
  so they aren't stored.
- The 3 main ingredients are a composite attribute with exactly three parts.
- A home cook can read the same recipe many times, so a reading session is identified by its
  **start time**.
- Merchant websites are unique, so `website` is a candidate key.

---

## 3. Phase 1: EER modeling

> Document: [EER diagram](MavDine/MavDine_Initial_EER_and_Final_Revised_EER/EER%20Diagram.pdf)

The owner's description was turned into an **Extended Entity-Relationship diagram**. The assignment
required it to be drawn by hand or in PowerPoint/Paint, using only the course notation and **(min, max)**
cardinalities. Main modeling decisions:

- **Specialization:** `User` is the superclass of `Homecook` and `Chef`. The subclasses overlap,
  because one student can be both.
- **Weak entities:** `Recipe` depends on `Cookbook`, since its recipe number restarts at 1 in each
  cookbook. `Campaign` depends on `Merchant` in the same way.
- **Relationships with their own attributes:** Read (start/end time, location), Like/Dislike
  (interaction type), and Display_On (display cost).
- **Derived attributes:** age, number of followers, number of subscribers and number of reads are kept
  out of the stored data.

---

## 4. Phase 2: Mapping to relations

> Documents: [Relation schema](MavDine/MavDine_MappedRelations_CandidateKeys_FunctionalDependencies_BCNF_DependencyLevels/RelationSchema.pdf) · [Candidate keys and functional dependencies](MavDine/MavDine_MappedRelations_CandidateKeys_FunctionalDependencies_BCNF_DependencyLevels/RelationSchema_CandidateKeys_FunctionalDependencies.pdf)

The EER diagram was mapped into **12 relations** using the textbook mapping steps. Every relation has
its primary key, foreign keys (drawn as arrows), **all candidate keys**, and its **functional
dependencies** listed.

| Relation | Primary key | Other candidate keys | Foreign keys |
|---|---|---|---|
| User | MAV_ID | username, email | - |
| Merchant | REGISTRATION_NUMBER | website | - |
| Homecook | HOMECOOK_MAV_ID | - | → User |
| Chef | CHEF_MAV_ID | chef_id | → User |
| Campaign | (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER) | - | → Merchant |
| Cookbook | COOKBOOK_ID | - | → Chef |
| Follow_Unfollow | (HOMECOOK_MAV_ID, CHEF_MAV_ID) | - | → Homecook, → Chef |
| Subscribe | (HOMECOOK_MAV_ID, COOKBOOK_ID) | - | → Homecook, → Cookbook |
| Recipe | (COOKBOOK_ID, RECIPE_NUMBER) | - | → Cookbook |
| Like_Dislike | (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER) | - | → Homecook, → Recipe |
| Read | (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time) | - | → Homecook, → Recipe |
| Display_On | (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER) | - | → Recipe, → Campaign |

Two example functional dependencies:

- `MAV_ID → {username, email, password, …, zip_code}`
- `{COOKBOOK_ID, RECIPE_NUMBER} → {title, source_url, date_of_publish, …, total_calories}`

---

## 5. Phase 3: Building the database in Oracle

### BCNF check

> Document: [BCNF check table, dependency levels and execution order](MavDine/MavDine_MappedRelations_CandidateKeys_FunctionalDependencies_BCNF_DependencyLevels/BCNFCheckTable,%20DependencyLevels,ExecutionOrder.pdf)

A relation is in BCNF when, for every functional dependency `X → A`, X is a superkey. Every FD in the
12 relations has a primary key or candidate key on its left side, so **all 12 relations are already in
BCNF** and no table had to be split. Each extra candidate key (username, email, website, chef_id)
became a `UNIQUE` constraint.

### Creation order (dependency levels)

A table can only reference a table that already exists, so the tables are grouped into levels:

| Level | Tables | Depends on |
|---|---|---|
| 0 | User, Merchant | nothing |
| 1 | Homecook, Chef, Campaign | Level 0 |
| 2 | Cookbook, Follow_Unfollow | Level 1 |
| 3 | Subscribe, Recipe | Level 2 |
| 4 | Like_Dislike, Read, Display_On | Level 3 |

The create and insert scripts run Level 0 → 4. The drop script runs Level 4 → 0.

### The five scripts

| Script | Assignment step | What it does |
|---|---|---|
| [`projectDBcreate.sql`](MavDine/MavDine_DatabaseScripts/projectDBcreate.sql) | Step 1: DDL | 12 tables with named constraints, plus 5 triggers |
| [`projectDBinsert.sql`](MavDine/MavDine_DatabaseScripts/projectDBinsert.sql) | Step 2: DML | 741 realistic rows (22 to 255 per table), shaped so every business query returns meaningful results |
| [`projectDBupdate.sql`](MavDine/MavDine_DatabaseScripts/projectDBupdate.sql) | Step 3: Updates | Inserts, updates and deletes; each one is documented with the query result it changes |
| [`projectDBdrop.sql`](MavDine/MavDine_DatabaseScripts/projectDBdrop.sql) | Step 4: Drop | Drops every table children-first with `PURGE`, then `PURGE RECYCLEBIN` |
| [`projectDBqueries.sql`](MavDine/MavDine_DatabaseScripts/projectDBqueries.sql) | Step 5: Queries | The 7 business goals: English version, SQL, and expected output before **and** after the update |

### Constraints

Every rule from the problem statement is enforced by the database itself:

- **Keys:** `PRIMARY KEY` (including composite keys of up to 4 columns), `UNIQUE` for candidate keys, and
  `FOREIGN KEY` (including composite foreign keys such as `(COOKBOOK_ID, RECIPE_NUMBER) → Recipe`).
- **`CHECK` constraints:**
  - MavID is exactly 10 digits (`REGEXP_LIKE`).
  - GPA is between 0 and 4.
  - Email and URL have a valid shape (`LIKE`).
  - Cuisine and meal type come from the fixed lists (`IN`).
  - Times are valid `HH24:MI` values.
  - A home cook can't follow themselves.
  - A reading session ends after it starts.
- **`ON DELETE CASCADE`** where the child can't exist without its parent: deleting a cookbook deletes
  its recipes, which deletes their reads, likes and ad placements. It is deliberately **left off**
  Cookbook → Chef, so a chef who still owns cookbooks can't be deleted by accident.
- **Naming:** every constraint is named `T4_<Table>_<PK|FK|UQ|CK>_<what>`, so an error message names the
  exact rule that was broken.

### Triggers

A `CHECK` can't use today's date or look at another table, so these rules are PL/SQL triggers:

| Trigger | Business rule |
|---|---|
| T1 | A user must be at least 18, and can't have an enrollment date in the future |
| T2 | A cookbook can't be created in the future |
| T3 | A recipe can't be published in the future, or before its cookbook was created |
| T4 | A reading session can't start in the future, or before the recipe was published |
| T5 | A home cook can only like or dislike a recipe they have actually read |

### Queries

| Query | Techniques used |
|---|---|
| Q1 | Date functions (`TO_CHAR 'Day'`, `TRUNC 'IW'`), timestamp arithmetic in minutes, `GROUP BY` |
| Q2 | Common table expressions (`WITH`), `LEFT JOIN` + `NVL`, `FETCH FIRST 10 ROWS ONLY` |
| Q3 | Window function `RANK() OVER (PARTITION BY …)` to pick the top meal type per birth year |
| Q4 | "Only" logic with `NOT EXISTS` |
| Q5 | "Every" logic: relational division with a double `NOT EXISTS` |
| Q6 | Inner join meaning "has at least one" |
| Q7 | Four-table join on composite keys; aggregate before joining so the sums aren't multiplied |

The update script changes all 7 results in ways that can be explained. For example, it closes open
reading sessions and adds long Tuesday reads (Q1), unsubscribes one student and completes another
student's reading (Q5), and renegotiates the two worst ad deals (Q7).

---

## 6. How to run the scripts

In SQL*Plus on Omega, started from the folder that holds the five scripts
(`MavDine_DatabaseScripts/`), in the order used at the demo:

```sql
SET ECHO ON
SPOOL final_run.txt
@projectDBdrop.sql
@projectDBcreate.sql
@projectDBinsert.sql
@projectDBqueries.sql      -- results before the update
@projectDBupdate.sql
@projectDBqueries.sql      -- the SAME queries again: results changed
SPOOL OFF
```

The first run of the drop script reports "table does not exist" for every table. That's expected on an
empty database.

---

## 7. MavDine Manager (web interface)

Typing SQL for every check gets slow, so I also built **MavDine Manager**, a local web app for working
with the database the way you would in a real database tool. **It was built with the help of Claude
(Anthropic's AI assistant).** It isn't part of the graded Phase 3 submission, which is the five scripts
above.

- **Browse tables:** browse all 12 tables by level; search, sort, add, edit and delete rows through forms.
  Foreign keys appear as dropdowns of names instead of raw IDs.
- **See the rules:** each table's columns, keys, `CHECK` rules and triggers are read live from Oracle's
  data dictionary.
- **Safe deletes:** before a delete, it shows every row that `ON DELETE CASCADE` will also remove, and
  warns when a foreign key will block the delete.
- **Readable errors:** errors are explained in plain English (which constraint, which column), with
  Oracle's original message underneath.
- **Queries:** runs the 7 business queries directly from `projectDBqueries.sql`, next to their expected
  output.
- **SQL console and scripts:** includes a SQL console, and runs the project scripts the way SQL*Plus
  does (including a one-click reset).
- **Connections:** connects to the course's Oracle cloud database over an encrypted (TCPS) connection,
  or to a local practice copy in Docker. Passwords are never stored.

Built with Python, Flask and python-oracledb. Setup instructions are in
[`mavdine_app/README.md`](MavDine/mavdine_app/README.md).

---

## 8. Skills I learned

From reading the owner's description on day one to running the final demo, these are the skills this
project built, in the order I used them:

**Requirements analysis (Phase 0)**
- Read a business owner's non-technical description and pick out the entities, attributes,
  relationships and rules hidden in it.
- Spot gaps, write explicit **assumptions** for them, and check that every business goal has the data it
  needs.
- Write **new business goals** that create value from data nobody had used yet (merchant and campaign
  data).

**Conceptual modeling (Phase 1)**
- Model with the **EER** notation: entities, relationships, keys, and **(min, max)** cardinalities.
- Recognize **weak entities** (Recipe, Campaign) and **overlapping specialization** (User → Homecook /
  Chef).
- Decide what to store and what to **derive** (age, counts, totals).

**Logical design (Phase 2)**
- Map an EER diagram to relations step by step.
- Identify **primary, foreign and candidate keys**, including composite keys.
- Write **functional dependencies** for every relation.

**Normalization and physical design (Phase 3)**
- Check every relation for **BCNF** with an FD-by-FD table, and turn candidate keys into `UNIQUE`
  constraints.
- Choose Oracle **data types** (`CHAR` vs `VARCHAR2`, `NUMBER(p,s)`, `DATE` vs `TIMESTAMP`), and work
  around missing types: Oracle has no `TIME` or `BOOLEAN` column type.
- Order the tables by **dependency level**, so creation and dropping never break a foreign key.
- Enforce rules **inside the database**: named constraints, `CHECK` with `REGEXP_LIKE`, `IN` and `LIKE`,
  and choosing between `ON DELETE CASCADE` and blocking a delete.
- Write **PL/SQL triggers** for rules a `CHECK` can't express: `:NEW`, `SELECT INTO`, `NO_DATA_FOUND`,
  `RAISE_APPLICATION_ERROR`.

**Data and SQL**
- Design **test data on purpose**: realistic rows that respect every key and trigger, and are shaped so
  each business query gives a meaningful answer.
- Write **complex SQL**: multi-table and composite-key joins, outer joins with `NVL`, aggregation,
  `WITH` clauses, `RANK() OVER (PARTITION BY)`, `EXISTS` / `NOT EXISTS`, relational division ("every"),
  date and time arithmetic, and top-N queries.
- **Test queries properly**: record expected output, change the data with an update script, and explain
  every difference in the results.

**Tools and workflow**
- Run scripts in **SQL*Plus** (`@script`, `SPOOL`, `SET ECHO`, `COLUMN … FORMAT`, `SET DEFINE OFF`) on a
  remote Linux server over **SSH**.
- Read Oracle's **connection configuration** (`tnsnames.ora`) and connect to an Oracle cloud database
  over **TCPS**.
- Use **Git and GitHub**: commits, `.gitignore` for personal notes and settings, and taking files out of
  tracking without deleting them.
- Use an AI assistant as a tool to build a practical web interface (Python, Flask, python-oracledb)
  on top of a database design I understand end to end.
- Manage a **project in phases**, with versioned submissions and a final task and time management
  report.

---

## 9. Repository structure

```
README.md                                           this file
MavDine/
├── MavDine_BusinessProblem/                        Phase 0: final problem description
├── MavDine_Initial_EER_and_Final_Revised_EER/      Phase 1: EER diagram
├── MavDine_MappedRelations_CandidateKeys_FunctionalDependencies_BCNF_DependencyLevels/
│                                                   Phase 2: relation schema, candidate keys, FDs,
│                                                   BCNF check, dependency levels
├── MavDine_DatabaseScripts/                        Phase 3: the five SQL scripts
│   ├── projectDBcreate.sql     12 tables, constraints and 5 triggers
│   ├── projectDBinsert.sql     741 rows of sample data
│   ├── projectDBupdate.sql     inserts/updates/deletes that change the query results
│   ├── projectDBdrop.sql       drops everything, children first
│   └── projectDBqueries.sql    the 7 business queries with expected output
└── mavdine_app/                    MavDine Manager web interface (see its README)
```

The course assignment and personal study notes are kept out of the repository.
