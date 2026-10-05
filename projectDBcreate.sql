-- User: every registered user
-- Candidate keys: MAV_ID, username, email
CREATE TABLE DASC5306_Fall26_S001_T4_User (
    MAV_ID CHAR(10) NOT NULL,
    username VARCHAR2(30) NOT NULL,
    email VARCHAR2(100) NOT NULL,
    password VARCHAR2(64) NOT NULL,
    phone_number VARCHAR2(15),
    date_of_enrollment DATE NOT NULL,
    cumulative_GPA NUMBER(3,2) NOT NULL,
    enrolled_department VARCHAR2(50) NOT NULL, 
    nationality VARCHAR2(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    first_name VARCHAR2(30) NOT NULL,
    last_name VARCHAR2(30) NOT NULL,
    street_address VARCHAR2(100) NOT NULL,
    apartment_number VARCHAR2(10),
    city VARCHAR2(40) NOT NULL,
    county VARCHAR2(40) NOT NULL,
    zip_code VARCHAR2(10) NOT NULL,
    CONSTRAINT T4_User_PK PRIMARY KEY (MAV_ID),
    CONSTRAINT T4_User_UQ_username UNIQUE (username),
    CONSTRAINT T4_User_UQ_email UNIQUE (email),
    CONSTRAINT T4_User_CK_MAV_ID CHECK (REGEXP_LIKE(MAV_ID, '^[0-9]{10}$')),
    CONSTRAINT T4_User_CK_email CHECK (email LIKE '%_@_%._%'),
    CONSTRAINT T4_User_CK_date_of_enrollment CHECK (date_of_enrollment > date_of_birth),
    CONSTRAINT T4_User_CK_GPA CHECK (cumulative_GPA BETWEEN 0 AND 4.0)
);

-- Merchant: every registered merchant
-- Candidate keys: REGISTRATION_NUMBER, website
CREATE TABLE DASC5306_Fall26_S001_T4_Merchant (
    REGISTRATION_NUMBER CHAR(10) NOT NULL,
    merchant_name VARCHAR2(100) NOT NULL,
    website VARCHAR2(100) NOT NULL,
    number_of_employees NUMBER(7) NOT NULL,
    headquarter_city VARCHAR2(40) NOT NULL,
    CONSTRAINT T4_Merchant_PK PRIMARY KEY (REGISTRATION_NUMBER),
    CONSTRAINT T4_Merchant_UQ_website UNIQUE (website),
    CONSTRAINT T4_Merchant_CK_regno CHECK (REGEXP_LIKE(REGISTRATION_NUMBER, '^[0-9]{10}$')),
    CONSTRAINT T4_Merchant_CK_website CHECK (website LIKE '%_._%'),
    CONSTRAINT T4_Merchant_CK_empno CHECK (number_of_employees > 0)
);


-- Homecook: every registered homecook
-- Candidate keys: HOMECOOK_MAV_ID
CREATE TABLE DASC5306_Fall26_S001_T4_Homecook (
   HOMECOOK_MAV_ID char(10) NOT NULL,
   CONSTRAINT T4_Homecook_PK PRIMARY KEY (HOMECOOK_MAV_ID),
   -- ON DELETE CASCADE: a homecook can't exist without its user.
   CONSTRAINT T4_Homecook_FK_User FOREIGN KEY (HOMECOOK_MAV_ID) REFERENCES DASC5306_Fall26_S001_T4_User(MAV_ID) ON DELETE CASCADE
);

-- Chef: every registered chef
-- Candidate keys: CHEF_MAV_ID, chef_id
CREATE TABLE DASC5306_Fall26_S001_T4_Chef (
   CHEF_MAV_ID char(10) NOT NULL,
   chef_id NUMBER(10) NOT NULL,
   CONSTRAINT T4_Chef_PK PRIMARY KEY (CHEF_MAV_ID),
   CONSTRAINT T4_Chef_UQ_chef_id UNIQUE (chef_id),
   CONSTRAINT T4_Chef_CK_chef_id CHECK (chef_id > 0), 
   -- ON DELETE CASCADE: deleting a user also deletes the chef.
   CONSTRAINT T4_Chef_FK_User FOREIGN KEY (CHEF_MAV_ID) REFERENCES DASC5306_Fall26_S001_T4_User(MAV_ID) ON DELETE CASCADE
);

-- Campaign: every registered campaign
-- Candidate keys: (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER)
CREATE TABLE DASC5306_Fall26_S001_T4_Campaign (
    MERCHANT_REGISTRATION_NUMBER CHAR(10) NOT NULL,
    CAMPAIGN_NUMBER NUMBER(10) NOT NULL,
    advertised_grocery_item_name VARCHAR2(100) NOT NULL,
    advertised_grocery_category VARCHAR2(50) NOT NULL,
    campaign_hyperlink VARCHAR2(200) NOT NULL,
    cashback_rate_per_read NUMBER(5,2) NOT NULL,
    -- ADDING CONSTRAINTS
    CONSTRAINT T4_Campaign_PK PRIMARY KEY (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER),
    CONSTRAINT T4_Campaign_CK_cashback CHECK (cashback_rate_per_read BETWEEN 0 AND 100),
    CONSTRAINT T4_Campaign_CK_number CHECK (CAMPAIGN_NUMBER > 0),
    CONSTRAINT T4_Campaign_CK_link CHECK (campaign_hyperlink LIKE 'http%'),
    -- ON DELETE CASCADE: a campaign belongs to its merchant.
    CONSTRAINT T4_Campaign_FK_Merchant FOREIGN KEY (MERCHANT_REGISTRATION_NUMBER) REFERENCES DASC5306_Fall26_S001_T4_Merchant(REGISTRATION_NUMBER) ON DELETE CASCADE
);

