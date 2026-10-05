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


