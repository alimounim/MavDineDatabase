-- level 0
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

-- Level 1
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

-- Level 2

-- Cookbook: every registered cookbook
-- Candidate keys: COOKBOOK_ID
CREATE TABLE DASC5306_FALL26_S001_T4_Cookbook (
   COOKBOOK_ID NUMBER(10) NOT NULL,
   cookbook_name VARCHAR2(100) NOT NULL,
   date_of_creation DATE NOT NULL,
   description VARCHAR2(500) NOT NULL,
   primary_cuisine VARCHAR2(50) NOT NULL,
   CHEF_MAV_ID CHAR(10) NOT NULL,
    -- ADDING CONSTRAINTS
   CONSTRAINT T4_Cookbook_PK primary key (cookbook_id),
   CONSTRAINT T4_Cookbook_CK_NUMBER CHECK(cookbook_id > 0),
   -- No ON DELETE: a chef who still has cookbooks cannot be deleted (protects cookbooks). 
   CONSTRAINT T4_Cookbook_FK_Chef FOREIGN KEY (CHEF_MAV_ID) REFERENCES DASC5306_Fall26_S001_T4_Chef(CHEF_MAV_ID) 
);

-- Follow_Unfollow: which homecook follows which chef
-- Candidate keys: (HOMECOOK_MAV_ID, CHEF_MAV_ID)
CREATE TABLE DASC5306_Fall26_S001_T4_Follow_Unfollow (
    HOMECOOK_MAV_ID  char(10)  NOT NULL,
    CHEF_MAV_ID      char(10)  NOT NULL,
    CONSTRAINT T4_Follow_PK PRIMARY KEY (HOMECOOK_MAV_ID, CHEF_MAV_ID),
    CONSTRAINT T4_Follow_CK_self CHECK (HOMECOOK_MAV_ID <> CHEF_MAV_ID),
    -- ON DELETE CASCADE: if the homecook is deleted, their follows mean nothing.
    CONSTRAINT T4_Follow_FK_Homecook FOREIGN KEY (HOMECOOK_MAV_ID)
        REFERENCES DASC5306_Fall26_S001_T4_Homecook(HOMECOOK_MAV_ID) ON DELETE CASCADE,
    -- ON DELETE CASCADE: if the chef is deleted, nobody can follow them anymore.
    CONSTRAINT T4_Follow_FK_Chef FOREIGN KEY (CHEF_MAV_ID)
        REFERENCES DASC5306_Fall26_S001_T4_Chef(CHEF_MAV_ID) ON DELETE CASCADE
);


-- LEVEL 3

-- Subscribe: which homecook subscribes to which cookbook
-- Candidate Keys: (HOMECOOK_MAV_ID, COOKBOOK_ID)
CREATE TABLE DASC5306_Fall26_S001_T4_Subscribe (
    HOMECOOK_MAV_ID CHAR(10) NOT NULL,
    COOKBOOK_ID NUMBER(10) NOT NULL,
    CONSTRAINT T4_Subscribe_PK PRIMARY KEY (HOMECOOK_MAV_ID, COOKBOOK_ID),
    -- ON DELETE CASCADE: if the homecook is deleted, their subscriptions go too.
    CONSTRAINT T4_Subscribe_FK_Homecook FOREIGN KEY (HOMECOOK_MAV_ID) 
        REFERENCES DASC5306_Fall26_S001_T4_Homecook (HOMECOOK_MAV_ID) ON DELETE CASCADE,
    -- ON DELETE CASCADE: if the cookbook is deleted, nobody can subscribe to it. 
    CONSTRAINT T4_Subscribe_FK_Cookbook FOREIGN KEY (COOKBOOK_ID) 
        REFERENCES DASC5306_Fall26_S001_T4_Cookbook (COOKBOOK_ID) ON DELETE CASCADE
);

-- Recipe: every recipe, numbered within its cookbook (recipe numbers restart at 1 per cookbook)
-- Candidate keys: (COOKBOOK_ID, RECIPE_NUMBER)
CREATE TABLE DASC5306_Fall26_S001_T4_Recipe (
    COOKBOOK_ID NUMBER(10) NOT NULL, 
    RECIPE_NUMBER NUMBER(5) NOT NULL,
    title VARCHAR2(150) NOT NULL,
    source_url VARCHAR2(200) NOT NULL,
    date_of_publish DATE NOT NULL,
    -- 'HH24:MI' (Oracle has no TIME type)
    time_of_publish VARCHAR2(5) NOT NULL,
    meal_type VARCHAR2(15) NOT NULL,
    ingredient_1 VARCHAR2(50) NOT NULL,
    ingredient_2 VARCHAR2(50) ,
    ingredient_3 VARCHAR2(50) ,
    preparation_time NUMBER(4) NOT NULL,
    -- Minutes (0 = no-cook recipe, e.g. salad)
    cook_time NUMBER(4) NOT NULL,
    total_calories NUMBER(5) NOT NULL,
    CONSTRAINT T4_Recipe_PK PRIMARY KEY (COOKBOOK_ID, RECIPE_NUMBER),
    CONSTRAINT T4_Recipe_CK_number CHECK (RECIPE_NUMBER > 0),
    CONSTRAINT T4_Recipe_CK_time CHECK (REGEXP_LIKE(time_of_publish, '^([01][0-9]|2[0-3]):[0-5][0-9]$')),
    CONSTRAINT T4_Recipe_CK_meal CHECK (meal_type IN ('Breakfast','Lunch','Dinner','Snack','Dessert')),
    CONSTRAINT T4_Recipe_CK_prep CHECK (preparation_time > 0),
    CONSTRAINT T4_Recipe_CK_cook CHECK (cook_time >= 0),
    CONSTRAINT T4_Recipe_CK_calories CHECK (total_calories >= 0),
    CONSTRAINT T4_Recipe_CK_url CHECK (source_url LIKE 'http%'),
    -- ON DELETE CASCADE: a recipe cannot exist without its cookbook (COOKBOOK_ID) is part of the PK)
    CONSTRAINT T4_Recipe_FK_Cookbook FOREIGN KEY (COOKBOOK_ID) 
        REFERENCES DASC5306_Fall26_S001_T4_Cookbook(COOKBOOK_ID) ON DELETE CASCADE
);

-- Level 4

-- Like_Dislike: a homecook's single reaction (Like or Dislike) to a recipe
-- Candidate Keys: (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER)
CREATE TABLE DASC5306_Fall26_S001_T4_Like_Dislike (
    HOMECOOK_MAV_ID   CHAR(10)      NOT NULL,
    COOKBOOK_ID       NUMBER(10)    NOT NULL,
    RECIPE_NUMBER     NUMBER(5)     NOT NULL,
    interaction_type  VARCHAR2(7)   NOT NULL,
    CONSTRAINT T4_Like_PK PRIMARY KEY (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER),
    CONSTRAINT T4_Like_CK_type CHECK (interaction_type IN ('Like', 'Dislike')),
    -- ON DELETE CASCADE: if the homecook is deleted, their reaction go too. 
    CONSTRAINT T4_Like_FK_Homecook FOREIGN KEY (HOMECOOK_MAV_ID)
        REFERENCES DASC5306_Fall26_S001_T4_Homecook(HOMECOOK_MAV_ID) ON DELETE CASCADE,
    -- ON DELETE CASCADE: composite FK; if the recipe is deleted, its reactions go too.
    CONSTRAINT T4_Like_FK_Recipe FOREIGN KEY (COOKBOOK_ID, RECIPE_NUMBER)
        REFERENCES DASC5306_Fall26_S001_T4_Recipe(COOKBOOK_ID, RECIPE_NUMBER) ON DELETE CASCADE
);

-- Read: each reading session of a recipe by a homecook (the same recipe can be read many times)
-- Candidate keys: (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time)
CREATE TABLE DASC5306_Fall26_S001_T4_Read (
    HOMECOOK_MAV_ID   CHAR(10)       NOT NULL,
    COOKBOOK_ID       NUMBER(10)     NOT NULL,
    RECIPE_NUMBER     NUMBER(5)      NOT NULL,
    start_time        TIMESTAMP      NOT NULL,
    end_time          TIMESTAMP,                     -- NULL = session still open
    location          VARCHAR2(100),
    CONSTRAINT T4_Read_PK PRIMARY KEY (HOMECOOK_MAV_ID, COOKBOOK_ID, RECIPE_NUMBER, start_time),
    CONSTRAINT T4_Read_CK_times CHECK (end_time > start_time),            -- NULL end_time passes
    -- ON DELETE CASCADE: if the homecook is deleted, their reading history goes too.
    CONSTRAINT T4_Read_FK_Homecook FOREIGN KEY (HOMECOOK_MAV_ID)
        REFERENCES DASC5306_Fall26_S001_T4_Homecook(HOMECOOK_MAV_ID) ON DELETE CASCADE,
    -- ON DELETE CASCADE: composite FK; if the recipe is deleted, its reads go too.
    CONSTRAINT T4_Read_FK_Recipe FOREIGN KEY (COOKBOOK_ID, RECIPE_NUMBER)
        REFERENCES DASC5306_Fall26_S001_T4_Recipe(COOKBOOK_ID, RECIPE_NUMBER) ON DELETE CASCADE
);

-- Display_On: which campaign (ad) is displayed on which recipe, and its cost
-- Candidate keys: (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER)
CREATE TABLE DASC5306_Fall26_S001_T4_Display_On (
    COOKBOOK_ID                   NUMBER(10)   NOT NULL,
    RECIPE_NUMBER                 NUMBER(5)    NOT NULL,
    MERCHANT_REGISTRATION_NUMBER  CHAR(10)     NOT NULL,
    CAMPAIGN_NUMBER               NUMBER(10)   NOT NULL,
    display_cost                  NUMBER(8,2)  NOT NULL,
    CONSTRAINT T4_Display_PK PRIMARY KEY
        (COOKBOOK_ID, RECIPE_NUMBER, MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER),
    CONSTRAINT T4_Display_CK_cost CHECK (display_cost >= 0),
    -- ON DELETE CASCADE: composite FK; if the recipe is deleted, its ad placements go too.
    CONSTRAINT T4_Display_FK_Recipe FOREIGN KEY (COOKBOOK_ID, RECIPE_NUMBER)
        REFERENCES DASC5306_Fall26_S001_T4_Recipe(COOKBOOK_ID, RECIPE_NUMBER) ON DELETE CASCADE,
    -- ON DELETE CASCADE: composite FK; if the campaign ends (is deleted), its placements go too.
    CONSTRAINT T4_Display_FK_Campaign FOREIGN KEY (MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER)
        REFERENCES DASC5306_Fall26_S001_T4_Campaign(MERCHANT_REGISTRATION_NUMBER, CAMPAIGN_NUMBER) ON DELETE CASCADE
);
-- ===================== TRIGGERS =====================
-- Business rules that a CHECK constraint cannot enforce
-- (they need SYSDATE or data from another table).

-- T1: User must be at least 18, and cannot enroll in the future.
create or replace trigger t4_trg_user_dates before
   insert or update of date_of_birth,date_of_enrollment on dasc5306_fall26_s001_t4_user
   for each row
begin
   if :new.date_of_birth > add_months(
      sysdate,
      -216
   ) then          -- 216 months = 18 years
      raise_application_error(
         -20001,
         'User must be at least 18 years old.'
      );
   end if;
   if :new.date_of_enrollment > sysdate then
      raise_application_error(
         -20002,
         'Enrollment date cannot be in the future.'
      );
   end if;
end;
/

-- T2: A cookbook cannot be created in the future.
create or replace trigger t4_trg_cookbook_date before
   insert or update of date_of_creation on dasc5306_fall26_s001_t4_cookbook
   for each row
begin
   if :new.date_of_creation > sysdate then
      raise_application_error(
         -20003,
         'Cookbook creation date cannot be in the future.'
      );
   end if;
end;
/

-- T3: A recipe cannot be published in the future,
--     or before its cookbook was created (cross-table rule).
create or replace trigger t4_trg_recipe_date before
   insert or update of date_of_publish,cookbook_id on dasc5306_fall26_s001_t4_recipe
   for each row
declare
   v_created date;
begin
   if :new.date_of_publish > sysdate then
      raise_application_error(
         -20004,
         'Recipe publish date cannot be in the future.'
      );
   end if;
   select date_of_creation
     into v_created
     from dasc5306_fall26_s001_t4_cookbook
    where cookbook_id = :new.cookbook_id;
   if :new.date_of_publish < v_created then
      raise_application_error(
         -20005,
         'Recipe cannot be published before its cookbook was created.'
      );
   end if;
exception
   when no_data_found then
      null;   -- cookbook doesn't exist: let the FK constraint report it
end;
/

-- T4: A reading session cannot start in the future,
--     or before the recipe was published (cross-table rule).
create or replace trigger t4_trg_read_time before
   insert or update of start_time on dasc5306_fall26_s001_t4_read
   for each row
declare
   v_published date;
begin
   if :new.start_time > systimestamp then
      raise_application_error(
         -20006,
         'Reading session cannot start in the future.'
      );
   end if;
   select date_of_publish
     into v_published
     from dasc5306_fall26_s001_t4_recipe
    where cookbook_id = :new.cookbook_id
      and recipe_number = :new.recipe_number;
   if :new.start_time < v_published then
      raise_application_error(
         -20007,
         'A recipe cannot be read before it was published.'
      );
   end if;
exception
   when no_data_found then
      null;   -- recipe doesn't exist: let the FK constraint report it
end;
/

-- T5: A homecook can only Like/Dislike a recipe they have read at least once.
create or replace trigger t4_trg_like_requires_read before
   insert on dasc5306_fall26_s001_t4_like_dislike
   for each row
declare
   v_reads number;
begin
   select count(*)
     into v_reads
     from dasc5306_fall26_s001_t4_read
    where homecook_mav_id = :new.homecook_mav_id
      and cookbook_id = :new.cookbook_id
      and recipe_number = :new.recipe_number;
   if v_reads = 0 then
      raise_application_error(
         -20008,
         'Homecook must read the recipe before liking/disliking it.'
      );
   end if;
end;
/
