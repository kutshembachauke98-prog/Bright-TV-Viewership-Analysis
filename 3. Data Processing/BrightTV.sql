--=============================================================
--1.DATA EXPLORATION
--=============================================================
SELECT * 
FROM `workspace`.`bright_tv`.`user_profile` limit 100;
SELECT *
    FROM `workspace`.`bright_tv`.`viewership` limit 100;

--=============================================================
--2.Checking unique Users
--=============================================================
SELECT COUNT(DISTINCT UserID) AS unique_users
FROM `workspace`.`bright_tv`.`user_profile`;

--We have  5375 Unique users

--=============================================================
--3.Gender Distribution
--=============================================================
SELECT gender, 
       COUNT(*) AS count
FROM `workspace`.`bright_tv`.`user_profile`
GROUP BY gender;
--We have 3918 males, 537 female and 920 Unknown Users

--=============================================================
--4. Province distribution
--=============================================================
SELECT province, COUNT(*) AS count
FROM `workspace`.`bright_tv`.`user_profile`
GROUP BY province;

-- The dataset consist of 9 different Provinces with 1 Unknown province

--===============================================================
--5. Race distribution
--===============================================================
SELECT race, COUNT(*) AS count
FROM `workspace`.`bright_tv`.`user_profile`
GROUP BY race;

--We have 760 white people, 
--1811 black, 
--679 Coloured people, 
--768 indian_asian and 1357 with no specified race

--=============================================================
--6. Check NULL values (VERY IMPORTANT)
--=============================================================
SELECT 
  COUNT(*) AS total_rows,
  COUNT(gender) AS known_gender,
  COUNT(*) - COUNT(gender) AS null_gender
FROM `workspace`.`bright_tv`.`user_profile`;

--No Nulls detected

--=============================================================
-- 7. Checking Age Range
--=============================================================
SELECT 
      MIN(age) As Youngest,
      MAX(Age) AS Oldest
FROM `workspace`.`bright_tv`.`user_profile`;
 
--Our youngest people are 0 years and the oldest are 114 years
--==============================================================
--DATA CLEANING AND JOINING 
--==============================================================
SELECT
    -- User Info
    `v`.`UserID0` AS user_id,


-- Clean Gender, Race, Province
COALESCE(NULLIF(u.gender,'None'),'Unknown') AS gender,
COALESCE(NULLIF(u.race,'None'),'Unknown') AS race,
INITCAP(COALESCE(NULLIF(u.province,'None'),'Unknown')) AS province,


-- Age and Age Group
CASE 
    WHEN u.Age IS NULL THEN 0 ELSE u.Age END AS age,
CASE
    WHEN u.Age BETWEEN 0 AND 12 THEN 'Children'
    WHEN u.Age BETWEEN 13 AND 19 THEN 'Teen'
    WHEN u.Age BETWEEN 20 AND 35 THEN 'Youth'
    WHEN u.Age BETWEEN 36 AND 55 THEN 'Adult'
    ELSE 'Elderly'
END AS age_group,

-- Viewership Info
    v.Channel2 AS channel,

-- South African time (no UTC)
    CAST(v.RecordDate2 + INTERVAL 2 HOURS AS DATE) AS session_date,            -- only date
    date_format(v.RecordDate2 + INTERVAL 2 HOURS, 'HH:mm:ss') AS session_time, -- only time

-- Extract hour for analysis
    HOUR(v.RecordDate2 + INTERVAL 2 HOURS) AS session_hour,

-- Time-of-day categories / Creating time buckets 
CASE
    WHEN HOUR(v.RecordDate2 + INTERVAL 2 HOURS) BETWEEN 5 AND 11 THEN 'Morning'
    WHEN HOUR(v.RecordDate2 + INTERVAL 2 HOURS) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN HOUR(v.RecordDate2 + INTERVAL 2 HOURS) BETWEEN 18 AND 23 THEN 'Evening'
    WHEN HOUR(v.RecordDate2 + INTERVAL 2 HOURS) BETWEEN 0 AND 4 THEN 'Midnight'
    
END AS time_of_day,

-- Duration in minutes
    (HOUR(v.`Duration 2`) * 60 + MINUTE(v.`Duration 2`) + SECOND(v.`Duration 2`) / 60) AS duration_minutes

FROM viewership v
LEFT JOIN user_profile u
ON v.UserID0 = u.UserID;
