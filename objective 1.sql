USE stravafitness;
-- Sleep vs Calories Burned
SELECT 
    ROUND(AVG(s.TotalMinutesAsleep), 1) AS avg_sleep_mins,
    ROUND(AVG(a.Calories), 1) AS avg_calories_burned
FROM dailyActivity_merged a
JOIN sleepDay_merged s
    ON a.Id = s.Id
    AND a.ActivityDate = DATE(s.SleepDay);
-- Step Consistency Over Time
SELECT 
    user_Id,
    ActivityDay,
    StepTotal
FROM cleaned_dailysteps_merged
ORDER BY user_Id, ActivityDay;
-- Calories Burned on High Sleep vs Low Sleep Days
SELECT 
    CASE 
        WHEN s.TotalMinutesAsleep >= 420 THEN 'Well Rested (7+ hrs)'
        ELSE 'Sleep Deprived (<7 hrs)'
    END AS sleep_quality,
    ROUND(AVG(a.Calories), 0) AS avg_calories_burned
FROM dailyActivity_merged a
JOIN sleepDay_merged s
    ON a.Id = s.Id
    AND a.ActivityDate = DATE(s.SleepDay)
GROUP BY sleep_quality;
-- Top 10 Most Active Users (Based on Total Steps)
SELECT 
    Id AS user_id,
    ROUND(AVG(TotalSteps), 0) AS avg_daily_steps,
    ROUND(AVG(Calories), 0) AS avg_calories
FROM dailyActivity_merged
GROUP BY Id
ORDER BY avg_daily_steps DESC
LIMIT 10;
-- Daily trends for each user
SELECT 
    Id,
    ActivityDate,
    TotalSteps,
    Calories,
    VeryActiveMinutes,
    SedentaryMinutes
FROM dailyActivity_merged;
-- Merged engagement table
CREATE TABLE unified_engagement_data1 AS
SELECT 
    da.Id,
    da.ActivityDate,
    da.TotalSteps,
    da.SedentaryMinutes,
    da.Calories,
    sd.TotalMinutesAsleep,
    sd.TotalTimeInBed
FROM dailyActivity_merged da
JOIN sleepDay_merged sd
  ON da.Id = sd.Id AND da.ActivityDate = sd.SleepDay;
-- Check how weight & BMI relate to active lifestyle
SELECT 
    wl.user_id,
    wl.WeightKg,
    wl.BMI,
    da.TotalSteps,
    da.Calories
FROM weightloginfo wl
JOIN dailyactivity_merged da 
    ON wl.user_id = da.Id
WHERE wl.WeightKg IS NOT NULL 
  AND wl.BMI IS NOT NULL;