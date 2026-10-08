-- projectDBdrop.sql: MavDine database
-- Drops all tables in reverse order of creation (children before parents),
-- so no table is dropped while another table still references it. 

-- Level 4
DROP TABLE DASC5306_Fall26_S001_T4_Display_On PURGE;
drop table DASC5306_Fall26_S001_T4_Read PURGE;
drop table DASC5306_Fall26_S001_T4_Like_Dislike PURGE;
-- Level 3
drop table DASC5306_Fall26_S001_T4_Recipe PURGE;
drop table DASC5306_Fall26_S001_T4_Subscribe PURGE;
-- Level 2
drop table DASC5306_Fall26_S001_T4_Follow_Unfollow PURGE;
drop table DASC5306_FALL26_S001_T4_Cookbook PURGE;
-- Level 1
drop table DASC5306_Fall26_S001_T4_Campaign PURGE;
drop table DASC5306_Fall26_S001_T4_Chef PURGE;
drop table DASC5306_Fall26_S001_T4_Homecook PURGE;
-- Level 0 
drop table DASC5306_Fall26_S001_T4_Merchant PURGE;
drop table DASC5306_Fall26_S001_T4_User PURGE;

-- Clear leftovers from earlier runs
PURGE RECYCLEBIN;