# MavDine Phase 3: Step-by-Step Guide & Progress Tracker

> **How we use this file**
> - This is the only place to look. Every step has: **Concept → Example (Library DB, not your project) → Your Task → Review**.
> - Write your answers directly in this file, in the **✍️ Your answer** boxes, then ask for a review with "check step X".
> - The review goes under each step, and the next step is added at the bottom.
> - ⚠️ **Do not include this file in the submission zip.** It is a study and tracking file only.

---

## 📌 Progress

| # | Step | Status |
|---|------|--------|
| 1 | BCNF check + table creation order | ✅ Done |
| 2a | Data types for **User** columns | ✅ Done |
| 2b | First `CREATE TABLE`: User (NOT NULL, PK, UNIQUE, CHECK) | ✅ Done |
| 2c | Merchant table (same process) | ✅ Done |
| 3 | Homecook, Chef, Campaign, Cookbook, Recipe (FKs + ON DELETE) | 🟡 **Current step** |
| 4 | Subscribe, Follow_Unfollow, Like_Dislike, Read, Display_On (composite FKs) | ⬜ |
| 5 | Triggers | ⬜ |
| 6 | `projectDBdrop.sql` | ⬜ |
| 7 | `projectDBinsert.sql` (20–25 rows per table) | ⬜ |
| 8 | `projectDBqueries.sql` (7+ queries) | ⬜ |
| 9 | `projectDBupdate.sql` | ⬜ |
| 10 | Run on Omega (`set echo on`, `spool`), then zip `team4_phase3_versionY.zip` | ⬜ |

---

## 📒 Decisions Log (agreed and final)

| Decision | Value |
|---|---|
| Table prefix | `DASC5306_Fall26_S001_T4_` |
| Constraint name prefix (short) | `T4_<Table>_<PK/FK/UQ/CK>_<what>`, e.g. `T4_User_UQ_email` |
| Spelling fixes vs. schema PDF | `ingredient_1..3`, `preparation_time` |
| Renamed tables (Oracle doesn't allow `/`) | `Follow_Unfollow`, `Like_Dislike` |
| Reserved words `User`, `Read` | OK, because the prefix makes the names unique |
| Composite FKs | Like_Dislike / Read → Recipe via `(COOKBOOK_ID, RECIPE_NUMBER)`; Display_On → Recipe via `(COOKBOOK_ID, RECIPE_NUMBER)` and → Campaign via `(MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER)`. No separate FK to Cookbook or Merchant. |
| Rules that need "today's date" | CHECK cannot use `SYSDATE`, so these go into triggers (Step 5). List them here as you find them: (1) User: age >= 18, i.e. `date_of_birth <= ADD_MONTHS(SYSDATE, -216)`; (2) User: `date_of_enrollment <= SYSDATE` |

---

## ✅ Step 1: BCNF Check + Table Creation Order

### Concept
- **BCNF:** for every FD `X → A`, the left side `X` must be a superkey.
- **Candidate keys that are not the PK** must still be enforced, using `UNIQUE NOT NULL`.
- **Order:** a table can only be created after every table it references. Drop in reverse.

### Example (Library DB)
```
L0: Member, Author        (no FKs)
L1: Book                  (→ Author)
L2: Copy                  (→ Book)
L3: Borrow                (→ Member, → Copy via composite FK (BookID, CopyNo))
```

### Your result (final, reviewed)
- **BCNF:** all 12 relations are in BCNF; every FD's left side is a PK or a candidate key.
- **UNIQUE constraints (4):** User.username, User.email, Chef.chef_id, Merchant.website

**Dependency levels:**
- **L0:** User, Merchant
- **L1:** Homecook (→ User), Chef (→ User), Campaign (→ Merchant)
- **L2:** Cookbook (→ Chef), Follow_Unfollow (→ Homecook, → Chef)
- **L3:** Subscribe (→ Homecook, → Cookbook), Recipe (→ Cookbook)
- **L4:**
  - Like_Dislike (→ Homecook, → Recipe via composite FK `(COOKBOOK_ID, RECIPE_NUMBER)`)
  - Read (→ Homecook, → Recipe via composite FK `(COOKBOOK_ID, RECIPE_NUMBER)`)
  - Display_On (→ Recipe via composite FK `(COOKBOOK_ID, RECIPE_NUMBER)`, → Campaign via composite FK `(MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER)`)

**Order:** create L0 → L4, drop L4 → L0.

### 💡 Lesson learned
A foreign key must reference the **whole** primary key. Referencing only `RECIPE_NUMBER` fails with **ORA-02270**, because recipe numbers repeat across cookbooks.

---

## ✅ Step 2a: Data Types for the User Table (planning only, no SQL yet)

### Concept
| Type | Use it for | Example |
|---|---|---|
| `CHAR(n)` | Text that is **always exactly** n characters | state code `'TX'` → `CHAR(2)` |
| `VARCHAR2(n)` | Text whose length **varies**, up to n | names, emails, URLs |
| `NUMBER(p)` | Whole numbers you **do math on**, up to p digits | quantity, age |
| `NUMBER(p,s)` | Decimals: p total digits, s after the point | `NUMBER(6,2)` → 9999.99 |
| `DATE` | Calendar date (Oracle's DATE also stores time) | birthday |
| `TIMESTAMP` | Date + time with precision. Oracle has **no `TIME` type**. | a reading session start |

**Key rule:** if you never do math on it, store it as text, even if it looks like a number. Number types drop leading zeros (`02134` becomes `2134`) and dashes.

### Example (Library `Member`, not your project)
| Column | Type | Reason |
|---|---|---|
| MID | `CHAR(8)` | Card IDs are always 8 chars; no math on them |
| email | `VARCHAR2(60)` | Length varies |
| phone | `VARCHAR2(15)` | No math; may contain `-` or `+` |
| join_date | `DATE` | It's a date |
| fine_balance | `NUMBER(6,2)` | Money with cents, up to 9999.99 |
| postal_code | `VARCHAR2(10)` | Must keep leading zeros |

### Final User types (final)
| Column | Type | Reason |
|---|---|---|
| MAV_ID | `CHAR(10)` | Always 10 digits; no math on it |
| username | `VARCHAR2(30)` | Length varies |
| email | `VARCHAR2(100)` | Length varies |
| password | `VARCHAR2(64)` | Room for a hashed password |
| phone_number | `VARCHAR2(15)` | No math; may contain `-`, `+`, `( )` |
| date_of_enrollment | `DATE` | Calendar date |
| cumulative_GPA | `NUMBER(3,2)` | 3 digits total, 2 after the point (0.00–4.00) |
| enrolled_department | `VARCHAR2(50)` | Length varies |
| nationality | `VARCHAR2(50)` | Length varies |
| date_of_birth | `DATE` | Calendar date |
| first_name | `VARCHAR2(30)` | Length varies |
| last_name | `VARCHAR2(30)` | Length varies |
| street_address | `VARCHAR2(100)` | Length varies |
| apartment_number | `VARCHAR2(10)` | Can be `"12B"` |
| city | `VARCHAR2(40)` | Length varies |
| county | `VARCHAR2(40)` | Length varies |
| zip_code | `VARCHAR2(10)` | Keeps leading zeros; fits ZIP+4 `76019-0001` |

> ⚠️ **Carry forward:** every column that references `MAV_ID` (HOMECOOK_MAV_ID, CHEF_MAV_ID, chef_mav_id) must also be `CHAR(10)`. An FK column must have the same type as the column it points to.

---

## ✅ Step 2b: Write Your First CREATE TABLE (User)

### Concept
A `CREATE TABLE` has two parts:
1. **Column lines:** `name  TYPE  [DEFAULT x]  [NOT NULL]`
2. **Table constraints** at the bottom, each with a name: `CONSTRAINT name PRIMARY KEY / UNIQUE / CHECK (...)`

| Constraint | When to use it |
|---|---|
| `NOT NULL` | The value is required: PK and candidate-key columns, plus anything the business needs |
| `PRIMARY KEY` | The chosen key. It is automatically NOT NULL and unique. |
| `UNIQUE` + `NOT NULL` | Every other candidate key. UNIQUE alone still allows NULL. |
| `CHECK (condition)` | Range, list, or pattern rules on one row. It **cannot use `SYSDATE`**, so date-vs-today rules become triggers. |

### Example (Library `Member`, not your project)
```sql
-- Member: every registered library member.
-- Candidate keys: MID (PK), username, email
CREATE TABLE DASC5306_Fall26_S001_T9_Member (
    MID             CHAR(8)       NOT NULL,
    username        VARCHAR2(30)  NOT NULL,
    email           VARCHAR2(60)  NOT NULL,
    password        VARCHAR2(64)  NOT NULL,
    phone           VARCHAR2(15),                         -- optional
    join_date       DATE          DEFAULT SYSDATE NOT NULL,
    fine_balance    NUMBER(6,2)   DEFAULT 0,
    membership_type VARCHAR2(10),
    birth_date      DATE,
    CONSTRAINT T9_Member_PK       PRIMARY KEY (MID),
    CONSTRAINT T9_Member_UQ_user  UNIQUE (username),
    CONSTRAINT T9_Member_UQ_email UNIQUE (email),
    CONSTRAINT T9_Member_CK_email CHECK (email LIKE '%_@_%._%'),
    CONSTRAINT T9_Member_CK_fine  CHECK (fine_balance >= 0),
    CONSTRAINT T9_Member_CK_type  CHECK (membership_type IN ('Basic','Premium','Student')),
    CONSTRAINT T9_Member_CK_dates CHECK (join_date > birth_date)   -- compares 2 columns: OK
);
```
Notes:
- `DEFAULT SYSDATE` is allowed. Only **CHECK** can't use SYSDATE.
- A CHECK that compares two columns of the same row (`join_date > birth_date`) is fine.

### ✍️ Your task
Write `CREATE TABLE DASC5306_Fall26_S001_T4_User` in **`projectDBcreate.sql`**, using the types above. Include:
- [ ] A `--` comment above the table (what it stores + its candidate keys)
- [ ] `NOT NULL` where needed (decide which columns are optional)
- [ ] PK on MAV_ID; `UNIQUE` on username and email
- [ ] At least 3 CHECKs. Ideas: GPA range, MAV_ID only digits (`REGEXP_LIKE(MAV_ID, '^[0-9]{10}$')`), email pattern, enrollment after birth.
- [ ] Add any "compared to today" rule to the Decisions Log (it becomes a trigger)

When you're done, ask for a review: **"check step 2b"**.

### 🔍 Review (round 1): ❌ Not ready yet. 2 blockers, then small fixes

**🔴 Blockers (the script will fail):**
1. **Line 13: `first_name VARCHAR2(30) NOT,`** is a syntax error, so the whole `CREATE TABLE` fails. It should be `NOT NULL`.
2. **`MAV_ID CHAR(10)` + `CHECK REGEXP_LIKE(MAV_ID, '^[A-Z]{2}[0-9]{6}$')` can never both be true.** The regex matches exactly 8 characters (`AB123456`). `CHAR(10)` pads that value with 2 spaces (`'AB123456  '`), so `$` never matches and **every INSERT is rejected (ORA-02290)**. It also contradicts Step 2a, where we decided "always 10 digits". Use `'^[0-9]{10}$'`.

**🟠 Fix these:**
3. **Line 18: `country`**, but the schema PDF and FDs say **`county`**. Either rename it to `county`, or, if you mean to change it, add the change to the Decisions Log the way we did for `ingredient_1..3`.
4. **No GPA CHECK.** `NUMBER(3,2)` accepts up to 9.99. Add `CHECK (cumulative_GPA BETWEEN 0 AND 4)`.
5. **Missing the comment line about candidate keys** (checklist item). Example: `-- Candidate keys: MAV_ID (PK), username, email`.

**🟡 Think about this:**
6. **Every column is `NOT NULL`.** The checklist asks you to decide which ones are optional. `apartment_number` should be nullable, because people who live in a house don't have one. `phone_number` and `nationality` could also be optional. That's your call, but be ready to justify it.
7. **"Compared to today" rules:** date_of_birth and date_of_enrollment can't be in the future. Add these to the Decisions Log, because they become triggers in Step 5.

**✅ Good:** PK and UNIQUE constraints are correct; constraint names follow the convention; the email pattern and the `enrollment > birth` two-column CHECK are correct; the types match Step 2a.

Fix 1–5, decide 6–7, then ask for **"check step 2b"** again.

### 🔍 Review (round 2): ❌ One blocker still open

- ✅ Fixed: #1 `NOT NULL`, #3 `county`, #4 GPA CHECK, #5 candidate-keys comment.
- 🔴 **#2 is still open (line 24).** The regex `'^[A-Z]{2}[0-9]{6}$'` is unchanged, so every INSERT will still fail. Change it to `'^[0-9]{10}$'`.
- 🟡 **#6 not decided:** `apartment_number` is still `NOT NULL`. Either drop the `NOT NULL`, or keep it and be ready to justify it.
- 🟡 **#7 not done:** the "today's date" row in the Decisions Log still says _(none yet)_. Add: `User.date_of_birth <= today`, `User.date_of_enrollment <= today`.

Fix #2 and this step passes. #6 and #7 take one minute each.

### 🔍 Review (round 3): ❌ 2 blockers

- ✅ #6 decided: `apartment_number` and `phone_number` are now optional. Good.
- 🔴 **#2 is still open (line 24).** The regex is still `'^[A-Z]{2}[0-9]{6}$'`, so every INSERT will fail. Change it to `'^[0-9]{10}$'`.
- 🔴 **NEW, line 27: `CHECK (date_of_birth <= ADD_MONTHS(SYSDATE, -18*12))`.** CHECK cannot use `SYSDATE`, so Oracle refuses to create the table (**ORA-02436**). Delete this line and move the rule to the Decisions Log as a trigger: `User: age >= 18 (date_of_birth <= ADD_MONTHS(SYSDATE, -216))`.
- 🟡 **#7 still not done:** the "today's date" row still says _(none yet)_. Add the 18+ rule above and `date_of_enrollment <= today`.

### 🔍 Review (round 4): ✅ PASSED

- ✅ The MAV_ID regex is `'^[0-9]{10}$'`, which matches `CHAR(10)`.
- ✅ The SYSDATE CHECK is gone; both "today" rules are in the Decisions Log for Step 5.
- ✅ The PK, 2 UNIQUEs, 4 CHECKs, and nullable columns are all justified.

### 💡 Lessons learned
- `CHAR(n)` pads with spaces, so a regex anchored with `$` must match exactly n characters.
- CHECK can't use `SYSDATE` (ORA-02436). Rules that compare to today become triggers.

---

## ✅ Step 2c: Merchant Table (same process, on your own)

### Concept
Same as User: choose the types, decide NOT NULL, then add the PK, UNIQUE, and CHECKs. Merchant has **two candidate keys**: `REGISTRATION_NUMBER` (PK) and `website` (UNIQUE + NOT NULL).

### Columns (from the schema PDF)
`REGISTRATION_NUMBER`, `merchant_name`, `website`, `number_of_employees`, `headquarter_city`

### ✍️ Your task
Add `CREATE TABLE DASC5306_Fall26_S001_T4_Merchant` **below User** in `projectDBcreate.sql`:
- [ ] A comment: what it stores + its candidate keys
- [ ] Types: think about whether `REGISTRATION_NUMBER` ever needs math (Step 2a key rule). `number_of_employees` does → `NUMBER(p)`.
- [ ] PK on REGISTRATION_NUMBER; UNIQUE on website
- [ ] At least 2 CHECKs. Ideas: `number_of_employees > 0`, website pattern (`LIKE 'http%'` or `'%.%'`).
- [ ] ⚠️ Carry forward: whatever type you pick for REGISTRATION_NUMBER, `Campaign.MERCHANT_REGISTRATION_NUMBER` and `Display_On.MERCHANT_REGISTRATION_NUMBER` must use the **same** type.

When you're done, ask for a review: **"check step 2c"**.

### 🔍 Review (round 1): ❌ 1 blocker + 3 fixes

**🔴 Blocker:**
1. **Line 40: the constraint name `T4_Merchant_CK_REGISTERATION_NUMBER` is 35 characters.** Oracle before 12.2 allows a maximum of 30 (**ORA-00972: identifier is too long**), and Omega may be running an older version. Shorten it, e.g. `T4_Merchant_CK_regno`. Rule from now on: keep every name ≤ 30 characters.

**🟠 Fix these:**
2. **Spelling: `REGISTERATION_NUMBER` → `REGISTRATION_NUMBER`** (lines 31, 33, 38, 40). The schema PDF uses `REGISTRATION`, and Campaign and Display_On will have `MERCHANT_REGISTRATION_NUMBER`. If you keep the typo, you'll carry it into 3 tables.
3. **`number_of_employees VARCHAR2(10)` → `NUMBER(7)`.** You do math on it (count, compare, `> 0`), so per the Step 2a key rule it is a number. As text, `'9' > '10'` is TRUE.
4. **Only 1 CHECK; the task asks for at least 2.** Add:
   - `CHECK (number_of_employees > 0)` (this works only once #3 is done)
   - `CHECK (website LIKE '%_._%')` or `LIKE 'http%'`

**✅ Good:** the PK and UNIQUE on website are correct; `CHAR(10)` + the 10-digit regex are consistent; the comment lists both candidate keys.

**⚠️ Carry forward:** `MERCHANT_REGISTRATION_NUMBER` in Campaign and Display_On must be `CHAR(10)`.

Fix 1–4, then ask for **"check step 2c"** again.

### 🔍 Review (round 2): 🟡 Runs, but #3 is still open

- ✅ #1 The constraint names are short (`T4_Merchant_CK_regno`, `_website`, `_empno`).
- ✅ #2 The spelling is `REGISTRATION_NUMBER` everywhere.
- ✅ #4 It now has 3 CHECKs.
- 🟡 **#3 `number_of_employees` is still `VARCHAR2(10)`.** The regex + `TO_NUMBER` CHECK is clever and the table will be created, but the data is still text:
  - In Step 8 queries, `ORDER BY number_of_employees` sorts `'100' < '9'`, and `> 500` comparisons need `TO_NUMBER(...)` every time.
  - `'0050'` and `'50'` are both accepted as different values.
  - Oracle doesn't guarantee the order in which the two halves of an `AND` are evaluated, so `'abc'` could fail with ORA-01722 instead of a clean CHECK violation.

  **Recommended:** `number_of_employees NUMBER(7) NOT NULL` + `CONSTRAINT T4_Merchant_CK_empno CHECK (number_of_employees > 0)`. That's simpler and correct.
- Small: delete the blank line before `);` (cosmetic).

Change #3 and Step 2c passes.

### 🔍 Review (round 3): ✅ PASSED

`number_of_employees NUMBER(7)` + `CHECK (> 0)` is correct. The PK, UNIQUE, 3 CHECKs, and names ≤ 30 characters are all good.

### 💡 Lessons learned
- Oracle names before 12.2 have a maximum of **30 characters**. Check every table, column, and constraint name.
- If you do math on it or compare it, use `NUMBER`. Don't patch text with `TO_NUMBER` inside CHECKs.

---

## 🟡 Step 3: Tables with Foreign Keys (Homecook, Chef, Campaign, Cookbook, Recipe)

### Concept
- **FK syntax:** `CONSTRAINT name FOREIGN KEY (col) REFERENCES Parent(pk_col) [ON DELETE CASCADE | ON DELETE SET NULL]`
- **Oracle supports only 2 ON DELETE options:** `CASCADE` and `SET NULL`. If you write nothing, the default is "no action": you can't delete a parent that still has children. There is **no `ON DELETE RESTRICT`** and **no `ON UPDATE`** in Oracle.
  - `CASCADE`: the child can't exist without the parent (a weak entity, or a subclass row).
  - `SET NULL`: the child survives, without a link (the FK column must be nullable).
  - Nothing: protects the parent from accidental deletion.
- **The FK column type must match the parent PK exactly** (`CHAR(10)` → `CHAR(10)`).
- **A column can be both PK and FK** (a subclass like Homecook, or a weak entity like Recipe).
- **Composite PK:** `PRIMARY KEY (a, b)`. A child that references it needs a composite FK `(a, b)`.

### Example (Library DB, not your project)
```sql
-- Author: subclass of Person (ISA), so the PK is also an FK
CREATE TABLE DASC5306_Fall26_S001_T9_Author (
    AUTHOR_PID CHAR(8) NOT NULL,
    pen_name   VARCHAR2(50) NOT NULL,
    CONSTRAINT T9_Author_PK     PRIMARY KEY (AUTHOR_PID),
    CONSTRAINT T9_Author_UQ_pen UNIQUE (pen_name),
    CONSTRAINT T9_Author_FK_Person FOREIGN KEY (AUTHOR_PID)
        REFERENCES DASC5306_Fall26_S001_T9_Person(PID) ON DELETE CASCADE
);

-- Copy: weak entity of Book, so composite PK (BOOK_ID, COPY_NO) and CASCADE
CREATE TABLE DASC5306_Fall26_S001_T9_Copy (
    BOOK_ID  NUMBER(8) NOT NULL,
    COPY_NO  NUMBER(3) NOT NULL,
    shelf    VARCHAR2(10),
    CONSTRAINT T9_Copy_PK      PRIMARY KEY (BOOK_ID, COPY_NO),
    CONSTRAINT T9_Copy_FK_Book FOREIGN KEY (BOOK_ID)
        REFERENCES DASC5306_Fall26_S001_T9_Book(BOOK_ID) ON DELETE CASCADE,
    CONSTRAINT T9_Copy_CK_no   CHECK (COPY_NO > 0)
);
```

### ✍️ Your task: write them in this order, under Merchant
1. [ ] **Homecook:** `HOMECOOK_MAV_ID CHAR(10)`, which is both PK and FK → User. Pick an ON DELETE option.
2. [ ] **Chef:** `CHEF_MAV_ID CHAR(10)` PK + FK → User; `chef_id` is UNIQUE NOT NULL (a candidate key).
3. [ ] **Campaign:** composite PK `(MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER)`; FK → Merchant. `MERCHANT_REGISTRATION_NUMBER` is `CHAR(10)`. `cashback_rate_per_read` is money/a rate → `NUMBER(p,s)` + CHECK.
4. [ ] **Cookbook:** `COOKBOOK_ID` PK; `chef_mav_id CHAR(10)` FK → Chef. Decide: if a chef is deleted, do their cookbooks go too (CASCADE), stay without a chef (SET NULL, so the column must be nullable), or block the delete (nothing)?
5. [ ] **Recipe:** composite PK `(COOKBOOK_ID, RECIPE_NUMBER)`; FK → Cookbook. ⚠️ **`time_of_publish`:** Oracle has no TIME type. Decide between (a) `TIMESTAMP`, or (b) dropping it and storing the time inside `date_of_publish DATE`. Log your choice in the Decisions Log.
- [ ] At least 1 CHECK per table where it makes sense (e.g. `total_calories >= 0`, `meal_type IN (...)`, `cashback_rate_per_read BETWEEN 0 AND 1`).
- [ ] Explain each ON DELETE choice in a `--` comment above the FK.
- [ ] Any new "today" rules (e.g. `date_of_creation <= today`) → add them to the Decisions Log.

💡 Tip: do 1–2 first and ask for a review ("check homecook and chef"); then 3; then 4–5. Smaller reviews catch mistakes before they spread.

### 🔍 Review
_(Review goes here.)_
