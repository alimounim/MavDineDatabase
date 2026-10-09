-- projectDBinsert.sql: MavDine database (DASC5306 Fall 2026, Section 001)
-- Fills every table with realistic sample data, parents before children (Level 0 -> Level 4),
-- so every foreign key value already exists when a child row is inserted.
--
-- ID plan (keeps all foreign keys consistent):
--   Users      MAV_ID 1001000001 - 1001000030   (30 users)
--   Homecooks  users  1001000001 - 1001000022   (22 homecooks)
--   Chefs      users  1001000009 - 1001000030   (22 chefs, chef_id 5001 - 5022)
--              users  1001000009 - 1001000022 are both homecook and chef
--   Merchants  REGISTRATION_NUMBER 2000000001 - 2000000023   (23 merchants)
--   Cookbooks  COOKBOOK_ID 1 - 25 (every chef owns at least one); recipes numbered from 1 per cookbook
--
-- Rules the data respects (constraints + triggers in projectDBcreate.sql):
--   every user is 18+, no date is in the future, enrollment is after birth, GPA is 0.00 - 4.00,
--   a recipe is published on/after its cookbook's creation, a read starts on/after the recipe's
--   publish date, and every Like/Dislike has a matching Read (so Read is inserted before Like_Dislike).
--
-- Data shaped for the business goals (Phase 0):
--   Goal 1  reads spread over every day of the week, with end times
--   Goal 2  recipes published in 2025 by 16 different chefs, with likes
--   Goal 3  homecooks born in different years favour different meal types
--   Goal 4  cookbooks 20 and 21 are read only by CSE students enrolled after July 2024 (users 6, 10, 22);
--           cookbook 22 is also read by user 1 (CSE, enrolled 2023), so it is excluded
--   Goal 5  cookbooks 3 (Indian) and 7 (Korean) contain 'campfire kitchen'; users 2 and 13 subscribe
--           and read every recipe of both; users 5, 16 and 19 are near-misses
--   Goal 6  merchants 4, 5, 14 and 23 are headquartered in Arlington (23 has no campaign yet)
--   Goal 7  cheap placements on heavily read recipes give some merchants a negative net amount
--   cashback_rate_per_read is in dollars per read.

-- Without this, SQL*Plus treats '&' in text (e.g. 'Metro Meat & Seafood') as a variable prompt.
SET DEFINE OFF

-- ===================== Level 0 =====================

-- User (30 rows)
INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000001', 'ecarter', 'emily.carter@mavs.uta.edu', 'pw_hash_01', '817-555-0101', DATE '2023-08-21', 3.62,
     'CSE', 'USA', DATE '2004-03-14', 'Emily', 'Carter',
     '701 S Nedderman Dr', '210', 'Arlington', 'Tarrant', '76019');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000002', 'apatel', 'arjun.patel@mavs.uta.edu', 'pw_hash_02', '682-555-0102', DATE '2024-01-16', 3.85,
     'Data Science', 'India', DATE '2001-07-09', 'Arjun', 'Patel',
     '500 Summit Ave', '3B', 'Arlington', 'Tarrant', '76013');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000003', 'sramirez', 'sofia.ramirez@mavs.uta.edu', 'pw_hash_03', '817-555-0103', DATE '2022-08-22', 3.10,
     'Nursing', 'Mexico', DATE '2003-11-02', 'Sofia', 'Ramirez',
     '1201 W Mitchell St', NULL, 'Arlington', 'Tarrant', '76013');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000004', 'dokafor', 'david.okafor@mavs.uta.edu', 'pw_hash_04', '469-555-0104', DATE '2023-01-17', 2.95,
     'Mechanical Engineering', 'Nigeria', DATE '2002-05-27', 'David', 'Okafor',
     '2500 Commerce St', '1407', 'Dallas', 'Dallas', '75226');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000005', 'lnguyen', 'linh.nguyen@mavs.uta.edu', 'pw_hash_05', '817-555-0105', DATE '2021-08-23', 3.48,
     'Biology', 'Vietnam', DATE '2000-09-18', 'Linh', 'Nguyen',
     '900 Spaniolo Dr', '12', 'Arlington', 'Tarrant', '76010');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000006', 'wzhang', 'wei.zhang@mavs.uta.edu', 'pw_hash_06', NULL, DATE '2024-08-19', 3.91,
     'CSE', 'China', DATE '2002-02-11', 'Wei', 'Zhang',
     '411 S Cooper St', '205', 'Arlington', 'Tarrant', '76013');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000007', 'akhan', 'ayesha.khan@mavs.uta.edu', 'pw_hash_07', '682-555-0107', DATE '2022-01-18', 3.27,
     'Business Analytics', 'Pakistan', DATE '1999-12-05', 'Ayesha', 'Khan',
     '2200 W Park Row Dr', NULL, 'Arlington', 'Tarrant', '76013');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000008', 'lsilva', 'lucas.silva@mavs.uta.edu', 'pw_hash_08', '817-555-0108', DATE '2023-08-21', 2.76,
     'Civil Engineering', 'Brazil', DATE '2003-04-30', 'Lucas', 'Silva',
     '3100 S Collins St', '118', 'Arlington', 'Tarrant', '76014');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000009', 'srahimi', 'sara.rahimi@mavs.uta.edu', 'pw_hash_09', '214-555-0109', DATE '2025-01-21', 3.70,
     'Data Science', 'Iran', DATE '2000-06-22', 'Sara', 'Rahimi',
     '600 E Las Colinas Blvd', '902', 'Irving', 'Dallas', '75039');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000010', 'bthapa', 'bikash.thapa@mavs.uta.edu', 'pw_hash_10', '817-555-0110', DATE '2024-08-19', 3.33,
     'CSE', 'Nepal', DATE '2001-10-13', 'Bikash', 'Thapa',
     '1000 Greek Row Dr', '7', 'Arlington', 'Tarrant', '76013');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000011', 'hbrooks', 'hannah.brooks@mavs.uta.edu', 'pw_hash_11', '817-555-0111', DATE '2021-08-23', 3.95,
     'Psychology', 'USA', DATE '2002-01-25', 'Hannah', 'Brooks',
     '4000 Matlock Rd', NULL, 'Arlington', 'Tarrant', '76015');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000012', 'mjohnson', 'marcus.johnson@mavs.uta.edu', 'pw_hash_12', '682-555-0112', DATE '2022-08-22', 2.64,
     'Accounting', 'USA', DATE '2003-08-08', 'Marcus', 'Johnson',
     '300 Main St', '1520', 'Fort Worth', 'Tarrant', '76102');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000013', 'psharma', 'priya.sharma@mavs.uta.edu', 'pw_hash_13', '469-555-0113', DATE '2023-01-17', 3.58,
     'Business Analytics', 'India', DATE '2001-03-03', 'Priya', 'Sharma',
     '1800 W Pioneer Pkwy', '22', 'Grand Prairie', 'Dallas', '75051');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000014', 'dhernandez', 'diego.hernandez@mavs.uta.edu', 'pw_hash_14', '817-555-0114', DATE '2024-01-16', 3.05,
     'Mechanical Engineering', 'Mexico', DATE '2004-12-19', 'Diego', 'Hernandez',
     '1500 E Lamar Blvd', '310', 'Arlington', 'Tarrant', '76011');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000015', 'omartin', 'olivia.martin@mavs.uta.edu', 'pw_hash_15', NULL, DATE '2022-08-22', 3.81,
     'Nursing', 'USA', DATE '2003-06-11', 'Olivia', 'Martin',
     '1100 E Broad St', NULL, 'Mansfield', 'Tarrant', '76063');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000016', 'kmensah', 'kwame.mensah@mavs.uta.edu', 'pw_hash_16', '214-555-0116', DATE '2023-08-21', 3.12,
     'Electrical Engineering', 'Ghana', DATE '2001-09-29', 'Kwame', 'Mensah',
     '1717 Main St', '804', 'Dallas', 'Dallas', '75201');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000017', 'mtran', 'mai.tran@mavs.uta.edu', 'pw_hash_17', '817-555-0117', DATE '2025-08-18', 3.44,
     'Biology', 'Vietnam', DATE '2005-02-07', 'Mai', 'Tran',
     '701 S Nedderman Dr', '118', 'Arlington', 'Tarrant', '76019');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000018', 'ohaddad', 'omar.haddad@mavs.uta.edu', 'pw_hash_18', '682-555-0118', DATE '2021-01-19', 2.88,
     'Civil Engineering', 'Jordan', DATE '1998-11-15', 'Omar', 'Haddad',
     '2200 W Park Row Dr', '14', 'Arlington', 'Tarrant', '76013');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000019', 'cbennett', 'chloe.bennett@mavs.uta.edu', 'pw_hash_19', '817-555-0119', DATE '2024-08-19', 3.67,
     'Psychology', 'USA', DATE '2005-07-21', 'Chloe', 'Bennett',
     '500 Summit Ave', '1C', 'Arlington', 'Tarrant', '76013');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000020', 'riyer', 'ravi.iyer@mavs.uta.edu', 'pw_hash_20', '469-555-0120', DATE '2023-08-21', 3.99,
     'CSE', 'India', DATE '2000-04-16', 'Ravi', 'Iyer',
     '600 E Las Colinas Blvd', '1105', 'Irving', 'Dallas', '75039');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000021', 'fali', 'fatima.ali@mavs.uta.edu', 'pw_hash_21', '817-555-0121', DATE '2022-01-18', 3.21,
     'Accounting', 'Pakistan', DATE '2002-10-01', 'Fatima', 'Ali',
     '3100 S Collins St', NULL, 'Arlington', 'Tarrant', '76014');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000022', 'ewalker', 'ethan.walker@mavs.uta.edu', 'pw_hash_22', '817-555-0122', DATE '2025-01-21', 2.53,
     'CSE', 'USA', DATE '2004-08-26', 'Ethan', 'Walker',
     '411 S Cooper St', '402', 'Arlington', 'Tarrant', '76013');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000023', 'ytanaka', 'yuki.tanaka@mavs.uta.edu', 'pw_hash_23', '682-555-0123', DATE '2023-01-17', 3.76,
     'Electrical Engineering', 'Japan', DATE '2001-12-30', 'Yuki', 'Tanaka',
     '1000 Greek Row Dr', '3', 'Arlington', 'Tarrant', '76013');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000024', 'gcosta', 'gabriel.costa@mavs.uta.edu', 'pw_hash_24', NULL, DATE '2024-01-16', 3.09,
     'Business Analytics', 'Brazil', DATE '2000-03-17', 'Gabriel', 'Costa',
     '300 Main St', '907', 'Fort Worth', 'Tarrant', '76102');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000025', 'aeze', 'amara.eze@mavs.uta.edu', 'pw_hash_25', '214-555-0125', DATE '2022-08-22', 3.55,
     'Nursing', 'Nigeria', DATE '2003-05-05', 'Amara', 'Eze',
     '1717 Main St', '1210', 'Dallas', 'Dallas', '75201');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000026', 'nkim', 'noah.kim@mavs.uta.edu', 'pw_hash_26', '817-555-0126', DATE '2021-08-23', 3.38,
     'Mechanical Engineering', 'South Korea', DATE '1999-08-12', 'Noah', 'Kim',
     '900 Spaniolo Dr', '5', 'Arlington', 'Tarrant', '76010');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000027', 'ilopez', 'isabella.lopez@mavs.uta.edu', 'pw_hash_27', '817-555-0127', DATE '2025-08-18', 3.90,
     'Biology', 'USA', DATE '2006-01-09', 'Isabella', 'Lopez',
     '1201 W Mitchell St', '2A', 'Arlington', 'Tarrant', '76013');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000028', 'hkarimi', 'hamid.karimi@mavs.uta.edu', 'pw_hash_28', '682-555-0128', DATE '2023-08-21', 3.15,
     'CSE', 'Afghanistan', DATE '2002-06-28', 'Hamid', 'Karimi',
     '1800 W Pioneer Pkwy', '40', 'Grand Prairie', 'Dallas', '75051');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000029', 'gowens', 'grace.owens@mavs.uta.edu', 'pw_hash_29', '817-555-0129', DATE '2022-01-18', 3.72,
     'Psychology', 'USA', DATE '2001-11-23', 'Grace', 'Owens',
     '4000 Matlock Rd', '216', 'Arlington', 'Tarrant', '76015');

INSERT INTO DASC5306_Fall26_S001_T4_User
    (MAV_ID, username, email, password, phone_number, date_of_enrollment, cumulative_GPA,
     enrolled_department, nationality, date_of_birth, first_name, last_name,
     street_address, apartment_number, city, county, zip_code)
VALUES ('1001000030', 'taziz', 'tariq.aziz@mavs.uta.edu', 'pw_hash_30', '469-555-0130', DATE '2024-08-19', 2.97,
     'Civil Engineering', 'Egypt', DATE '2003-02-14', 'Tariq', 'Aziz',
     '2500 Commerce St', '611', 'Dallas', 'Dallas', '75226');

-- Merchant (23 rows)
INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000001', 'FreshCart Market', 'https://www.freshcartmarket.com', 1850, 'Dallas');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000002', 'GreenLeaf Organics', 'https://www.greenleaforganics.com', 420, 'Austin');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000003', 'Lone Star Grocers', 'https://www.lonestargrocers.com', 3200, 'Houston');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000004', 'Harvest Basket', 'https://www.harvestbasket.com', 960, 'Arlington');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000005', 'Prairie Pantry', 'https://www.prairiepantry.com', 310, 'Arlington');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000006', 'Urban Spice Co', 'https://www.urbanspiceco.com', 75, 'Dallas');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000007', 'Golden Grain Bakery Supply', 'https://www.goldengrainbakery.com', 540, 'San Antonio');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000008', 'Blue Bonnet Dairy', 'https://www.bluebonnetdairy.com', 1270, 'Waco');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000009', 'Pecan Valley Farms', 'https://www.pecanvalleyfarms.com', 230, 'Austin');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000010', 'Sunrise Produce', 'https://www.sunriseproduce.com', 680, 'Houston');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000011', 'Metro Meat & Seafood', 'https://www.metromeatseafood.com', 890, 'Dallas');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000012', 'Rio Grande Foods', 'https://www.riograndefoods.com', 2150, 'El Paso');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000013', 'Maple & Oak Creamery', 'https://www.mapleoakcreamery.com', 160, 'Plano');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000014', 'Cedar Creek Coffee', 'https://www.cedarcreekcoffee.com', 95, 'Arlington');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000015', 'Tex-Mex Pantry', 'https://www.texmexpantry.com', 350, 'San Antonio');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000016', 'Nature''s Table', 'https://www.naturestable.com', 510, 'Austin');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000017', 'Spice Route Imports', 'https://www.spicerouteimports.com', 120, 'Houston');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000018', 'Gulf Coast Seafood', 'https://www.gulfcoastseafood.com', 740, 'Corpus Christi');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000019', 'Hill Country Honey', 'https://www.hillcountryhoney.com', 45, 'Fredericksburg');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000020', 'Red River Beverages', 'https://www.redriverbeverages.com', 1430, 'Dallas');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000021', 'Panhandle Pasta Co', 'https://www.panhandlepasta.com', 260, 'Amarillo');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000022', 'Bayou Sauce Works', 'https://www.bayousauceworks.com', 180, 'Beaumont');

INSERT INTO DASC5306_Fall26_S001_T4_Merchant
    (REGISTRATION_NUMBER, merchant_name, website, number_of_employees, headquarter_city)
VALUES ('2000000023', 'Mav Market Co-op', 'https://www.mavmarketcoop.com', 38, 'Arlington');

-- ===================== Level 1 =====================

-- Homecook (22 rows): users 1001000001 - 1001000022
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000001');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000002');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000003');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000004');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000005');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000006');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000007');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000008');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000009');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000010');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000011');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000012');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000013');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000014');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000015');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000016');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000017');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000018');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000019');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000020');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000021');
INSERT INTO DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) VALUES ('1001000022');

-- Chef (22 rows): users 1001000009 - 1001000030, chef_id 5001 - 5022
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000009', 5001);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000010', 5002);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000011', 5003);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000012', 5004);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000013', 5005);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000014', 5006);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000015', 5007);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000016', 5008);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000017', 5009);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000018', 5010);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000019', 5011);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000020', 5012);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000021', 5013);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000022', 5014);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000023', 5015);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000024', 5016);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000025', 5017);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000026', 5018);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000027', 5019);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000028', 5020);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000029', 5021);
INSERT INTO DASC5306_Fall26_S001_T4_Chef (CHEF_MAV_ID, chef_id) VALUES ('1001000030', 5022);

-- Campaign (28 rows): campaign numbers restart at 1 for each merchant;
-- the category uses the same domain as recipe ingredients; cashback is dollars per read.
INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000001', 1, 'Organic Baby Spinach', 'Spinach',
     'https://www.freshcartmarket.com/campaigns/organic-baby-spinach', 0.20);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000001', 2, 'Whole Wheat Bread', 'Bread',
     'https://www.freshcartmarket.com/campaigns/whole-wheat-bread', 0.15);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000002', 1, 'Quinoa (2 lb bag)', 'Quinoa',
     'https://www.greenleaforganics.com/campaigns/quinoa-2-lb-bag', 0.30);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000003', 1, 'Long Grain White Rice', 'Rice',
     'https://www.lonestargrocers.com/campaigns/long-grain-white-rice', 0.30);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000003', 2, 'Chicken Breast Family Pack', 'Chicken',
     'https://www.lonestargrocers.com/campaigns/chicken-breast-family-pack', 0.35);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000003', 3, 'Large Brown Eggs', 'Eggs',
     'https://www.lonestargrocers.com/campaigns/large-brown-eggs', 0.12);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000004', 1, 'Russet Potatoes (5 lb)', 'Potatoes',
     'https://www.harvestbasket.com/campaigns/russet-potatoes-5-lb', 0.15);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000005', 1, 'All-Purpose Flour', 'Flour',
     'https://www.prairiepantry.com/campaigns/all-purpose-flour', 0.10);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000006', 1, 'Smoked Paprika', 'Paprika',
     'https://www.urbanspiceco.com/campaigns/smoked-paprika', 0.45);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000006', 2, 'Ground Cumin', 'Cumin',
     'https://www.urbanspiceco.com/campaigns/ground-cumin', 0.40);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000007', 1, 'Active Dry Yeast', 'Yeast',
     'https://www.goldengrainbakery.com/campaigns/active-dry-yeast', 0.25);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000008', 1, 'Whole Milk (1 gal)', 'Milk',
     'https://www.bluebonnetdairy.com/campaigns/whole-milk-1-gal', 0.12);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000008', 2, 'Sharp Cheddar Cheese', 'Cheddar',
     'https://www.bluebonnetdairy.com/campaigns/sharp-cheddar-cheese', 0.30);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000009', 1, 'Roasted Pecans', 'Pecans',
     'https://www.pecanvalleyfarms.com/campaigns/roasted-pecans', 0.55);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000010', 1, 'Hass Avocados', 'Avocado',
     'https://www.sunriseproduce.com/campaigns/hass-avocados', 0.35);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000011', 1, 'Gulf Shrimp (1 lb)', 'Shrimp',
     'https://www.metromeatseafood.com/campaigns/gulf-shrimp-1-lb', 0.60);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000012', 1, 'Corn Tortillas', 'Tortillas',
     'https://www.riograndefoods.com/campaigns/corn-tortillas', 0.20);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000013', 1, 'Unsalted Butter', 'Butter',
     'https://www.mapleoakcreamery.com/campaigns/unsalted-butter', 0.18);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000014', 1, 'Medium Roast Coffee Beans', 'Coffee',
     'https://www.cedarcreekcoffee.com/campaigns/medium-roast-coffee-beans', 0.50);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000015', 1, 'Salsa Verde', 'Salsa Verde',
     'https://www.texmexpantry.com/campaigns/salsa-verde', 0.30);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000016', 1, 'Extra Virgin Olive Oil', 'Olive Oil',
     'https://www.naturestable.com/campaigns/extra-virgin-olive-oil', 0.40);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000017', 1, 'Basmati Rice', 'Rice',
     'https://www.spicerouteimports.com/campaigns/basmati-rice', 0.25);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000017', 2, 'Saffron Threads', 'Saffron',
     'https://www.spicerouteimports.com/campaigns/saffron-threads', 0.75);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000018', 1, 'Atlantic Salmon Fillet', 'Salmon',
     'https://www.gulfcoastseafood.com/campaigns/atlantic-salmon-fillet', 0.65);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000019', 1, 'Raw Wildflower Honey', 'Honey',
     'https://www.hillcountryhoney.com/campaigns/raw-wildflower-honey', 0.45);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000020', 1, 'Lemon Juice Concentrate', 'Lemon',
     'https://www.redriverbeverages.com/campaigns/lemon-juice-concentrate', 0.15);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000021', 1, 'Spaghetti Pasta', 'Pasta',
     'https://www.panhandlepasta.com/campaigns/spaghetti-pasta', 0.20);

INSERT INTO DASC5306_Fall26_S001_T4_Campaign
    (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, advertised_grocery_item_name,
     advertised_grocery_category, campaign_hyperlink, cashback_rate_per_read)
VALUES ('2000000022', 1, 'Cajun Hot Sauce', 'Hot Sauce',
     'https://www.bayousauceworks.com/campaigns/cajun-hot-sauce', 0.35);

-- ===================== Level 2 =====================

-- Cookbook (25 rows)
INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (1, 'Weeknight Wok', DATE '2024-02-10',
     'Fast stir-fries and rice dishes for busy weeknights.', 'Chinese', '1001000009');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (2, 'Paris on a Budget', DATE '2024-03-05',
     'Classic French comfort food made with dorm-friendly ingredients.', 'French', '1001000010');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (3, 'Campfire Kitchen: Indian Trail Meals', DATE '2024-05-12',
     'Spiced one-pot Indian meals from our campfire kitchen, built for camping trips.', 'Indian', '1001000011');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (4, 'Greek Dorm Classics', DATE '2024-01-20',
     'Fresh Greek salads, wraps and grills that fit a student budget.', 'Greek', '1001000012');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (5, 'Nonna''s Mav Pasta', DATE '2023-11-08',
     'Simple Italian pasta recipes passed down from Nonna.', 'Italian', '1001000013');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (6, 'Bento Basics', DATE '2024-06-01',
     'Balanced Japanese lunch boxes you can pack the night before.', 'Japanese', '1001000014');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (7, 'Seoul Food Campfire Kitchen', DATE '2024-04-18',
     'Korean grill favorites adapted for the campfire kitchen and portable stoves.', 'Korean', '1001000015');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (8, 'Mediterranean Meal Prep', DATE '2024-08-22',
     'Healthy Mediterranean bowls and plates for weekly meal prep.', 'Mediterranean', '1001000016');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (9, 'Taqueria at Home', DATE '2024-09-10',
     'Street-style tacos, enchiladas and burritos at home.', 'Mexican', '1001000017');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (10, 'Tapas Night', DATE '2024-07-03',
     'Small Spanish plates to share with roommates.', 'Spanish', '1001000018');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (11, 'Thai Street Eats', DATE '2024-10-15',
     'Bangkok street food favorites made in a small kitchen.', 'Thai', '1001000019');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (12, 'Spice Route Curries', DATE '2024-02-28',
     'Rich North Indian curries and desserts.', 'Indian', '1001000020');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (13, 'Dim Sum Sundays', DATE '2025-01-05',
     'Weekend dim sum projects: dumplings and steamed buns.', 'Chinese', '1001000021');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (14, 'Ramen Lab', DATE '2025-01-20',
     'Upgrading instant noodles into real ramen bowls.', 'Japanese', '1001000022');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (15, 'K-BBQ Campus Grill', DATE '2024-11-02',
     'Korean BBQ and snacks for tailgates.', 'Korean', '1001000023');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (16, 'Thai Campfire Kitchen', DATE '2024-12-01',
     'Coconut curries and skewers from a campfire kitchen.', 'Thai', '1001000024');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (17, 'Bistro Breakfasts', DATE '2025-02-14',
     'French cafe breakfasts and brunch plates.', 'French', '1001000025');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (18, 'Aegean Salads', DATE '2025-03-01',
     'Hearty Greek salads with grains and legumes.', 'Greek', '1001000026');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (19, 'Risotto & Rice', DATE '2025-01-11',
     'Creamy Italian risottos and rice snacks.', 'Italian', '1001000027');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (20, 'Code & Curry', DATE '2025-02-02',
     'Fifteen-minute Indian meals for long coding nights.', 'Indian', '1001000028');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (21, 'Midnight Mexican Snacks', DATE '2025-03-10',
     'Late-night Mexican snacks ready in ten minutes.', 'Mexican', '1001000029');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (22, 'Paella Project', DATE '2025-02-20',
     'Learning to cook Spanish paella step by step.', 'Spanish', '1001000030');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (23, 'Lunchbox Mediterranean', DATE '2025-04-05',
     'Mediterranean wraps and parfaits for packed lunches.', 'Mediterranean', '1001000011');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (24, 'Sichuan Heat', DATE '2025-05-01',
     'Bold, spicy Sichuan classics.', 'Chinese', '1001000020');

INSERT INTO DASC5306_Fall26_S001_T4_Cookbook
    (COOKBOOK_ID, cookbook_name, date_of_creation, description, primary_cuisine, CHEF_MAV_ID)
VALUES (25, 'Mochi & More Desserts', DATE '2025-06-15',
     'Japanese-style desserts and sweet snacks.', 'Japanese', '1001000025');

-- Follow_Unfollow (44 rows): a homecook never follows themselves
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000001', '1001000012');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000001', '1001000018');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000002', '1001000011');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000002', '1001000016');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000003', '1001000020');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000003', '1001000025');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000004', '1001000010');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000004', '1001000025');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000005', '1001000011');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000005', '1001000027');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000006', '1001000025');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000006', '1001000028');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000007', '1001000018');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000007', '1001000021');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000008', '1001000019');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000008', '1001000025');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000009', '1001000016');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000009', '1001000022');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000010', '1001000018');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000010', '1001000028');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000011', '1001000010');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000011', '1001000025');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000012', '1001000020');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000012', '1001000025');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000013', '1001000011');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000013', '1001000015');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000014', '1001000009');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000014', '1001000018');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000015', '1001000013');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000015', '1001000020');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000016', '1001000010');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000016', '1001000015');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000017', '1001000021');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000017', '1001000025');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000018', '1001000016');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000018', '1001000026');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000019', '1001000011');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000019', '1001000018');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000020', '1001000009');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000020', '1001000025');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000021', '1001000017');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000021', '1001000025');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000022', '1001000016');
INSERT INTO DASC5306_Fall26_S001_T4_Follow_Unfollow (HOMECOOK_MAV_ID, CHEF_MAV_ID) VALUES ('1001000022', '1001000028');

-- ===================== Level 3 =====================

-- Subscribe (55 rows)
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000001', 4);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000001', 10);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000002', 3);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000002', 7);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000002', 8);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000002', 9);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000003', 12);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000003', 25);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000004', 2);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000004', 17);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000005', 3);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000005', 7);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000005', 14);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000005', 19);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000006', 17);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000006', 20);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000006', 21);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000007', 10);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000007', 13);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000008', 3);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000008', 11);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000008', 25);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000009', 8);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000009', 14);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000010', 10);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000010', 20);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000011', 2);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000011', 17);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000012', 12);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000012', 25);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000013', 3);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000013', 7);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000013', 12);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000013', 18);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000014', 1);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000014', 7);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000014', 10);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000015', 5);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000015', 12);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000016', 2);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000016', 7);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000016', 17);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000017', 10);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000017', 13);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000018', 8);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000018', 18);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000019', 1);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000019', 10);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000020', 1);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000020', 15);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000021', 3);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000021', 9);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000021', 17);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000022', 8);
INSERT INTO DASC5306_Fall26_S001_T4_Subscribe (HOMECOOK_MAV_ID, COOKBOOK_ID) VALUES ('1001000022', 20);

-- Recipe (63 rows): recipe numbers restart at 1 in every cookbook
INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (1, 1, 'Egg Fried Rice', 'https://mavdine.uta.edu/recipes/1/1.txt', DATE '2024-02-25', '20:00', 'Dinner',
     'Rice', 'Eggs', 'Soy Sauce', 10, 15, 520);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (1, 2, 'Garlic Chicken Stir-Fry', 'https://mavdine.uta.edu/recipes/1/2.txt', DATE '2024-05-30', '09:10', 'Dinner',
     'Chicken', 'Garlic', 'Soy Sauce', 15, 12, 610);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (1, 3, 'Scallion Pancakes', 'https://mavdine.uta.edu/recipes/1/3.txt', DATE '2024-09-02', '17:30', 'Snacks',
     'Flour', 'Onion', 'Soy Sauce', 20, 10, 330);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (2, 1, 'Croque Monsieur', 'https://mavdine.uta.edu/recipes/2/1.txt', DATE '2024-03-20', '21:15', 'Lunch',
     'Bread', 'Cheddar', 'Butter', 10, 8, 640);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (2, 2, 'French Onion Soup', 'https://mavdine.uta.edu/recipes/2/2.txt', DATE '2024-06-23', '11:00', 'Dinner',
     'Onion', 'Butter', 'Bread', 15, 50, 450);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (2, 3, 'Crepes with Honey', 'https://mavdine.uta.edu/recipes/2/3.txt', DATE '2024-09-26', '19:20', 'Breakfast',
     'Flour', 'Milk', 'Honey', 10, 15, 380);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (3, 1, 'Foil-Packet Chana Masala', 'https://mavdine.uta.edu/recipes/3/1.txt', DATE '2024-05-27', '07:45', 'Dinner',
     'Chickpeas', 'Cumin', 'Tomato', 15, 25, 480);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (3, 2, 'Campfire Paneer Tikka', 'https://mavdine.uta.edu/recipes/3/2.txt', DATE '2024-08-30', '08:30', 'Dinner',
     'Paneer', 'Yogurt', 'Paprika', 20, 15, 520);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (3, 3, 'Skillet Masala Potatoes', 'https://mavdine.uta.edu/recipes/3/3.txt', DATE '2024-12-03', '12:15', 'Lunch',
     'Potatoes', 'Cumin', 'Onion', 10, 20, 360);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (4, 1, 'Greek Salad', 'https://mavdine.uta.edu/recipes/4/1.txt', DATE '2024-02-04', '18:45', 'Lunch',
     'Tomato', 'Feta', 'Olive Oil', 10, 0, 290);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (4, 2, 'Lemon Chicken Souvlaki', 'https://mavdine.uta.edu/recipes/4/2.txt', DATE '2024-05-09', '20:00', 'Dinner',
     'Chicken', 'Lemon', 'Olive Oil', 20, 15, 560);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (4, 3, 'Spanakopita Bites', 'https://mavdine.uta.edu/recipes/4/3.txt', DATE '2024-08-12', '09:10', 'Snacks',
     'Spinach', 'Feta', 'Flour', 25, 20, 310);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (5, 1, 'Spaghetti Aglio e Olio', 'https://mavdine.uta.edu/recipes/5/1.txt', DATE '2023-11-23', '17:30', 'Dinner',
     'Pasta', 'Garlic', 'Olive Oil', 5, 12, 590);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (5, 2, 'Creamy Mushroom Pasta', 'https://mavdine.uta.edu/recipes/5/2.txt', DATE '2024-02-26', '21:15', 'Dinner',
     'Pasta', 'Mushrooms', 'Milk', 10, 15, 680);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (5, 3, 'Tiramisu Cups', 'https://mavdine.uta.edu/recipes/5/3.txt', DATE '2024-05-31', '11:00', 'Dessert',
     'Coffee', 'Chocolate', 'Milk', 25, 0, 420);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (6, 1, 'Salmon Teriyaki Bento', 'https://mavdine.uta.edu/recipes/6/1.txt', DATE '2024-06-16', '19:20', 'Lunch',
     'Salmon', 'Rice', 'Soy Sauce', 15, 15, 610);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (6, 2, 'Tamagoyaki', 'https://mavdine.uta.edu/recipes/6/2.txt', DATE '2024-09-19', '07:45', 'Breakfast',
     'Eggs', 'Soy Sauce', 'Butter', 5, 8, 220);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (7, 1, 'Campfire Kimchi Fried Rice', 'https://mavdine.uta.edu/recipes/7/1.txt', DATE '2024-05-03', '12:15', 'Dinner',
     'Kimchi', 'Rice', 'Eggs', 10, 12, 540);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (7, 2, 'Gochujang Grilled Chicken', 'https://mavdine.uta.edu/recipes/7/2.txt', DATE '2024-08-06', '18:45', 'Dinner',
     'Chicken', 'Gochujang', 'Garlic', 20, 18, 590);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (8, 1, 'Chickpea Quinoa Bowl', 'https://mavdine.uta.edu/recipes/8/1.txt', DATE '2024-09-06', '09:10', 'Lunch',
     'Quinoa', 'Chickpeas', 'Lemon', 15, 15, 470);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (8, 2, 'Hummus Plate', 'https://mavdine.uta.edu/recipes/8/2.txt', DATE '2024-12-10', '17:30', 'Snacks',
     'Chickpeas', 'Olive Oil', 'Garlic', 10, 0, 320);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (8, 3, 'Baked Lemon Salmon', 'https://mavdine.uta.edu/recipes/8/3.txt', DATE '2025-03-15', '21:15', 'Dinner',
     'Salmon', 'Lemon', 'Olive Oil', 10, 20, 520);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (9, 1, 'Shrimp Tacos', 'https://mavdine.uta.edu/recipes/9/1.txt', DATE '2024-09-25', '11:00', 'Dinner',
     'Shrimp', 'Tortillas', 'Avocado', 15, 10, 560);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (9, 2, 'Chicken Enchiladas Verdes', 'https://mavdine.uta.edu/recipes/9/2.txt', DATE '2024-12-29', '19:20', 'Dinner',
     'Chicken', 'Tortillas', 'Salsa Verde', 20, 25, 640);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (9, 3, 'Breakfast Burrito', 'https://mavdine.uta.edu/recipes/9/3.txt', DATE '2025-04-03', '07:45', 'Breakfast',
     'Eggs', 'Tortillas', 'Potatoes', 10, 15, 590);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (10, 1, 'Gambas al Ajillo', 'https://mavdine.uta.edu/recipes/10/1.txt', DATE '2024-07-18', '08:30', 'Snacks',
     'Shrimp', 'Garlic', 'Olive Oil', 10, 8, 300);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (10, 2, 'Patatas Bravas', 'https://mavdine.uta.edu/recipes/10/2.txt', DATE '2024-10-21', '12:15', 'Snacks',
     'Potatoes', 'Paprika', 'Olive Oil', 15, 30, 380);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (10, 3, 'Spanish Tortilla', 'https://mavdine.uta.edu/recipes/10/3.txt', DATE '2025-01-24', '18:45', 'Brunch',
     'Eggs', 'Potatoes', 'Onion', 15, 25, 410);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (11, 1, 'Pad Thai', 'https://mavdine.uta.edu/recipes/11/1.txt', DATE '2024-10-30', '20:00', 'Dinner',
     'Noodles', 'Shrimp', 'Eggs', 20, 15, 620);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (11, 2, 'Green Curry', 'https://mavdine.uta.edu/recipes/11/2.txt', DATE '2025-02-02', '09:10', 'Dinner',
     'Coconut Milk', 'Chicken', 'Basil', 15, 20, 580);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (11, 3, 'Coconut Sticky Rice', 'https://mavdine.uta.edu/recipes/11/3.txt', DATE '2025-05-08', '17:30', 'Dessert',
     'Coconut Milk', 'Rice', 'Honey', 10, 25, 410);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (12, 1, 'Butter Chicken', 'https://mavdine.uta.edu/recipes/12/1.txt', DATE '2024-03-14', '21:15', 'Dinner',
     'Chicken', 'Butter', 'Tomato', 20, 30, 720);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (12, 2, 'Dal Tadka', 'https://mavdine.uta.edu/recipes/12/2.txt', DATE '2024-06-17', '11:00', 'Lunch',
     'Lentils', 'Cumin', 'Garlic', 10, 30, 390);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (12, 3, 'Saffron Rice Pudding', 'https://mavdine.uta.edu/recipes/12/3.txt', DATE '2024-09-20', '19:20', 'Dessert',
     'Rice', 'Milk', 'Saffron', 5, 35, 350);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (13, 1, 'Pork Dumplings', 'https://mavdine.uta.edu/recipes/13/1.txt', DATE '2025-01-20', '07:45', 'Brunch',
     'Pork', 'Flour', 'Ginger', 40, 15, 450);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (13, 2, 'Steamed Buns', 'https://mavdine.uta.edu/recipes/13/2.txt', DATE '2025-04-25', '08:30', 'Brunch',
     'Flour', 'Yeast', 'Pork', 60, 15, 410);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (14, 1, 'Shoyu Ramen', 'https://mavdine.uta.edu/recipes/14/1.txt', DATE '2025-02-04', '18:45', 'Dinner',
     'Noodles', 'Soy Sauce', 'Eggs', 20, 25, 640);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (14, 2, 'Miso Mushroom Ramen', 'https://mavdine.uta.edu/recipes/14/2.txt', DATE '2025-05-10', '20:00', 'Dinner',
     'Noodles', 'Mushrooms', 'Tofu', 15, 20, 560);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (15, 1, 'Bulgogi', 'https://mavdine.uta.edu/recipes/15/1.txt', DATE '2024-11-17', '17:30', 'Dinner',
     'Beef', 'Soy Sauce', 'Garlic', 30, 10, 650);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (15, 2, 'Kimchi Pancake', 'https://mavdine.uta.edu/recipes/15/2.txt', DATE '2025-02-20', '21:15', 'Snacks',
     'Kimchi', 'Flour', 'Onion', 10, 10, 340);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (16, 1, 'Campfire Satay Skewers', 'https://mavdine.uta.edu/recipes/16/1.txt', DATE '2024-12-16', '19:20', 'Dinner',
     'Chicken', 'Coconut Milk', 'Ginger', 25, 12, 510);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (16, 2, 'Tom Kha Soup', 'https://mavdine.uta.edu/recipes/16/2.txt', DATE '2025-03-21', '07:45', 'Lunch',
     'Coconut Milk', 'Mushrooms', 'Lemon', 10, 20, 380);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (17, 1, 'French Toast', 'https://mavdine.uta.edu/recipes/17/1.txt', DATE '2025-03-01', '12:15', 'Breakfast',
     'Bread', 'Eggs', 'Milk', 10, 10, 470);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (17, 2, 'Mushroom Omelette', 'https://mavdine.uta.edu/recipes/17/2.txt', DATE '2025-06-04', '18:45', 'Breakfast',
     'Eggs', 'Mushrooms', 'Butter', 5, 8, 340);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (17, 3, 'Strawberry Crepes', 'https://mavdine.uta.edu/recipes/17/3.txt', DATE '2025-09-07', '20:00', 'Brunch',
     'Flour', 'Strawberries', 'Milk', 15, 15, 420);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (18, 1, 'Lentil Feta Salad', 'https://mavdine.uta.edu/recipes/18/1.txt', DATE '2025-03-16', '09:10', 'Lunch',
     'Lentils', 'Feta', 'Lemon', 15, 20, 410);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (18, 2, 'Quinoa Tabbouleh', 'https://mavdine.uta.edu/recipes/18/2.txt', DATE '2025-06-19', '17:30', 'Lunch',
     'Quinoa', 'Tomato', 'Lemon', 20, 15, 330);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (19, 1, 'Mushroom Risotto', 'https://mavdine.uta.edu/recipes/19/1.txt', DATE '2025-01-26', '11:00', 'Dinner',
     'Rice', 'Mushrooms', 'Butter', 10, 35, 560);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (19, 2, 'Saffron Risotto', 'https://mavdine.uta.edu/recipes/19/2.txt', DATE '2025-05-01', '19:20', 'Dinner',
     'Rice', 'Saffron', 'Butter', 10, 35, 540);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (19, 3, 'Spinach Arancini', 'https://mavdine.uta.edu/recipes/19/3.txt', DATE '2025-08-04', '07:45', 'Snacks',
     'Rice', 'Spinach', 'Cheddar', 30, 20, 420);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (20, 1, '15-Minute Chickpea Curry', 'https://mavdine.uta.edu/recipes/20/1.txt', DATE '2025-02-17', '08:30', 'Dinner',
     'Chickpeas', 'Coconut Milk', 'Cumin', 5, 15, 490);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (20, 2, 'Microwave Paneer Bhurji', 'https://mavdine.uta.edu/recipes/20/2.txt', DATE '2025-05-23', '12:15', 'Breakfast',
     'Paneer', 'Onion', 'Tomato', 5, 6, 360);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (21, 1, 'Avocado Quesadilla', 'https://mavdine.uta.edu/recipes/21/1.txt', DATE '2025-03-25', '20:00', 'Snacks',
     'Tortillas', 'Avocado', 'Cheddar', 5, 6, 450);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (21, 2, 'Salsa Verde Nachos', 'https://mavdine.uta.edu/recipes/21/2.txt', DATE '2025-06-28', '09:10', 'Snacks',
     'Tortillas', 'Salsa Verde', 'Cheddar', 5, 8, 520);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (22, 1, 'Seafood Paella', 'https://mavdine.uta.edu/recipes/22/1.txt', DATE '2025-03-07', '21:15', 'Dinner',
     'Rice', 'Shrimp', 'Saffron', 25, 40, 610);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (22, 2, 'Chicken Paella', 'https://mavdine.uta.edu/recipes/22/2.txt', DATE '2025-06-10', '11:00', 'Dinner',
     'Rice', 'Chicken', 'Paprika', 20, 40, 640);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (23, 1, 'Falafel Wrap', 'https://mavdine.uta.edu/recipes/23/1.txt', DATE '2025-04-20', '07:45', 'Lunch',
     'Chickpeas', 'Bread', 'Yogurt', 25, 15, 560);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (23, 2, 'Greek Yogurt Parfait', 'https://mavdine.uta.edu/recipes/23/2.txt', DATE '2025-07-24', '08:30', 'Breakfast',
     'Yogurt', 'Honey', 'Pecans', 5, 0, 310);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (24, 1, 'Mapo Tofu', 'https://mavdine.uta.edu/recipes/24/1.txt', DATE '2025-05-16', '18:45', 'Dinner',
     'Tofu', 'Pork', 'Garlic', 15, 15, 480);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (24, 2, 'Dan Dan Noodles', 'https://mavdine.uta.edu/recipes/24/2.txt', DATE '2025-08-19', '20:00', 'Dinner',
     'Noodles', 'Pork', 'Hot Sauce', 15, 10, 620);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (25, 1, 'Chocolate Mochi', 'https://mavdine.uta.edu/recipes/25/1.txt', DATE '2025-06-30', '17:30', 'Dessert',
     'Flour', 'Chocolate', 'Milk', 30, 15, 260);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (25, 2, 'Honey Castella Cake', 'https://mavdine.uta.edu/recipes/25/2.txt', DATE '2025-10-03', '21:15', 'Dessert',
     'Eggs', 'Flour', 'Honey', 20, 50, 330);

INSERT INTO DASC5306_Fall26_S001_T4_Recipe
    (COOKBOOK_ID, RECIPE_NUMBER, title, source_url, date_of_publish, time_of_publish, meal_type,
     ingredient_1, ingredient_2, ingredient_3, preparation_time, cook_time, total_calories)
VALUES (25, 3, 'Strawberry Daifuku', 'https://mavdine.uta.edu/recipes/25/3.txt', DATE '2026-01-06', '11:00', 'Dessert',
     'Strawberries', 'Flour', 'Honey', 30, 10, 210);

-- ===================== Level 4 =====================

-- Read (255 rows): inserted BEFORE Like_Dislike (trigger T5 needs a matching read);
-- end_time NULL = reading session still open.
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 2, 1, TIMESTAMP '2024-06-04 12:15:00', TIMESTAMP '2024-06-04 12:35:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 12, 2, TIMESTAMP '2024-07-23 17:30:00', TIMESTAMP '2024-07-23 17:47:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 4, 2, TIMESTAMP '2024-08-01 08:00:00', TIMESTAMP '2024-08-01 08:18:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 2, 1, TIMESTAMP '2024-08-07 11:40:00', TIMESTAMP '2024-08-07 11:52:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000014', 10, 1, TIMESTAMP '2024-08-18 20:15:00', TIMESTAMP '2024-08-18 20:48:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 9, 1, TIMESTAMP '2024-10-02 10:40:00', TIMESTAMP '2024-10-02 10:56:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 12, 3, TIMESTAMP '2024-10-30 15:15:00', TIMESTAMP '2024-10-30 15:26:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000011', 2, 3, TIMESTAMP '2024-11-01 07:45:00', TIMESTAMP '2024-11-01 08:10:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 1, 1, TIMESTAMP '2024-11-11 19:50:00', TIMESTAMP '2024-11-11 20:01:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 5, 2, TIMESTAMP '2024-11-16 15:50:00', TIMESTAMP '2024-11-16 16:24:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 5, 2, TIMESTAMP '2024-11-24 13:00:00', TIMESTAMP '2024-11-24 13:32:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 1, 1, TIMESTAMP '2024-12-14 22:45:00', TIMESTAMP '2024-12-14 23:18:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000014', 10, 2, TIMESTAMP '2024-12-16 09:45:00', TIMESTAMP '2024-12-16 09:55:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 8, 1, TIMESTAMP '2024-12-25 22:30:00', TIMESTAMP '2024-12-25 22:44:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000014', 1, 3, TIMESTAMP '2025-01-01 13:20:00', TIMESTAMP '2025-01-01 13:43:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 8, 1, TIMESTAMP '2025-01-10 17:10:00', TIMESTAMP '2025-01-10 17:28:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 4, 1, TIMESTAMP '2025-01-17 13:30:00', TIMESTAMP '2025-01-17 13:46:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 19, 1, TIMESTAMP '2025-02-06 16:30:00', TIMESTAMP '2025-02-06 16:50:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 3, 1, TIMESTAMP '2025-02-08 19:00:00', TIMESTAMP '2025-02-08 19:20:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 3, 2, TIMESTAMP '2025-02-17 20:00:00', TIMESTAMP '2025-02-17 20:23:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 8, 2, TIMESTAMP '2025-02-20 09:10:00', TIMESTAMP '2025-02-20 09:28:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 3, 3, TIMESTAMP '2025-02-26 21:00:00', TIMESTAMP '2025-02-26 21:26:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 3, 1, TIMESTAMP '2025-03-01 18:30:00', TIMESTAMP '2025-03-01 18:50:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 20, 1, TIMESTAMP '2025-03-04 21:30:00', TIMESTAMP '2025-03-04 21:48:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 8, 1, TIMESTAMP '2025-03-06 21:05:00', TIMESTAMP '2025-03-06 21:16:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 1, 1, TIMESTAMP '2025-03-07 17:40:00', TIMESTAMP '2025-03-07 17:58:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 7, 1, TIMESTAMP '2025-03-07 22:00:00', TIMESTAMP '2025-03-07 22:29:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 3, 2, TIMESTAMP '2025-03-10 19:30:00', TIMESTAMP '2025-03-10 19:53:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 20, 1, TIMESTAMP '2025-03-11 22:10:00', TIMESTAMP '2025-03-11 22:25:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 10, 2, TIMESTAMP '2025-03-12 09:10:00', TIMESTAMP '2025-03-12 09:30:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 9, 1, TIMESTAMP '2025-03-13 12:30:00', TIMESTAMP '2025-03-13 12:49:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 12, 3, TIMESTAMP '2025-03-14 18:50:00', TIMESTAMP '2025-03-14 19:14:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 7, 2, TIMESTAMP '2025-03-16 23:00:00', TIMESTAMP '2025-03-16 23:32:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 17, 1, TIMESTAMP '2025-03-19 11:30:00', TIMESTAMP '2025-03-19 11:47:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000014', 14, 1, TIMESTAMP '2025-03-19 16:40:00', TIMESTAMP '2025-03-19 16:52:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 3, 3, TIMESTAMP '2025-03-19 20:30:00', TIMESTAMP '2025-03-19 20:56:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 7, 1, TIMESTAMP '2025-03-28 21:30:00', TIMESTAMP '2025-03-28 21:59:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 5, 3, TIMESTAMP '2025-03-31 22:20:00', TIMESTAMP '2025-03-31 22:31:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 20, 1, TIMESTAMP '2025-04-02 23:00:00', TIMESTAMP '2025-04-02 23:20:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 22, 1, TIMESTAMP '2025-04-05 18:30:00', TIMESTAMP '2025-04-05 19:00:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 7, 2, TIMESTAMP '2025-04-06 22:30:00', TIMESTAMP '2025-04-06 23:02:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000001', 4, 3, TIMESTAMP '2025-04-08 16:20:00', TIMESTAMP '2025-04-08 16:39:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 3, 1, TIMESTAMP '2025-04-12 12:00:00', TIMESTAMP '2025-04-12 12:20:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000007', 10, 3, TIMESTAMP '2025-04-13 19:10:00', TIMESTAMP '2025-04-13 19:47:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 10, 2, TIMESTAMP '2025-04-14 08:30:00', TIMESTAMP '2025-04-14 08:44:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000021', 11, 2, TIMESTAMP '2025-04-14 13:15:00', TIMESTAMP '2025-04-14 13:23:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 8, 3, TIMESTAMP '2025-04-17 17:05:00', TIMESTAMP '2025-04-17 17:13:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 10, 3, TIMESTAMP '2025-04-18 12:00:00', TIMESTAMP '2025-04-18 12:21:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 18, 1, TIMESTAMP '2025-04-19 16:15:00', TIMESTAMP '2025-04-19 16:56:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 21, 1, TIMESTAMP '2025-04-19 23:40:00', TIMESTAMP '2025-04-19 23:50:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 3, 2, TIMESTAMP '2025-04-21 13:00:00', TIMESTAMP '2025-04-21 13:23:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 18, 1, TIMESTAMP '2025-04-23 08:10:00', TIMESTAMP '2025-04-23 08:22:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 12, 1, TIMESTAMP '2025-04-26 13:20:00', TIMESTAMP '2025-04-26 13:52:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 9, 1, TIMESTAMP '2025-04-29 13:50:00', TIMESTAMP '2025-04-29 14:04:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 10, 3, TIMESTAMP '2025-04-29 16:05:00', TIMESTAMP '2025-04-29 16:13:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 3, 3, TIMESTAMP '2025-04-30 14:00:00', TIMESTAMP '2025-04-30 14:26:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 2, 3, TIMESTAMP '2025-05-01 12:00:00', TIMESTAMP '2025-05-01 12:16:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 21, 1, TIMESTAMP '2025-05-03 00:20:00', TIMESTAMP '2025-05-03 00:29:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000021', 6, 2, TIMESTAMP '2025-05-03 07:50:00', TIMESTAMP '2025-05-03 08:25:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 9, 2, TIMESTAMP '2025-05-05 17:50:00', TIMESTAMP '2025-05-05 17:58:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000008', 10, 1, TIMESTAMP '2025-05-05 21:40:00', TIMESTAMP '2025-05-05 21:57:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 7, 1, TIMESTAMP '2025-05-09 15:00:00', TIMESTAMP '2025-05-09 15:29:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000001', 22, 1, TIMESTAMP '2025-05-10 17:15:00', TIMESTAMP '2025-05-10 17:43:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000011', 14, 2, TIMESTAMP '2025-05-11 09:15:00', TIMESTAMP '2025-05-11 09:56:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 7, 1, TIMESTAMP '2025-05-17 16:00:00', TIMESTAMP '2025-05-17 16:20:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 9, 2, TIMESTAMP '2025-05-18 15:40:00', TIMESTAMP '2025-05-18 16:21:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000007', 13, 2, TIMESTAMP '2025-05-19 07:50:00', TIMESTAMP '2025-05-19 08:10:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 4, 1, TIMESTAMP '2025-05-19 08:05:00', TIMESTAMP '2025-05-19 08:15:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000008', 13, 1, TIMESTAMP '2025-05-20 09:45:00', TIMESTAMP '2025-05-20 09:54:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 7, 2, TIMESTAMP '2025-05-26 17:00:00', TIMESTAMP '2025-05-26 17:23:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 12, 3, TIMESTAMP '2025-05-27 13:15:00', TIMESTAMP '2025-05-27 13:27:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 14, 1, TIMESTAMP '2025-06-01 17:00:00', TIMESTAMP '2025-06-01 17:39:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 12, 3, TIMESTAMP '2025-06-05 12:45:00', TIMESTAMP '2025-06-05 13:01:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 3, 1, TIMESTAMP '2025-06-07 15:00:00', TIMESTAMP '2025-06-07 15:20:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 2, 1, TIMESTAMP '2025-06-09 08:45:00', TIMESTAMP '2025-06-09 08:55:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 20, 2, TIMESTAMP '2025-06-10 20:45:00', TIMESTAMP '2025-06-10 20:57:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 17, 1, TIMESTAMP '2025-06-13 22:10:00', TIMESTAMP '2025-06-13 22:26:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 16, 2, TIMESTAMP '2025-06-14 16:30:00', TIMESTAMP '2025-06-14 16:58:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 3, 2, TIMESTAMP '2025-06-16 16:00:00', TIMESTAMP '2025-06-16 16:23:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 11, 3, TIMESTAMP '2025-06-19 22:15:00', TIMESTAMP '2025-06-19 22:27:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 1, 1, TIMESTAMP '2025-06-20 10:20:00', TIMESTAMP '2025-06-20 10:44:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 23, 1, TIMESTAMP '2025-06-23 11:20:00', TIMESTAMP '2025-06-23 11:42:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 9, 1, TIMESTAMP '2025-06-23 13:15:00', TIMESTAMP '2025-06-23 13:25:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 3, 3, TIMESTAMP '2025-06-25 17:00:00', TIMESTAMP '2025-06-25 17:26:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 8, 3, TIMESTAMP '2025-06-25 22:20:00', TIMESTAMP '2025-06-25 22:37:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000008', 11, 3, TIMESTAMP '2025-06-26 12:40:00', TIMESTAMP '2025-06-26 12:59:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 20, 2, TIMESTAMP '2025-07-01 21:05:00', TIMESTAMP '2025-07-01 21:19:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000001', 10, 2, TIMESTAMP '2025-07-03 12:15:00', TIMESTAMP '2025-07-03 12:29:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 7, 1, TIMESTAMP '2025-07-04 18:00:00', TIMESTAMP '2025-07-04 18:29:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000007', 10, 3, TIMESTAMP '2025-07-06 12:45:00', TIMESTAMP '2025-07-06 13:27:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000021', 9, 3, TIMESTAMP '2025-07-11 08:30:00', TIMESTAMP '2025-07-11 08:58:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 21, 2, TIMESTAMP '2025-07-12 23:55:00', TIMESTAMP '2025-07-13 00:06:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 23, 1, TIMESTAMP '2025-07-13 18:00:00', TIMESTAMP '2025-07-13 18:43:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 7, 2, TIMESTAMP '2025-07-13 19:00:00', TIMESTAMP '2025-07-13 19:32:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 12, 3, TIMESTAMP '2025-07-15 10:45:00', TIMESTAMP '2025-07-15 10:54:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 22, 2, TIMESTAMP '2025-07-20 19:00:00', TIMESTAMP '2025-07-20 19:35:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000007', 10, 3, TIMESTAMP '2025-07-20 22:15:00', TIMESTAMP '2025-07-20 22:56:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 3, 2, TIMESTAMP '2025-08-02 20:00:00', TIMESTAMP '2025-08-02 20:20:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 8, 1, TIMESTAMP '2025-08-04 10:00:00', TIMESTAMP '2025-08-04 10:19:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 17, 2, TIMESTAMP '2025-08-09 15:00:00', TIMESTAMP '2025-08-09 15:41:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 11, 3, TIMESTAMP '2025-08-11 13:20:00', TIMESTAMP '2025-08-11 13:38:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 10, 2, TIMESTAMP '2025-08-13 13:10:00', TIMESTAMP '2025-08-13 13:30:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 11, 3, TIMESTAMP '2025-08-14 10:30:00', TIMESTAMP '2025-08-14 10:41:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 2, 3, TIMESTAMP '2025-08-15 10:40:00', TIMESTAMP '2025-08-15 11:08:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 20, 2, TIMESTAMP '2025-08-15 22:30:00', TIMESTAMP '2025-08-15 22:46:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000020', 15, 2, TIMESTAMP '2025-08-20 07:45:00', TIMESTAMP '2025-08-20 08:05:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000021', 9, 1, TIMESTAMP '2025-08-22 11:10:00', TIMESTAMP '2025-08-22 11:30:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 11, 3, TIMESTAMP '2025-08-22 17:40:00', TIMESTAMP '2025-08-22 18:02:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 1, 1, TIMESTAMP '2025-08-25 22:45:00', TIMESTAMP '2025-08-25 22:55:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000021', 17, 2, TIMESTAMP '2025-08-27 12:15:00', TIMESTAMP '2025-08-27 12:25:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 8, 3, TIMESTAMP '2025-08-30 22:50:00', TIMESTAMP '2025-08-30 23:21:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 18, 1, TIMESTAMP '2025-08-31 20:00:00', TIMESTAMP '2025-08-31 20:40:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 8, 3, TIMESTAMP '2025-09-07 07:30:00', TIMESTAMP '2025-09-07 08:07:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000011', 6, 2, TIMESTAMP '2025-09-08 16:40:00', TIMESTAMP '2025-09-08 16:58:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 12, 3, TIMESTAMP '2025-09-12 21:30:00', TIMESTAMP '2025-09-12 21:51:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 8, 1, TIMESTAMP '2025-09-14 13:30:00', TIMESTAMP '2025-09-14 14:08:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000008', 5, 3, TIMESTAMP '2025-09-14 18:20:00', TIMESTAMP '2025-09-14 19:06:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 14, 1, TIMESTAMP '2025-09-20 08:15:00', TIMESTAMP '2025-09-20 08:45:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 20, 1, TIMESTAMP '2025-09-20 13:15:00', TIMESTAMP '2025-09-20 13:40:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000014', 1, 3, TIMESTAMP '2025-09-29 20:15:00', TIMESTAMP '2025-09-29 20:35:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 8, 2, TIMESTAMP '2025-09-30 10:10:00', TIMESTAMP '2025-09-30 10:24:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 12, 3, TIMESTAMP '2025-10-02 10:10:00', TIMESTAMP '2025-10-02 10:20:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000020', 1, 1, TIMESTAMP '2025-10-08 12:00:00', TIMESTAMP '2025-10-08 12:16:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 14, 2, TIMESTAMP '2025-10-15 13:20:00', TIMESTAMP '2025-10-15 13:37:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 4, 2, TIMESTAMP '2025-10-15 15:10:00', TIMESTAMP '2025-10-15 15:20:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 17, 1, TIMESTAMP '2025-10-15 19:20:00', TIMESTAMP '2025-10-15 19:36:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 13, 1, TIMESTAMP '2025-10-15 21:30:00', TIMESTAMP '2025-10-15 21:42:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000021', 13, 1, TIMESTAMP '2025-10-16 14:45:00', TIMESTAMP '2025-10-16 14:54:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 15, 1, TIMESTAMP '2025-10-16 17:20:00', TIMESTAMP '2025-10-16 17:29:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000020', 5, 1, TIMESTAMP '2025-10-16 19:45:00', TIMESTAMP '2025-10-16 19:57:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000008', 25, 1, TIMESTAMP '2025-10-22 22:05:00', TIMESTAMP '2025-10-22 22:17:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 18, 1, TIMESTAMP '2025-10-22 22:30:00', TIMESTAMP '2025-10-22 22:54:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000011', 12, 3, TIMESTAMP '2025-10-23 11:10:00', TIMESTAMP '2025-10-23 11:25:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000021', 17, 1, TIMESTAMP '2025-10-24 15:00:00', TIMESTAMP '2025-10-24 15:24:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 13, 1, TIMESTAMP '2025-10-26 11:40:00', TIMESTAMP '2025-10-26 12:16:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 23, 1, TIMESTAMP '2025-10-27 21:40:00', TIMESTAMP '2025-10-27 21:53:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 15, 2, TIMESTAMP '2025-11-04 15:00:00', TIMESTAMP '2025-11-04 15:10:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 18, 2, TIMESTAMP '2025-11-08 12:30:00', TIMESTAMP '2025-11-08 13:04:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 17, 2, TIMESTAMP '2025-11-08 21:45:00', TIMESTAMP '2025-11-08 22:19:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000007', 13, 1, TIMESTAMP '2025-11-09 18:15:00', TIMESTAMP '2025-11-09 18:56:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000001', 12, 3, TIMESTAMP '2025-11-11 15:45:00', TIMESTAMP '2025-11-11 15:54:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 25, 1, TIMESTAMP '2025-11-12 16:10:00', TIMESTAMP '2025-11-12 16:29:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 11, 3, TIMESTAMP '2025-11-12 16:15:00', TIMESTAMP '2025-11-12 16:31:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 18, 1, TIMESTAMP '2025-11-15 12:45:00', TIMESTAMP '2025-11-15 13:16:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 17, 1, TIMESTAMP '2025-11-18 21:15:00', TIMESTAMP '2025-11-18 21:25:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000014', 8, 3, TIMESTAMP '2025-12-08 19:30:00', TIMESTAMP '2025-12-08 19:39:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 13, 1, TIMESTAMP '2025-12-09 10:15:00', TIMESTAMP '2025-12-09 10:33:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 9, 1, TIMESTAMP '2025-12-10 21:30:00', TIMESTAMP '2025-12-10 21:46:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 2, 3, TIMESTAMP '2025-12-11 13:10:00', TIMESTAMP '2025-12-11 13:22:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000011', 23, 2, TIMESTAMP '2025-12-16 13:40:00', TIMESTAMP '2025-12-16 13:51:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 5, 1, TIMESTAMP '2025-12-18 11:00:00', TIMESTAMP '2025-12-18 11:15:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000020', 25, 2, TIMESTAMP '2025-12-22 14:30:00', TIMESTAMP '2025-12-22 14:50:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000007', 17, 1, TIMESTAMP '2025-12-22 20:50:00', TIMESTAMP '2025-12-22 21:01:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 10, 1, TIMESTAMP '2025-12-26 19:05:00', TIMESTAMP '2025-12-26 19:21:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000021', 17, 2, TIMESTAMP '2025-12-29 11:30:00', TIMESTAMP '2025-12-29 11:48:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 23, 2, TIMESTAMP '2026-01-02 20:50:00', TIMESTAMP '2026-01-02 21:07:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 14, 1, TIMESTAMP '2026-01-07 12:40:00', TIMESTAMP '2026-01-07 12:50:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 25, 2, TIMESTAMP '2026-01-09 20:10:00', TIMESTAMP '2026-01-09 20:33:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 16, 1, TIMESTAMP '2026-01-30 10:05:00', TIMESTAMP '2026-01-30 10:20:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000020', 11, 2, TIMESTAMP '2026-02-06 11:20:00', TIMESTAMP '2026-02-06 11:42:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 2, 3, TIMESTAMP '2026-02-07 22:50:00', TIMESTAMP '2026-02-07 23:19:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 17, 3, TIMESTAMP '2026-02-10 18:10:00', TIMESTAMP '2026-02-10 18:24:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 8, 3, TIMESTAMP '2026-02-11 15:50:00', TIMESTAMP '2026-02-11 16:12:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 9, 1, TIMESTAMP '2026-02-11 17:15:00', TIMESTAMP '2026-02-11 17:33:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 10, 2, TIMESTAMP '2026-02-13 22:10:00', TIMESTAMP '2026-02-13 22:36:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 4, 1, TIMESTAMP '2026-02-15 07:15:00', TIMESTAMP '2026-02-15 07:50:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000008', 25, 2, TIMESTAMP '2026-02-15 07:50:00', TIMESTAMP '2026-02-15 08:25:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000007', 19, 3, TIMESTAMP '2026-02-28 14:45:00', TIMESTAMP '2026-02-28 15:24:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 10, 3, TIMESTAMP '2026-03-02 12:05:00', TIMESTAMP '2026-03-02 12:20:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 25, 2, TIMESTAMP '2026-03-02 20:15:00', TIMESTAMP '2026-03-02 20:30:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 1, 1, TIMESTAMP '2026-03-05 14:40:00', TIMESTAMP '2026-03-05 14:56:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 25, 1, TIMESTAMP '2026-03-09 08:15:00', TIMESTAMP '2026-03-09 08:29:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000011', 8, 3, TIMESTAMP '2026-03-09 15:05:00', TIMESTAMP '2026-03-09 15:21:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 4, 3, TIMESTAMP '2026-03-11 09:50:00', TIMESTAMP '2026-03-11 10:11:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 25, 2, TIMESTAMP '2026-03-11 12:50:00', TIMESTAMP '2026-03-11 13:04:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 17, 1, TIMESTAMP '2026-03-13 09:20:00', TIMESTAMP '2026-03-13 09:41:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 13, 2, TIMESTAMP '2026-03-15 13:50:00', TIMESTAMP '2026-03-15 14:29:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 10, 2, TIMESTAMP '2026-03-18 17:20:00', TIMESTAMP '2026-03-18 17:40:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000021', 17, 1, TIMESTAMP '2026-03-19 18:10:00', TIMESTAMP '2026-03-19 18:21:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 13, 1, TIMESTAMP '2026-03-22 21:50:00', TIMESTAMP '2026-03-22 22:30:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 6, 1, TIMESTAMP '2026-03-24 13:50:00', TIMESTAMP '2026-03-24 14:07:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 12, 3, TIMESTAMP '2026-03-25 08:50:00', TIMESTAMP '2026-03-25 09:02:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 10, 2, TIMESTAMP '2026-03-26 18:10:00', TIMESTAMP '2026-03-26 18:17:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 13, 1, TIMESTAMP '2026-03-27 18:05:00', TIMESTAMP '2026-03-27 18:23:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 25, 2, TIMESTAMP '2026-03-30 18:05:00', TIMESTAMP '2026-03-30 18:19:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 9, 3, TIMESTAMP '2026-04-04 14:10:00', TIMESTAMP '2026-04-04 14:51:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 4, 1, TIMESTAMP '2026-04-07 08:30:00', TIMESTAMP '2026-04-07 08:44:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000008', 11, 3, TIMESTAMP '2026-04-08 21:40:00', TIMESTAMP '2026-04-08 21:58:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000007', 13, 2, TIMESTAMP '2026-04-09 11:40:00', TIMESTAMP '2026-04-09 11:48:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000018', 18, 1, TIMESTAMP '2026-04-16 14:45:00', TIMESTAMP '2026-04-16 15:03:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 10, 2, TIMESTAMP '2026-04-18 17:05:00', TIMESTAMP '2026-04-18 17:34:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 8, 3, TIMESTAMP '2026-04-18 20:45:00', TIMESTAMP '2026-04-18 21:22:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000001', 10, 1, TIMESTAMP '2026-04-21 15:50:00', TIMESTAMP '2026-04-21 16:04:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 2, 1, TIMESTAMP '2026-04-22 15:45:00', TIMESTAMP '2026-04-22 15:56:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000021', 10, 2, TIMESTAMP '2026-04-22 21:20:00', TIMESTAMP '2026-04-22 21:31:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 13, 1, TIMESTAMP '2026-04-29 12:45:00', TIMESTAMP '2026-04-29 13:05:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 25, 2, TIMESTAMP '2026-05-01 11:50:00', TIMESTAMP '2026-05-01 12:09:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 2, 2, TIMESTAMP '2026-05-02 12:00:00', TIMESTAMP '2026-05-02 12:40:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 15, 1, TIMESTAMP '2026-05-02 20:05:00', TIMESTAMP '2026-05-02 20:34:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000014', 17, 3, TIMESTAMP '2026-05-03 18:30:00', TIMESTAMP '2026-05-03 19:02:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 18, 2, TIMESTAMP '2026-05-06 17:05:00', TIMESTAMP '2026-05-06 17:29:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 17, 1, TIMESTAMP '2026-05-08 10:50:00', TIMESTAMP '2026-05-08 11:06:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 5, 2, TIMESTAMP '2026-05-11 19:50:00', TIMESTAMP '2026-05-11 20:00:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000001', 19, 3, TIMESTAMP '2026-05-12 16:00:00', TIMESTAMP '2026-05-12 16:20:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000001', 8, 2, TIMESTAMP '2026-05-15 13:40:00', TIMESTAMP '2026-05-15 14:00:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000001', 9, 1, TIMESTAMP '2026-05-15 19:20:00', TIMESTAMP '2026-05-15 19:43:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000020', 1, 1, TIMESTAMP '2026-05-18 20:30:00', TIMESTAMP '2026-05-18 20:45:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 5, 3, TIMESTAMP '2026-05-26 11:30:00', TIMESTAMP '2026-05-26 11:43:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000008', 25, 2, TIMESTAMP '2026-05-26 18:40:00', TIMESTAMP '2026-05-26 18:52:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 8, 3, TIMESTAMP '2026-05-27 15:05:00', TIMESTAMP '2026-05-27 15:19:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000022', 15, 2, TIMESTAMP '2026-06-02 22:45:00', TIMESTAMP '2026-06-02 22:56:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000011', 17, 2, TIMESTAMP '2026-06-04 14:00:00', TIMESTAMP '2026-06-04 14:10:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 13, 1, TIMESTAMP '2026-06-07 17:00:00', TIMESTAMP '2026-06-07 17:41:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000014', 19, 3, TIMESTAMP '2026-06-15 14:30:00', TIMESTAMP '2026-06-15 14:47:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 13, 2, TIMESTAMP '2026-06-16 17:40:00', TIMESTAMP '2026-06-16 17:56:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 25, 2, TIMESTAMP '2026-06-17 22:10:00', TIMESTAMP '2026-06-17 22:23:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 12, 3, TIMESTAMP '2026-06-21 11:05:00', TIMESTAMP '2026-06-21 11:45:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000020', 17, 1, TIMESTAMP '2026-06-24 17:00:00', TIMESTAMP '2026-06-24 17:16:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 1, 1, TIMESTAMP '2026-06-26 08:50:00', TIMESTAMP '2026-06-26 09:08:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000020', 1, 2, TIMESTAMP '2026-07-02 20:20:00', TIMESTAMP '2026-07-02 20:36:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000001', 4, 3, TIMESTAMP '2026-07-03 13:05:00', TIMESTAMP '2026-07-03 13:25:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 14, 2, TIMESTAMP '2026-07-10 21:05:00', TIMESTAMP '2026-07-10 21:29:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 25, 2, TIMESTAMP '2026-07-16 10:50:00', TIMESTAMP '2026-07-16 11:05:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 11, 1, TIMESTAMP '2026-07-17 12:10:00', TIMESTAMP '2026-07-17 12:34:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000011', 17, 1, TIMESTAMP '2026-07-20 09:50:00', TIMESTAMP '2026-07-20 10:11:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000013', 18, 1, TIMESTAMP '2026-07-20 22:50:00', TIMESTAMP '2026-07-20 23:03:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 17, 1, TIMESTAMP '2026-07-23 09:20:00', TIMESTAMP '2026-07-23 09:37:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000020', 14, 2, TIMESTAMP '2026-08-04 20:50:00', TIMESTAMP '2026-08-04 21:09:00', 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 19, 2, TIMESTAMP '2026-08-09 19:15:00', TIMESTAMP '2026-08-09 19:59:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 9, 1, TIMESTAMP '2026-08-19 07:20:00', TIMESTAMP '2026-08-19 07:42:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 6, 1, TIMESTAMP '2026-08-19 20:05:00', TIMESTAMP '2026-08-19 20:19:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 25, 2, TIMESTAMP '2026-08-23 12:10:00', TIMESTAMP '2026-08-23 12:46:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 10, 2, TIMESTAMP '2026-08-26 16:00:00', TIMESTAMP '2026-08-26 16:19:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000005', 19, 2, TIMESTAMP '2026-08-27 21:00:00', TIMESTAMP '2026-08-27 21:08:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000003', 25, 1, TIMESTAMP '2026-08-30 13:45:00', TIMESTAMP '2026-08-30 14:20:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000009', 13, 1, TIMESTAMP '2026-09-06 12:40:00', TIMESTAMP '2026-09-06 13:22:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 8, 1, TIMESTAMP '2026-09-09 09:05:00', TIMESTAMP '2026-09-09 09:15:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000019', 17, 3, TIMESTAMP '2026-09-10 18:15:00', TIMESTAMP '2026-09-10 18:31:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 17, 2, TIMESTAMP '2026-09-12 17:50:00', TIMESTAMP '2026-09-12 18:32:00', 'Engineering Research Building');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000011', 17, 2, TIMESTAMP '2026-09-13 11:20:00', TIMESTAMP '2026-09-13 11:53:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 12, 3, TIMESTAMP '2026-09-13 19:40:00', TIMESTAMP '2026-09-13 20:18:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000001', 8, 2, TIMESTAMP '2026-09-14 18:05:00', TIMESTAMP '2026-09-14 18:26:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000016', 16, 2, TIMESTAMP '2026-09-15 18:05:00', TIMESTAMP '2026-09-15 18:14:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000020', 1, 1, TIMESTAMP '2026-09-18 14:30:00', TIMESTAMP '2026-09-18 14:46:00', 'Science Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000010', 2, 1, TIMESTAMP '2026-09-20 13:20:00', TIMESTAMP '2026-09-20 14:01:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 2, 3, TIMESTAMP '2026-09-23 08:10:00', TIMESTAMP '2026-09-23 08:28:00', 'University Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000006', 2, 3, TIMESTAMP '2026-09-24 12:00:00', TIMESTAMP '2026-09-24 12:17:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000015', 11, 3, TIMESTAMP '2026-09-27 22:05:00', TIMESTAMP '2026-09-27 22:38:00', 'Maverick Activities Center');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000012', 25, 1, TIMESTAMP '2026-09-28 20:20:00', TIMESTAMP '2026-09-28 20:33:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 10, 3, TIMESTAMP '2026-10-03 07:10:00', TIMESTAMP '2026-10-03 07:38:00', 'Arlington Hall');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000002', 13, 1, TIMESTAMP '2026-10-03 18:45:00', TIMESTAMP '2026-10-03 19:25:00', 'UTA Central Library');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000021', 2, 3, TIMESTAMP '2026-10-05 14:15:00', TIMESTAMP '2026-10-05 14:30:00', NULL);
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 17, 1, TIMESTAMP '2026-10-05 22:40:00', TIMESTAMP '2026-10-05 23:02:00', 'MAX bus');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000004', 9, 1, TIMESTAMP '2026-10-06 20:15:00', NULL, 'Home');
INSERT INTO DASC5306_Fall26_S001_T4_Read
    (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time, end_time, location)
VALUES ('1001000017', 25, 1, TIMESTAMP '2026-10-07 21:40:00', NULL, 'Arlington Hall');

-- Like_Dislike (132 rows): one reaction per homecook per recipe, only on recipes they read
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000001', 4, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000001', 8, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000001', 9, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000001', 10, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000001', 12, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000001', 22, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 3, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 3, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 7, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 7, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 8, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 9, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 10, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 12, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 13, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 16, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 18, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000002', 25, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000003', 4, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000003', 8, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000003', 9, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000003', 11, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000003', 12, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000003', 13, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000003', 25, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000004', 8, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000004', 9, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000004', 10, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000004', 17, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000005', 3, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000005', 3, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000005', 4, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000005', 8, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000005', 12, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000005', 14, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000005', 16, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000005', 19, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000005', 19, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000006', 2, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000006', 9, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000006', 10, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000006', 17, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000006', 20, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000006', 21, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000006', 22, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000007', 13, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000007', 19, 3, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000008', 5, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000008', 10, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000008', 11, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000008', 13, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000008', 25, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000008', 25, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000009', 1, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000009', 5, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000009', 9, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000009', 11, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000009', 12, 3, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000009', 13, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000009', 14, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000009', 14, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000009', 17, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000010', 2, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000010', 4, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000010', 9, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000010', 17, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000010', 18, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000010', 20, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000010', 22, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000010', 23, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000011', 6, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000011', 8, 3, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000011', 12, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000011', 17, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000012', 2, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000012', 10, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000012', 12, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000012', 12, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000012', 13, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000012', 25, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000012', 25, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000013', 3, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000013', 3, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000013', 3, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000013', 18, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000014', 14, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000014', 17, 3, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000015', 5, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000015', 5, 3, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000015', 9, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000015', 11, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000015', 12, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000015', 25, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000016', 6, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000016', 12, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000016', 16, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000016', 17, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000016', 18, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000016', 23, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000017', 10, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000017', 10, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000017', 12, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000017', 13, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000017', 17, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000017', 17, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000017', 25, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000017', 25, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000018', 2, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000018', 4, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000018', 13, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000018', 18, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000019', 3, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000019', 3, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000019', 7, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000019', 7, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000019', 9, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000019', 11, 3, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000019', 13, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000020', 1, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000020', 1, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000020', 5, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000020', 11, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000021', 6, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000021', 13, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000022', 4, 3, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000022', 8, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000022', 10, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000022', 20, 1, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000022', 20, 2, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000022', 21, 1, 'Like');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000022', 21, 2, 'Dislike');
INSERT INTO DASC5306_Fall26_S001_T4_Like_Dislike (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, interaction_type) VALUES ('1001000022', 25, 2, 'Like');

-- Display_On (42 rows): each campaign shown on recipes that use its category as an ingredient
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (4, 3, '2000000001', 1, 49.21);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (19, 3, '2000000001', 1, 51.61);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (17, 1, '2000000001', 2, 33.39);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (2, 1, '2000000001', 2, 34.20);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (8, 1, '2000000002', 1, 49.87);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (18, 2, '2000000002', 1, 31.83);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (1, 1, '2000000003', 1, 1.50);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (10, 2, '2000000004', 1, 31.37);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (10, 3, '2000000004', 1, 30.61);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (13, 1, '2000000005', 1, 22.43);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (25, 2, '2000000005', 1, 23.81);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (10, 2, '2000000006', 1, 27.77);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (3, 2, '2000000006', 1, 14.83);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (3, 1, '2000000006', 2, 31.92);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (3, 3, '2000000006', 2, 45.53);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (13, 2, '2000000007', 1, 49.45);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (17, 1, '2000000008', 1, 17.42);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (12, 3, '2000000008', 1, 27.66);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (2, 1, '2000000008', 2, 49.41);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (19, 3, '2000000008', 2, 53.11);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (23, 2, '2000000009', 1, 25.60);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (9, 1, '2000000010', 1, 19.66);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (21, 1, '2000000010', 1, 48.12);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (9, 1, '2000000011', 1, 2.50);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (9, 1, '2000000012', 1, 24.71);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (9, 2, '2000000012', 1, 40.26);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (17, 2, '2000000013', 1, 51.78);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (2, 1, '2000000013', 1, 22.83);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (5, 3, '2000000014', 1, 24.70);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (9, 2, '2000000015', 1, 36.49);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (21, 2, '2000000015', 1, 15.63);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (10, 2, '2000000016', 1, 33.77);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (8, 3, '2000000016', 1, 36.78);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (12, 3, '2000000017', 2, 2.00);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (8, 3, '2000000018', 1, 3.00);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (25, 2, '2000000019', 1, 30.58);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (2, 3, '2000000019', 1, 43.85);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (8, 3, '2000000020', 1, 40.67);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (18, 1, '2000000020', 1, 36.98);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (5, 2, '2000000021', 1, 47.09);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (5, 1, '2000000021', 1, 18.15);
INSERT INTO DASC5306_Fall26_S001_T4_Display_On
    (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER, display_cost)
VALUES (24, 2, '2000000022', 1, 19.67);

COMMIT;
