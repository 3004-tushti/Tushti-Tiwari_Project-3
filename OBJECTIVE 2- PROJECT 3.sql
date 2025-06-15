-- OBJECTIVE 
USE stravafitness;
SELECT 
    a.Id AS user_id,
    a.ActivityDate,
    a.TotalSteps,
    a.SedentaryMinutes,
    a.VeryActiveMinutes,
    a.FairlyActiveMinutes,
    a.LightlyActiveMinutes,
    s.TotalMinutesAsleep,
    s.TotalTimeInBed,
    c.Calories,
    ds.StepTotal
FROM dailyActivity_merged a
LEFT JOIN sleepDay_merged s 
    ON a.Id = s.Id 
    AND a.ActivityDate = DATE(s.SleepDay)
LEFT JOIN dailyCalories_merged c 
    ON a.Id = c.Id 
    AND a.ActivityDate = c.ActivityDay
LEFT JOIN cleaned_dailysteps_merged ds 
    ON a.Id = ds.user_Id 
    AND a.ActivityDate = ds.ActivityDay;
-- Engagement by Day of Week
-- 🔄 Create merged table from activity and sleep data
CREATE TABLE unified_engagement_data AS
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
  ON da.Id = sd.Id 
  AND da.ActivityDate = sd.SleepDay;
SELECT 
    DAYNAME(ActivityDate) AS day_name,
    ROUND(AVG(TotalSteps), 0) AS avg_steps,
    ROUND(AVG(SedentaryMinutes), 0) AS avg_sedentary,
    ROUND(AVG(TotalMinutesAsleep), 0) AS avg_sleep
FROM unified_engagement_data
GROUP BY day_name
ORDER BY FIELD(day_name, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
-- Correlation Between Sleep and Steps: do well-rested users walk more?
SELECT 
    TotalMinutesAsleep,
    TotalSteps
FROM unified_engagement_data
WHERE TotalMinutesAsleep IS NOT NULL AND TotalSteps IS NOT NULL;
-- User Segmentation: Sleep & Activity Profile- Prepare for user clustering in Power BI
SELECT 
    Id,
    ROUND(AVG(TotalSteps), 0) AS avg_steps,
    ROUND(AVG(Calories), 0) AS avg_calories,
    ROUND(AVG(SedentaryMinutes), 0) AS avg_sedentary,
    ROUND(AVG(TotalMinutesAsleep), 0) AS avg_sleep,
    ROUND(AVG(TotalTimeInBed), 0) AS avg_time_in_bed
FROM unified_engagement_data
GROUP BY Id;
-- Engagement Bins by Steps
SELECT 
    CASE 
        WHEN TotalSteps >= 10000 THEN 'Highly Active'
        WHEN TotalSteps >= 5000 THEN 'Moderately Active'
        ELSE 'Low Activity'
    END AS activity_level,
    COUNT(*) AS num_days,
    ROUND(AVG(TotalMinutesAsleep), 0) AS avg_sleep,
    ROUND(AVG(SedentaryMinutes), 0) AS avg_sedentary
FROM unified_engagement_data
GROUP BY activity_level;
-- When are users most active in a day?
SELECT 
    HOUR(ActivityHour) AS hour_of_day,
    AVG(StepTotal) AS avg_steps
FROM hourlysteps
GROUP BY hour_of_day
ORDER BY hour_of_day;
-- Calories burned at different hours
SELECT 
    HOUR(ActivityHour) AS hour_of_day,
    AVG(Calories) AS avg_calories
FROM hourlycalories
GROUP BY hour_of_day
ORDER BY hour_of_day;
-- When are people doing very active movements?
SELECT 
    HOUR(ActivityHour) AS hour_of_day,
    AVG(TotalIntensity) AS avg_intensity
FROM hourlyIntensities_merged
GROUP BY hour_of_day
ORDER BY hour_of_day;