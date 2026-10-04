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
| 2b | First `CREATE TABLE`: User (NOT NULL, PK, UNIQUE, CHECK) | 🟡 **Current step** |
| 2c | Merchant table (same process) | ⬜ |
| 3 | Homecook, Chef, Campaign, Cookbook, Recipe (FKs + ON DELETE) | ⬜ |
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
| Rules that need "today's date" | CHECK cannot use `SYSDATE`, so these go into triggers (Step 5). List them here as you find them: _(none yet)_ |

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

## 🟡 Step 2b: Write Your First CREATE TABLE (User)

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

### 🔍 Review
_(Review goes here.)_
