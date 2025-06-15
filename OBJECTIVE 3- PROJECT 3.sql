USE stravafitness
-- Average daily steps, sleep, and calories per user
SELECT 
    da.Id,
    ROUND(AVG(da.TotalSteps), 0) AS avg_steps,
    ROUND(AVG(sd.TotalMinutesAsleep), 0) AS avg_sleep,
    ROUND(AVG(da.Calories), 0) AS avg_calories
FROM dailyactivity_merged da
JOIN sleepday_merged sd
    ON da.Id = sd.Id AND da.ActivityDate = sd.SleepDay
GROUP BY da.Id;
-- Merge BMI with average steps
SELECT 
    wl.user_id,
    wl.BMI,
    ROUND(AVG(da.TotalSteps), 0) AS avg_steps
FROM weightloginfo wl
JOIN dailyactivity_merged da
    ON wl.user_id = da.Id
WHERE wl.BMI IS NOT NULL
GROUP BY wl.user_id, wl.BMI;
-- Steps by day of week per user
SELECT 
    Id,
    DAYNAME(ActivityDate) AS day_of_week,
    SUM(TotalSteps) AS total_steps
FROM dailyactivity_merged
GROUP BY Id, day_of_week;
-- Chart 4 (Updated): Steps Contribution by Activity Level (Column Chart)
-- Calculate percentage contribution of each activity level to total steps
-- Average distance types per user
SELECT 
    Id,
    ROUND(AVG(VeryActiveDistance), 2) AS very_active_km,
    ROUND(AVG(LightActiveDistance), 2) AS light_active_km,
    ROUND(AVG(TotalDistance), 2) AS total_km
FROM dailyactivity_merged
GROUP BY Id;
-- Chart 5: Calories Burned by Day of Week (Column Chart)
SELECT 
    DAYNAME(ActivityDate) AS day_name,
    ROUND(AVG(Calories), 0) AS avg_calories
FROM dailyactivity_merged
GROUP BY day_name
ORDER BY FIELD(day_name, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');
--  Chart 6: User Clustering (K-means style Prework)
-- Steps + Sleep + Calories per user
SELECT 
    da.Id,
    ROUND(AVG(da.TotalSteps), 0) AS avg_steps,
    ROUND(AVG(sd.TotalMinutesAsleep), 0) AS avg_sleep,
    ROUND(AVG(da.Calories), 0) AS avg_calories,
    ROUND(AVG(da.SedentaryMinutes), 0) AS avg_sedentary
FROM dailyactivity_merged da
JOIN sleepday_merged sd
    ON da.Id = sd.Id AND da.ActivityDate = sd.SleepDay
GROUP BY da.Id;
-- Chart 7: BMI Category Distribution (Pie Chart)
-- Group users by BMI category
SELECT 
    CASE
        WHEN BMI < 18.5 THEN 'Underweight'
        WHEN BMI BETWEEN 18.5 AND 24.9 THEN 'Normal'
        WHEN BMI BETWEEN 25 AND 29.9 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category,
    COUNT(*) AS user_count
FROM weightloginfo
WHERE BMI IS NOT NULL
GROUP BY bmi_category;