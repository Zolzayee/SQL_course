SELECT 
job_title_short as title, 
job_location as location, 
job_posted_date:: date as date -- here we've used (::date) functions in order to remove timestamps from the date
FROM
 job_postings_fact;

SELECT 
job_title_short as title, 
job_location as location, 
job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' as date -- here (AT TIME ZONE) functions is tested to convert the timezone
FROM
 job_postings_fact
LIMIT 5;

SELECT 
job_title_short as title, 
EXTRACT (YEAR FROM job_posted_date) as date_year -- here we pulled only month or year by EXTRACT function 
FROM
 job_postings_fact;

-- January
REATE TABLE DATE_JANUARY AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE 
        EXTRACT(MONTH FROM job_posted_date) = '1';

SELECT*
FROM 
    DATE_JANUARY; -- to create separate table with the data only shows in January or in particular month we chose. 

-- February
CREATE TABLE DATE_FEBRUARY AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

-- March
CREATE TABLE DATE_MARCH AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

--Problem_statement 01 -- 

/*Find the average salary both yearly (salary_year_avg) and hourly (salary_hour_avg) 
for job postings using the job_postings_fact table that were posted after June 1, 2023. 
Group the results by job schedule type. 
Order by the job_schedule_type in ascending order.*/

SELECT
    job_schedule_type,
    AVG(salary_year_avg) AS avg_yearly_salary,
    AVG(salary_hour_avg) AS avg_hourly_salary
FROM
    job_postings_fact
WHERE
    job_posted_date::date > '2023-06-01'
GROUP BY
    job_schedule_type
ORDER BY
    job_schedule_type;


--Problem_statement 02 -- 

/*Count the number of job postings for each month, adjusting the job_posted_date 
to be in 'America/New_York' time zone before extracting the month. 
Assume the job_posted_date is stored in UTC. Group by and order by the month.*/

SELECT
    COUNT(job_id) as job_postings, 
    EXTRACT(MONTH FROM (job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York')) AS date_month
FROM 
    job_postings_fact
GROUP BY
    date_month
ORDER BY
    date_month ASC;

--Problem_statement 03 -- 

/*Find companies (include company name) that have posted jobs offering health insurance, 
where these postings were made in the second quarter of 2023. 
Use date extraction to filter by quarter. And order by the job postings count from highest to lowest.*/

/*Join job_postings_fact and company_dim on company_id to match jobs to companies.
Use the WHERE clause to filter for jobs with job_health_insurance column.
Use EXTRACT(QUARTER FROM job_posted_date) to filter for postings in the second quarter.
Group results by company_name.
Count the number of job postings per company with COUNT(job_id).
Use HAVING to include only companies with at least one job posting.
ORDER BY the job postings count in descending order to get highest → lowest.*/

SELECT
    company_dim.company_id, -- when using INNER join there was no need to include this. 
    company_dim.name, -- this was right but I should rename it as company_name to my joined table. 
    EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) AS posting_quarter, -- this was not neccesary when using INNER join. 
    COUNT(job_postings_fact.job_id) AS total_jobs_with_insurance 
FROM
    job_postings_fact
RIGHT JOIN company_dim /*INNER JOIN*/
    ON job_postings_fact.company_id = company_dim.company_id -- I should be using INNER join to join only colunms I needed for his query. 
WHERE 
    job_postings_fact.job_health_insurance = 'TRUE' -- correct
    AND EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) = 2 --correct
GROUP BY
    company_dim.company_id, -- it was not supposed to be added here if I didn't include it in the SELECT function first place. 
    company_dim.name,
    EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) -- it was same as the company_dim.company_id. 
ORDER BY
    posting_quarter DESC; -- it was not supposed to be ordered by, instead I should use total job_posting_count. 

--BASICALLY I GOT THE SAME RESULTS WITH MORE CROWDED AND UNLOGICAL WAY!

SELECT
    company_dim.name AS company_name,
    COUNT(job_postings_fact.job_id) AS job_postings_count
FROM
    job_postings_fact
	INNER JOIN
    company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_postings_fact.job_health_insurance = TRUE
    AND EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) = 2 
GROUP BY
    company_dim.name 
HAVING 
    COUNT(job_postings_fact.job_id) > 0
ORDER BY
	job_postings_count DESC; 

