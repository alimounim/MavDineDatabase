-- projectDBqueries.sql: MavDine database (Team 4, DASC5306 Fall 2026, Section 001)
-- Ad-hoc queries for the 7 business goals from Phase 0 (5 given + 2 added by the team).
-- Each query has: the English version, the SQL version, and the expected output.
-- Run order for the demo: drop -> create -> insert -> queries -> update -> queries again.

SET LINESIZE 200
SET PAGESIZE 100
SET FEEDBACK ON
COLUMN day_of_week                  FORMAT A11
COLUMN chef_name                    FORMAT A20
COLUMN meal_type                    FORMAT A10
COLUMN cookbook_name                FORMAT A30
COLUMN primary_cuisine              FORMAT A15
COLUMN student_name                 FORMAT A20
COLUMN nationality                  FORMAT A12
COLUMN email                        FORMAT A30
COLUMN merchant_name                FORMAT A28
COLUMN website                      FORMAT A36
COLUMN advertised_grocery_item_name FORMAT A28

-- =====================================================================
-- Query 1 (Business Goal 1)
-- English: For each day of the week, what is the average number of minutes
--          a home cook spends reading a recipe?
--          (Only finished reading sessions, i.e. end_time is not NULL, are used.)
-- =====================================================================
SELECT TRIM(TO_CHAR(rd.start_time, 'Day', 'NLS_DATE_LANGUAGE=ENGLISH'))      AS day_of_week,
       COUNT(*)                                                            AS reading_sessions,
       ROUND(AVG((CAST(rd.end_time AS DATE) - CAST(rd.start_time AS DATE)) * 24 * 60), 1)
                                                                           AS avg_reading_minutes
FROM   DASC5306_Fall26_S001_T4_Read rd
WHERE  rd.end_time IS NOT NULL
GROUP  BY TRIM(TO_CHAR(rd.start_time, 'Day', 'NLS_DATE_LANGUAGE=ENGLISH'))
-- days since the Monday of that week (0 = Monday ... 6 = Sunday), so Monday is listed first
ORDER  BY MIN(TRUNC(rd.start_time) - TRUNC(rd.start_time, 'IW'));

/* Expected output (before update):
DAY_OF_WEEK READING_SESSIONS AVG_READING_MINUTES
----------- ---------------- -------------------
Monday                    41                15.7
Tuesday                   29                13.7
Wednesday                 48                16.9
Thursday                  31                13.6
Friday                    36                21.5
Saturday                  34                29.1
Sunday                    34                37.7

7 rows selected.
*/

/* Expected output (after projectDBupdate.sql):
   Why it changed: U1 closes 2 open sessions; I1 adds six 55-minute Tuesday reads -> Tuesday 13.7 -> 21.7
DAY_OF_WEEK READING_SESSIONS AVG_READING_MINUTES
----------- ---------------- -------------------
Monday                    41                15.7
Tuesday                   35                21.7
Wednesday                 51                17.3
Thursday                  31                13.6
Friday                    35                21.7
Saturday                  36                28.2
Sunday                    34                37.7

7 rows selected.
*/

-- =====================================================================
-- Query 2 (Business Goal 2)
-- English: List the top 10 chefs who, on average, received the most likes
--          per recipe across all their cookbook recipes published in 2025.
-- =====================================================================
WITH recipes_2025 AS (
       SELECT r.COOKBOOK_ID, r.RECIPE_NUMBER, cb.CHEF_MAV_ID
       FROM   DASC5306_Fall26_S001_T4_Recipe   r
       JOIN   DASC5306_Fall26_S001_T4_Cookbook cb ON cb.COOKBOOK_ID = r.COOKBOOK_ID
       WHERE  EXTRACT(YEAR FROM r.date_of_publish) = 2025
     ),
     recipe_likes AS (
       SELECT COOKBOOK_ID, RECIPE_NUMBER, COUNT(*) AS num_likes
       FROM   DASC5306_Fall26_S001_T4_Like_Dislike
       WHERE  interaction_type = 'Like'
       GROUP  BY COOKBOOK_ID, RECIPE_NUMBER
     )
SELECT u.first_name || ' ' || u.last_name              AS chef_name,
       ch.chef_id,
       COUNT(*)                                        AS recipes_2025,
       NVL(SUM(l.num_likes), 0)                        AS total_likes,
       ROUND(NVL(SUM(l.num_likes), 0) / COUNT(*), 2)   AS avg_likes_per_recipe
FROM   recipes_2025 r
LEFT   JOIN recipe_likes l
       ON l.COOKBOOK_ID = r.COOKBOOK_ID AND l.RECIPE_NUMBER = r.RECIPE_NUMBER
JOIN   DASC5306_Fall26_S001_T4_Chef ch ON ch.CHEF_MAV_ID = r.CHEF_MAV_ID
JOIN   DASC5306_Fall26_S001_T4_User u  ON u.MAV_ID       = ch.CHEF_MAV_ID
GROUP  BY u.first_name, u.last_name, ch.chef_id
ORDER  BY avg_likes_per_recipe DESC, total_likes DESC, chef_name
FETCH  FIRST 10 ROWS ONLY;

/* Expected output (before update):
CHEF_NAME               CHEF_ID RECIPES_2025 TOTAL_LIKES AVG_LIKES_PER_RECIPE
-------------------- ---------- ------------ ----------- --------------------
Fatima Ali                 5013            2           9                  4.5
Kwame Mensah               5008            1           3                    3
Amara Eze                  5017            5          10                    2
Chloe Bennett              5011            2           4                    2
Noah Kim                   5018            2           4                    2
Gabriel Costa              5016            1           2                    2
Ethan Walker               5014            2           3                  1.5
Hamid Karimi               5020            2           3                  1.5
Grace Owens                5021            2           2                    1
Hannah Brooks              5003            2           2                    1

10 rows selected.
*/

/* Expected output (after projectDBupdate.sql):
   Why it changed: I2 adds 2 likes to Kwame Mensah's 2025 recipe (now 1st); D2 deletes Gabriel Costa's cookbook (drops out)
CHEF_NAME               CHEF_ID RECIPES_2025 TOTAL_LIKES AVG_LIKES_PER_RECIPE
-------------------- ---------- ------------ ----------- --------------------
Kwame Mensah               5008            1           5                    5
Fatima Ali                 5013            2           9                  4.5
Amara Eze                  5017            5          10                    2
Chloe Bennett              5011            2           4                    2
Noah Kim                   5018            2           4                    2
Ethan Walker               5014            2           3                  1.5
Hamid Karimi               5020            2           3                  1.5
Grace Owens                5021            2           2                    1
Hannah Brooks              5003            2           2                    1
Tariq Aziz                 5022            2           2                    1

10 rows selected.
*/

-- =====================================================================
-- Query 3 (Business Goal 3)
-- English: For each year of birth, list the most popular meal type along with
--          its average recipe cooking time. Popularity = total number of reads
--          the recipes of that meal type received from home cooks born that year.
-- =====================================================================
WITH year_meal AS (
       SELECT EXTRACT(YEAR FROM u.date_of_birth) AS birth_year,
              r.meal_type,
              COUNT(*)                           AS total_reads,
              ROUND(AVG(r.cook_time), 1)         AS avg_cook_time_min
       FROM   DASC5306_Fall26_S001_T4_Read   rd
       JOIN   DASC5306_Fall26_S001_T4_User   u ON u.MAV_ID = rd.HOMECOOK_MAV_ID
       JOIN   DASC5306_Fall26_S001_T4_Recipe r ON r.COOKBOOK_ID   = rd.COOKBOOK_ID
                                              AND r.RECIPE_NUMBER = rd.RECIPE_NUMBER
       GROUP  BY EXTRACT(YEAR FROM u.date_of_birth), r.meal_type
     ),
     ranked AS (
       SELECT y.birth_year, y.meal_type, y.total_reads, y.avg_cook_time_min,
              RANK() OVER (PARTITION BY y.birth_year ORDER BY y.total_reads DESC) AS rnk
       FROM   year_meal y
     )
SELECT birth_year, meal_type, total_reads, avg_cook_time_min
FROM   ranked
WHERE  rnk = 1
ORDER  BY birth_year;

/* Expected output (before update):
BIRTH_YEAR MEAL_TYPE  TOTAL_READS AVG_COOK_TIME_MIN
---------- ---------- ----------- -----------------
      1998 Lunch                6              13.8
      1999 Brunch               6                20
      2000 Dinner              28              18.7
      2001 Lunch               26              14.1
      2002 Breakfast           27              10.1
      2003 Dessert             25                29
      2004 Snacks              20              11.9
      2005 Brunch              10                18

8 rows selected.
*/

/* Expected output (after projectDBupdate.sql):
   Why it changed: I1: Omar Haddad (born 1998) reads 6 dinner recipes -> 1998 changes from Lunch to Dinner
BIRTH_YEAR MEAL_TYPE  TOTAL_READS AVG_COOK_TIME_MIN
---------- ---------- ----------- -----------------
      1998 Dinner               7              23.1
      1999 Brunch               6                20
      2000 Dinner              28              18.9
      2001 Lunch               24              13.6
      2002 Breakfast           27              10.1
      2003 Dessert             25                29
      2004 Snacks              20              11.9
      2005 Brunch              10                18

8 rows selected.
*/

-- =====================================================================
-- Query 4 (Business Goal 4)
-- English: List the name, cuisine, number of recipes, and the average number of
--          reads per recipe for the cookbooks that have ONLY been read by students
--          from the 'CSE' department enrolled after July 2024. Order the list by
--          the average number of reads per recipe, highest first.
-- =====================================================================
WITH recipe_count AS (
       SELECT COOKBOOK_ID, COUNT(*) AS num_recipes
       FROM   DASC5306_Fall26_S001_T4_Recipe
       GROUP  BY COOKBOOK_ID
     ),
     read_count AS (
       SELECT COOKBOOK_ID, COUNT(*) AS num_reads
       FROM   DASC5306_Fall26_S001_T4_Read
       GROUP  BY COOKBOOK_ID
     )
SELECT cb.cookbook_name,
       cb.primary_cuisine,
       rc.num_recipes,
       ROUND(rdc.num_reads / rc.num_recipes, 2) AS avg_reads_per_recipe
FROM   DASC5306_Fall26_S001_T4_Cookbook cb
JOIN   recipe_count rc  ON rc.COOKBOOK_ID  = cb.COOKBOOK_ID
JOIN   read_count   rdc ON rdc.COOKBOOK_ID = cb.COOKBOOK_ID      -- read at least once
WHERE  NOT EXISTS (                                              -- no reader outside the group
         SELECT 1
         FROM   DASC5306_Fall26_S001_T4_Read rd
         JOIN   DASC5306_Fall26_S001_T4_User u ON u.MAV_ID = rd.HOMECOOK_MAV_ID
         WHERE  rd.COOKBOOK_ID = cb.COOKBOOK_ID
         AND    NOT (u.enrolled_department = 'CSE'
                     AND u.date_of_enrollment > DATE '2024-07-31')
       )
ORDER  BY avg_reads_per_recipe DESC;

/* Expected output (before update):
COOKBOOK_NAME                  PRIMARY_CUISINE NUM_RECIPES AVG_READS_PER_RECIPE
------------------------------ --------------- ----------- --------------------
Code & Curry                   Indian                    2                  3.5
Midnight Mexican Snacks        Mexican                   2                  1.5

2 rows selected.
*/

/* Expected output (after projectDBupdate.sql):
   Why it changed: I3: a Nursing student reads 'Midnight Mexican Snacks' (removed); more CSE reads of 'Code & Curry' (3.5 -> 4.5)
COOKBOOK_NAME                  PRIMARY_CUISINE NUM_RECIPES AVG_READS_PER_RECIPE
------------------------------ --------------- ----------- --------------------
Code & Curry                   Indian                    2                  4.5

1 row selected.
*/

-- =====================================================================
-- Query 5 (Business Goal 5)
-- English: Who are the student subscribers who have read every recipe from the
--          Indian or Korean cuisine cookbooks that have the phrase 'campfire kitchen'
--          somewhere in the description? Find their name, GPA, nationality, and email.
--          (A subscriber of at least one such cookbook, who read every recipe of all of them.)
-- =====================================================================
SELECT u.first_name || ' ' || u.last_name AS student_name,
       u.cumulative_GPA,
       u.nationality,
       u.email
FROM   DASC5306_Fall26_S001_T4_User u
WHERE  EXISTS (                                    -- is a subscriber of such a cookbook
         SELECT 1
         FROM   DASC5306_Fall26_S001_T4_Subscribe s
         JOIN   DASC5306_Fall26_S001_T4_Cookbook  cb ON cb.COOKBOOK_ID = s.COOKBOOK_ID
         WHERE  s.HOMECOOK_MAV_ID = u.MAV_ID
         AND    cb.primary_cuisine IN ('Indian', 'Korean')
         AND    LOWER(cb.description) LIKE '%campfire kitchen%'
       )
AND    NOT EXISTS (                                -- there is no such recipe ...
         SELECT 1
         FROM   DASC5306_Fall26_S001_T4_Recipe   r
         JOIN   DASC5306_Fall26_S001_T4_Cookbook cb ON cb.COOKBOOK_ID = r.COOKBOOK_ID
         WHERE  cb.primary_cuisine IN ('Indian', 'Korean')
         AND    LOWER(cb.description) LIKE '%campfire kitchen%'
         AND    NOT EXISTS (                       -- ... that this student has not read
                  SELECT 1
                  FROM   DASC5306_Fall26_S001_T4_Read rd
                  WHERE  rd.HOMECOOK_MAV_ID = u.MAV_ID
                  AND    rd.COOKBOOK_ID     = r.COOKBOOK_ID
                  AND    rd.RECIPE_NUMBER   = r.RECIPE_NUMBER
                )
       )
ORDER  BY student_name;

/* Expected output (before update):
STUDENT_NAME         CUMULATIVE_GPA NATIONALITY  EMAIL
-------------------- -------------- ------------ ------------------------------
Arjun Patel                    3.85 India        arjun.patel@mavs.uta.edu
Priya Sharma                   3.58 India        priya.sharma@mavs.uta.edu

2 rows selected.
*/

/* Expected output (after projectDBupdate.sql):
   Why it changed: D1: Arjun Patel unsubscribes (removed); I4: Linh Nguyen reads her missing recipe (added)
STUDENT_NAME         CUMULATIVE_GPA NATIONALITY  EMAIL
-------------------- -------------- ------------ ------------------------------
Linh Nguyen                    3.48 Vietnam      linh.nguyen@mavs.uta.edu
Priya Sharma                   3.58 India        priya.sharma@mavs.uta.edu

2 rows selected.
*/

-- =====================================================================
-- Query 6 (Business Goal 6, added by the team)
-- English: List the names, websites, and advertised grocery items of merchants whose
--          company headquarter city is 'Arlington' and who have at least one campaign
--          on the platform, so these local campaigns can be highlighted to students.
-- =====================================================================
SELECT m.merchant_name,
       m.website,
       c.advertised_grocery_item_name
FROM   DASC5306_Fall26_S001_T4_Merchant m
JOIN   DASC5306_Fall26_S001_T4_Campaign c
       ON c.MERCHANT_REGISTRATION_NUMBER = m.REGISTRATION_NUMBER   -- inner join = at least one campaign
WHERE  m.headquarter_city = 'Arlington'
ORDER  BY m.merchant_name, c.advertised_grocery_item_name;

/* Expected output (before update):
MERCHANT_NAME                WEBSITE                              ADVERTISED_GROCERY_ITEM_NAME
---------------------------- ------------------------------------ ----------------------------
Cedar Creek Coffee           https://www.cedarcreekcoffee.com     Medium Roast Coffee Beans
Harvest Basket               https://www.harvestbasket.com        Russet Potatoes (5 lb)
Prairie Pantry               https://www.prairiepantry.com        All-Purpose Flour

3 rows selected.
*/

/* Expected output (after projectDBupdate.sql):
   Why it changed: I5: Mav Market Co-op (Arlington) launches its first campaign
MERCHANT_NAME                WEBSITE                              ADVERTISED_GROCERY_ITEM_NAME
---------------------------- ------------------------------------ ----------------------------
Cedar Creek Coffee           https://www.cedarcreekcoffee.com     Medium Roast Coffee Beans
Harvest Basket               https://www.harvestbasket.com        Russet Potatoes (5 lb)
Mav Market Co-op             https://www.mavmarketcoop.com        Local Farm Eggs
Prairie Pantry               https://www.prairiepantry.com        All-Purpose Flour

4 rows selected.
*/

-- =====================================================================
-- Query 7 (Business Goal 7, added by the team)
-- English: For each merchant, list the total display cost paid to the platform and the
--          total cashback owed (each campaign's cashback rate per read multiplied by the
--          number of reads of every recipe it appears on). Report the net amount
--          (display cost - cashback) and order by ascending net amount, so merchants
--          that collect more than they pay appear first.
-- =====================================================================
WITH recipe_reads AS (
       SELECT COOKBOOK_ID, RECIPE_NUMBER, COUNT(*) AS num_reads
       FROM   DASC5306_Fall26_S001_T4_Read
       GROUP  BY COOKBOOK_ID, RECIPE_NUMBER
     )
SELECT m.merchant_name,
       SUM(d.display_cost)                                        AS total_display_cost,
       SUM(c.cashback_rate_per_read * NVL(rr.num_reads, 0))       AS total_cashback,
       SUM(d.display_cost)
         - SUM(c.cashback_rate_per_read * NVL(rr.num_reads, 0))   AS net_amount
FROM   DASC5306_Fall26_S001_T4_Display_On d
JOIN   DASC5306_Fall26_S001_T4_Campaign   c
       ON  c.MERCHANT_REGISTRATION_NUMBER = d.MERCHANT_REGISTRATION_NUMBER
       AND c.CAMPAIGN_NUMBER              = d.CAMPAIGN_NUMBER
JOIN   DASC5306_Fall26_S001_T4_Merchant   m
       ON  m.REGISTRATION_NUMBER = d.MERCHANT_REGISTRATION_NUMBER
LEFT   JOIN recipe_reads rr
       ON  rr.COOKBOOK_ID   = d.COOKBOOK_ID
       AND rr.RECIPE_NUMBER = d.RECIPE_NUMBER
GROUP  BY m.merchant_name
ORDER  BY net_amount, m.merchant_name;

/* Expected output (before update):
MERCHANT_NAME                TOTAL_DISPLAY_COST TOTAL_CASHBACK NET_AMOUNT
---------------------------- ------------------ -------------- ----------
Spice Route Imports                           2              9         -7
Metro Meat & Seafood                        2.5              6       -3.5
Gulf Coast Seafood                            3           5.85      -2.85
Lone Star Grocers                           1.5              3       -1.5
Bayou Sauce Works                         19.67              0      19.67
Cedar Creek Coffee                         24.7            1.5       23.2
Pecan Valley Farms                         25.6            1.1       24.5
Prairie Pantry                            46.24            2.3      43.94
Golden Grain Bakery Supply                49.45              1      48.45
Tex-Mex Pantry                            52.12             .9      51.22
Harvest Basket                            61.98            2.7      59.28
Nature's Table                            70.55              8      62.55
Rio Grande Foods                          64.97            2.4      62.57
Sunrise Produce                           67.78            4.2      63.58
Panhandle Pasta Co                        65.24              1      64.24
Hill Country Honey                        74.43           8.55      65.88
Maple & Oak Creamery                      74.61           2.16      72.45
Red River Beverages                       77.65            2.4      75.25
GreenLeaf Organics                         81.7            2.4       79.3
Urban Spice Co                           120.05           10.4     109.65
Blue Bonnet Dairy                         147.6            5.4      142.2
FreshCart Market                         168.41            3.9     164.51

22 rows selected.
*/

/* Expected output (after projectDBupdate.sql):
   Why it changed: U2 renegotiates Spice Route and Metro Meat (now positive); I5 adds Mav Market Co-op
MERCHANT_NAME                TOTAL_DISPLAY_COST TOTAL_CASHBACK NET_AMOUNT
---------------------------- ------------------ -------------- ----------
Gulf Coast Seafood                            3           7.15      -4.15
Lone Star Grocers                           1.5              3       -1.5
Metro Meat & Seafood                        2.5              2         .5
Mav Market Co-op                             18            2.6       15.4
Spice Route Imports                          25              9         16
Bayou Sauce Works                         19.67              0      19.67
Cedar Creek Coffee                         24.7            1.5       23.2
Pecan Valley Farms                         25.6            1.1       24.5
Prairie Pantry                            46.24            2.3      43.94
Golden Grain Bakery Supply                49.45              1      48.45
Tex-Mex Pantry                            52.12             .9      51.22
Harvest Basket                            61.98            2.7      59.28
Nature's Table                            70.55            8.8      61.75
Rio Grande Foods                          64.97            2.4      62.57
Sunrise Produce                           67.78           4.55      63.23
Panhandle Pasta Co                        65.24            1.2      64.04
Hill Country Honey                        74.43           8.55      65.88
Maple & Oak Creamery                      74.61           2.16      72.45
Red River Beverages                       77.65            2.7      74.95
GreenLeaf Organics                         81.7            2.4       79.3
Urban Spice Co                           120.05           10.4     109.65
Blue Bonnet Dairy                         147.6            5.4      142.2
FreshCart Market                         168.41            3.9     164.51

23 rows selected.
*/
