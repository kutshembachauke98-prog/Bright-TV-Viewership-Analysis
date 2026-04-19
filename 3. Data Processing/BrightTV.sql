select * from `workspace`.`bright_tv`.`viewership` limit 100;
---
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