-- Problem Statement 01 --

/*Create a unified query that categorizes job postings into two groups: 
those with salary information (salary_year_avg or salary_hour_avg is not null) and those without it. 
Each job posting should be listed with its job_id, job_title, and an indicator of whether salary information is provided.

-- Hint -- 
Use UNION ALL to merge results from two separate queries.
For the first query, filter job postings where either salary field is not null to identify postings with salary information.
For the second query, filter for postings where both salary fields are null to identify postings without salary information.
Include a custom field to indicate the presence or absence of salary information in the output.
When categorizing data, you can create a custom label directly in your query using string literals, 
such as 'With Salary Info' or 'Without Salary Info'. 
These literals are manually inserted values that indicate specific characteristics of each record.
 An example of this is as a new column in the query that doesn’t have salary information, put: 
 'Without Salary Info' AS salary_info. As the last column in the SELECT statement.*/



 SELECT *
 FROM (
 (
    SELECT 
 salary_year_avg,
 salary_hour_avg
 FROM job_postings_fact
 ORDER BY 
 salary_year_avg DESC
 )

UNION ALL 

 (
SELECT 
 salary_year_avg,
 salary_hour_avg
 FROM job_postings_fact
 WHERE 
    salary_year_avg is not NULL 
    AND 
    salary_hour_avg is not NULL
 )
 ) AS salary_info; -- my first attempt 


 -- Select job postings with salary information
(
SELECT 
    job_id, 
    job_title, 
    'With Salary Info' AS salary_info  -- Custom field indicating salary info presence
FROM 
    job_postings_fact
WHERE 
    salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL  
)
UNION ALL
 -- Select job postings without salary information
(
SELECT 
    job_id, 
    job_title, 
    'Without Salary Info' AS salary_info  -- Custom field indicating absence of salary info
FROM 
    job_postings_fact
WHERE 
    salary_year_avg IS NULL AND salary_hour_avg IS NULL 
)
ORDER BY 
    salary_info DESC, 
    job_id; 

-- Problem Statement 02 -- 

/* Retrieve the job id, job title short, job location, job via, skill and skill type 
for each job posting from the first quarter (January to March). 
Using a subquery to combine job postings from the first quarter 
(these tables were created in the Advanced Section - Practice Problem 6 [include timestamp of Youtube video])
 Only include postings with an average yearly salary greater than $70,000.

-- Hint --
Use UNION ALL to combine job postings from January, February, and March into a single dataset.
Apply a LEFT JOIN to include skills information, allowing for job postings without associated skills to be included.
Filter the results to only include job postings with an average yearly salary above $70,000.*/

WITH combined AS (
    SELECT * FROM date_january
    UNION
    SELECT * FROM date_february
    UNION
    SELECT * FROM date_march
)

SELECT 
    sj.job_id,
    c.job_title_short,
    c.job_location,
    c.job_via,
    c.salary_year_avg,
    s.skills,
    s.type
FROM skills_dim s
LEFT JOIN skills_job_dim sj ON s.skill_id = sj.skill_id
LEFT JOIN combined c ON sj.job_id = c.job_id
WHERE 
salary_year_avg > 70000
ORDER BY 
job_id; 

SELECT
    job_postings_q1.job_id,
    job_postings_q1.job_title_short,
    job_postings_q1.job_location,
    job_postings_q1.job_via,
    job_postings_q1.salary_year_avg,
    skills_dim.skills,
    skills_dim.type
FROM
-- Get job postings from the first quarter of 2023
    (
    SELECT *
    FROM date_january
    UNION ALL
    SELECT *
    FROM date_february
    UNION ALL
    SELECT *
    FROM date_march
    ) as job_postings_q1
LEFT JOIN skills_job_dim ON job_postings_q1.job_id = skills_job_dim.job_id
LEFT JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_postings_q1.salary_year_avg > 70000
ORDER BY
    job_postings_q1.job_id;

-- Problem Statement 03 --
/* Analyze the monthly demand for skills by counting the number of job postings for each skill in the first quarter (January to March), 
utilizing data from separate tables for each month. Ensure to include skills from all job postings across these months. 
The tables for the first quarter job postings were created in Practice Problem 6.

-- Hint -- 
Use UNION ALL to combine job postings from January, February, and March into a consolidated dataset.
Apply the EXTRACT function to obtain the year and month from job posting dates, 
even though the month will be implicitly known from the source table.
Group the combined results by skill to summarize the total postings for each skill across the first quarter.
Join with the skills dimension table to match skill IDs with skill names.*/

SELECT 
Q1.EXTRACT (YEAR AND MONTH FROM JOB_POSTED_DATE),
Q1.job_title_short,
skills_dim.skills
FROM skills_dim
(
WITH Q1 AS 
    (SELECT * FROM date_january)
    UNION ALL
    (SELECT * FROM date_february)
    UNION ALL
    (SELECT * FROM date_march)
)
INNER JOIN skills_dim as names ON skills_job_dim.skill_id = skills_dim.skill_id
INNER JOIN names ON names.job_id = job_postings_fact.job_id 
GROUP BY skills_dim.skills; -- my attempt 

-- Step 1: Combine job postings from January, February, and March
WITH Q1 AS (
    SELECT * FROM date_january
    UNION ALL
    SELECT * FROM date_february
    UNION ALL
    SELECT * FROM date_march
)

-- Step 2: Join with skills and extract month/year
SELECT 
    EXTRACT(YEAR FROM q1.job_posted_date) AS post_year,
    EXTRACT(MONTH FROM q1.job_posted_date) AS post_month,
    q1.job_title_short,
    s.skills
FROM Q1
INNER JOIN skills_job_dim sj ON q1.job_id = sj.job_id
INNER JOIN skills_dim s ON sj.skill_id = s.skill_id
ORDER BY post_year, post_month;

-- CTE for combining job postings from January, February, and March
WITH combined_job_postings AS (
    SELECT job_id, job_posted_date
    FROM date_january
    UNION ALL
    SELECT job_id, job_posted_date
    FROM date_february
    UNION ALL
    SELECT job_id, job_posted_date
    FROM date_march
),
-- CTE for calculating monthly skill demand based on the combined postings
monthly_skill_demand AS (
    SELECT
        skills_dim.skills,  
        EXTRACT(YEAR FROM combined_job_postings.job_posted_date) AS year,  
        EXTRACT(MONTH FROM combined_job_postings.job_posted_date) AS month,  
        COUNT(combined_job_postings.job_id) AS postings_count 
    FROM
        combined_job_postings
    INNER JOIN skills_job_dim ON combined_job_postings.job_id = skills_job_dim.job_id  
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id  
    GROUP BY
        skills_dim.skills, 
        year, 
        month
)
-- Main query to display the demand for each skill during the first quarter
SELECT
    skills,  
    year,  
    month,  
    postings_count 
FROM
    monthly_skill_demand
ORDER BY
    skills, 
    year,
    month;  
