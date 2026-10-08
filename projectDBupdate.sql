-- projectDBupdate.sql: MavDine database (Team 4, DASC5306 Fall 2026, Section 001)
-- Changes the database through a series of inserts, updates and deletes, so that running
-- projectDBqueries.sql again gives DIFFERENT results for the same queries.
-- Run order: drop -> create -> insert -> queries -> UPDATE (this file) -> queries again.
--
-- Every change below says which query it affects and how. All inserts respect the
-- primary/foreign keys and the triggers (a read is never in the future or before the
-- recipe was published, and a like is only inserted after a matching read).

SET DEFINE OFF

-- =====================================================================
-- U1 (UPDATE) Two reading sessions that were still open (end_time NULL) are finished.
--    Affects Query 1: they now count toward the Tuesday and Wednesday averages.
-- =====================================================================
UPDATE DASC5306_Fall26_S001_T4_Read
SET    end_time = TIMESTAMP '2026-10-06 20:57:00'
WHERE  HOMECOOK_MAV_ID = '1001000004' AND COOKBOOK_ID = 9 AND RECIPE_NUMBER = 1
AND    start_time = TIMESTAMP '2026-10-06 20:15:00';
UPDATE DASC5306_Fall26_S001_T4_Read
SET    end_time = TIMESTAMP '2026-10-07 22:22:00'
WHERE  HOMECOOK_MAV_ID = '1001000017' AND COOKBOOK_ID = 25 AND RECIPE_NUMBER = 1
AND    start_time = TIMESTAMP '2026-10-07 21:40:00';

-- =====================================================================
-- I1 (INSERT) Omar Haddad (born 1998) reads six dinner recipes, 55 minutes each, on Tuesday evenings.
--    Affects Query 1 (Tuesday average rises) and Query 3 (1998's favourite meal type changes from Lunch to Dinner).
-- =====================================================================
INSERT INTO DASC5306_Fall26_S001_T4_Read (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 1, 2, TIMESTAMP '2026-09-01 19:30:00', TIMESTAMP '2026-09-01 20:25:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 2, 2, TIMESTAMP '2026-09-08 19:30:00', TIMESTAMP '2026-09-08 20:25:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 4, 2, TIMESTAMP '2026-09-15 19:30:00', TIMESTAMP '2026-09-15 20:25:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 5, 2, TIMESTAMP '2026-09-22 19:30:00', TIMESTAMP '2026-09-22 20:25:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 8, 3, TIMESTAMP '2026-09-29 19:30:00', TIMESTAMP '2026-09-29 20:25:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 12, 1, TIMESTAMP '2026-10-06 19:30:00', TIMESTAMP '2026-10-06 20:25:00', 'Home');

-- =====================================================================
-- I2 (INSERT) Two more home cooks like Kwame Mensah's 2025 recipe 'Baked Lemon Salmon' (cookbook 8, recipe 3).
--    Ayesha Khan reads it first, because trigger T5 only allows a like after a read.
--    Affects Query 2: Kwame Mensah's average rises from 3 to 5 likes per recipe and he moves to first place.
-- =====================================================================
INSERT INTO DASC5306_Fall26_S001_T4_Read (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000007', 8, 3, TIMESTAMP '2026-09-19 12:10:00', TIMESTAMP '2026-09-19 12:28:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type)
VALUES ('1001000018', 8, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type)
VALUES ('1001000007', 8, 3, 'Like');

-- =====================================================================
-- I3 (INSERT) Sofia Ramirez (Nursing) reads 'Midnight Mexican Snacks', and Bikash Thapa (CSE, enrolled 2024-08)
--    reads both 'Code & Curry' recipes again.
--    Affects Query 4: 'Midnight Mexican Snacks' is no longer read ONLY by new CSE students, so it disappears,
--    and 'Code & Curry' rises from 3.5 to 4.5 reads per recipe.
-- =====================================================================
INSERT INTO DASC5306_Fall26_S001_T4_Read (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 21, 1, TIMESTAMP '2026-09-26 23:15:00', TIMESTAMP '2026-09-26 23:24:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 20, 1, TIMESTAMP '2026-09-16 22:40:00', TIMESTAMP '2026-09-16 22:54:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 20, 2, TIMESTAMP '2026-09-23 22:05:00', TIMESTAMP '2026-09-23 22:17:00', 'Engineering Research Building');

-- =====================================================================
-- D1 (DELETE) Arjun Patel unsubscribes from both 'campfire kitchen' cookbooks (3 and 7).
-- I4 (INSERT) Linh Nguyen reads the one campfire recipe she had missed (cookbook 7, recipe 2).
--    Affects Query 5: Arjun Patel is no longer a subscriber, so he drops out; Linh Nguyen has now read every
--    such recipe and is a subscriber, so she is added. Result changes from {Arjun, Priya} to {Linh, Priya}.
-- =====================================================================
DELETE FROM DASC5306_Fall26_S001_T4_Subscribe
WHERE  HOMECOOK_MAV_ID = '1001000002' AND COOKBOOK_ID IN (3, 7);
INSERT INTO DASC5306_Fall26_S001_T4_Read (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 7, 2, TIMESTAMP '2026-09-12 18:20:00', TIMESTAMP '2026-09-12 18:44:00', 'Home');

-- =====================================================================
-- I5 (INSERT) Arlington merchant 'Mav Market Co-op' launches its first campaign ('Local Farm Eggs')
--    and displays it on 'French Toast' (cookbook 17, recipe 1), which uses eggs.
--    Affects Query 6 (a 4th Arlington merchant appears) and Query 7 (a new merchant row).
-- =====================================================================
INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000023', 1, 'Local Farm Eggs', 'Eggs', 'https://www.mavmarketcoop.com/campaigns/local-farm-eggs', 0.20);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (17, 1, '2000000023', 1, 18.00);

-- =====================================================================
-- U2 (UPDATE) The platform renegotiates its two worst deals (the purpose of Business Goal 7):
--    Spice Route Imports now pays 25.00 instead of 2.00 to show 'Saffron Threads' on 'Saffron Rice Pudding',
--    and Metro Meat & Seafood's cashback for 'Gulf Shrimp' drops from 0.60 to 0.20 per read.
--    Affects Query 7: both merchants move from a negative to a positive net amount.
-- =====================================================================
UPDATE DASC5306_Fall26_S001_T4_Display_On
SET    display_cost = 25.00
WHERE  COOKBOOK_ID = 12 AND RECIPE_NUMBER = 3
AND    MERCHANT_REGISTRATION_NUMBER = '2000000017' AND CAMPAIGN_NUMBER = 2;
UPDATE DASC5306_Fall26_S001_T4_Campaign
SET    cashback_rate_per_read = 0.20
WHERE  MERCHANT_REGISTRATION_NUMBER = '2000000011' AND CAMPAIGN_NUMBER = 1;

-- =====================================================================
-- D2 (DELETE) Chef Gabriel Costa deletes his cookbook 'Thai Campfire Kitchen' (cookbook 16).
--    ON DELETE CASCADE also removes its 2 recipes, 3 reads, 3 likes/dislikes, 0 subscriptions and 0 ad placements.
--    Affects Query 2 (Gabriel Costa had a 2025 recipe and drops out of the top 10), and Queries 1 and 3 slightly.
-- =====================================================================
DELETE FROM DASC5306_Fall26_S001_T4_Cookbook
WHERE  COOKBOOK_ID = 16;

COMMIT;
