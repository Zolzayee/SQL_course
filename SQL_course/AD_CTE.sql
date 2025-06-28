-- Problem statement 01 -- 

/*Identify companies with the most diverse (unique) job titles. Use a CTE to count the number of unique job titles per company, 
then select companies with the highest diversity in job titles.

-- HINT -- 
Use a CTE to count the distinct number of job titles for each company.
After identifying the number of unique job titles per company, join this result with the company_dim table to get the company names.
Order your final results by the number of unique job titles in descending order to highlight the companies with the highest diversity.
Limit your results to the top 10 companies. This limit helps focus on the companies with the most significant diversity in job roles. 
Think about how SQL determines which companies make it into the top 10 when there are ties in the number of unique job titles.*/


WITH unique_job_count AS
(
    SELECT
        COUNT(DISTINCT(job_title)) as job_title_count,
        company_id
    FROM 
        job_postings_fact
    GROUP BY
        company_id
) 
SELECT
    company_dim.name as company_name,
    unique_job_count.job_title_count
FROM
    company_dim
INNER JOIN unique_job_count ON company_dim.company_id = unique_job_count.company_id
ORDER BY
job_title_count DESC
LIMIT 10;

--Problem Statement 02 --
/*
Explore job postings by listing job id, job titles, company names, and their average salary rates, 
while categorizing these salaries relative to the average in their respective countries. 
Include the month of the job posted date. 
Use CTEs, conditional logic, and date functions, to compare individual salaries with national averages.

--Hint--
Define a CTE to calculate the average salary for each country. This will serve as a foundational dataset for comparison.
Within the main query, use a CASE WHEN statement to categorize each salary as 'Above Average' or 'Below Average'
 based on its comparison (>) to the country's average salary calculated in the CTE.
To include the month of the job posting, use the EXTRACT function on the job posting date within your SELECT statement.
Join the job postings data (job_postings_fact) with the CTE to compare individual salaries to the average. 
Additionally, join with the company dimension (company_dim) table to get company names linked to each job posting.*/


WITH countries_avg AS 
(
SELECT
    DISTINCT(job_country) as countries,
    job_id,
    AVG(salary_year_avg) as country_avg_salary
FROM
    job_postings_fact
GROUP BY
    countries
)

SELECT
AVG(salary_year_avg) as overall_avg_salary,
EXTRACT(MONTH FROM job_posted_date),
job_id
FROM job_postings_fact
CASE
WHEN overall_avg_salary > countries_avg THEN 'Above Avg'
WHEN overall_avg_salary < countries_avg THEN 'Below Avg'
END as avg_salary_category,
INNER JOIN job_postings_fact
ON countries_avg.job_id = job_postings_fact.job_id; /*this is what I got, 
and I did a very beginner level mistake of writing case function after the from statement. WTF!! */

-- gets average job salary for each country
WITH avg_salaries AS (
    SELECT 
        job_country, 
        AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    GROUP BY job_country
)
SELECT
    -- Gets basic job info
    job_postings.job_id,
    job_postings.job_title,
    companies.name AS company_name,
    job_postings.salary_year_avg AS salary_rate,
    -- categorizes the salary as above or below average the average salary for the country
    CASE
        WHEN job_postings.salary_year_avg > avg_salaries.avg_salary
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS salary_category,
    -- gets the month and year of the job posting date
    EXTRACT(MONTH FROM job_postings.job_posted_date) AS posting_month
FROM
    job_postings_fact as job_postings
INNER JOIN
    company_dim as companies ON job_postings.company_id = companies.company_id
INNER JOIN
    avg_salaries ON job_postings.job_country = avg_salaries.job_country
ORDER BY
    -- Sorts it by the most recent job postings
    posting_month desc;

/*CTEs
Problem Statement 03 
Calculate the number of unique skills required by each company. 
Aim to quantify the unique skills required per company and identify which of these companies offer
 the highest average salary for positions necessitating at least one skill. 
 For entities without skill-related job postings, 
 list it as a zero skill requirement and a null salary. 
 Use CTEs to separately assess the unique skill count and the maximum average salary offered by these companies.

Hint
Use two CTEs:
The first should focus on counting the unique skills required by each company.
The second CTE should aim to find the highest average salary offered by these companies.
Ensure the final output includes companies without skill-related job postings. 
This involves use of LEFT JOINs to maintain companies in the result set even if they don't match criteria in the subsequent CTEs.
After creating the CTEs, the main query joins the company dimension table with the results of both CTEs.*/

--SOLUTION 

-- Counts the distinct skills required for each company's job posting

WITH required_skills AS (
    SELECT
        companies.company_id,
        COUNT(DISTINCT skills_to_job.skill_id) AS unique_skills_required
    FROM
        company_dim AS companies 
    LEFT JOIN job_postings_fact as job_postings ON companies.company_id = job_postings.company_id
    LEFT JOIN skills_job_dim as skills_to_job ON job_postings.job_id = skills_to_job.job_id
    GROUP BY
        companies.company_id
),
-- Gets the highest average yearly salary from the jobs that require at least one skills 
max_salary AS (
    SELECT
        job_postings.company_id,
        MAX(job_postings.salary_year_avg) AS highest_average_salary
    FROM
        job_postings_fact AS job_postings
    WHERE
        job_postings.job_id IN (SELECT job_id FROM skills_job_dim)
    GROUP BY
        job_postings.company_id
)
-- Joins 2 CTEs with table to get the query
SELECT
    companies.name,
    required_skills.unique_skills_required as unique_skills_required, --handle companies w/o any skills required
    max_salary.highest_average_salary
FROM
    company_dim AS companies
LEFT JOIN required_skills ON companies.company_id = required_skills.company_id
LEFT JOIN max_salary ON companies.company_id = max_salary.company_id
ORDER BY
    unique_skills_required DESC
LIMIT 20;

    -- CHATGPT POLISHED MY FIRST ATTEMPT 

WITH skills AS (
    SELECT DISTINCT 
        skills_dim.skills AS unique_skills,
        skills_job_dim.job_id
    FROM skills_dim
    LEFT JOIN skills_job_dim 
        ON skills_dim.skill_id = skills_job_dim.skill_id
),

last_all AS (
    SELECT 
        s.unique_skills,
        j.company_id
    FROM job_postings_fact j
    LEFT JOIN skills s 
        ON j.job_id = s.job_id
),

companies_high_salary AS (
    SELECT 
        company_id,
        MAX(salary_year_avg) AS company_high_salary
    FROM job_postings_fact
    GROUP BY company_id
)

SELECT 
    c.name AS company_name,
    COUNT(DISTINCT l.unique_skills) AS count_unique_skills,
    a.company_high_salary
FROM company_dim c
INNER JOIN last_all l 
    ON c.company_id = l.company_id
INNER JOIN companies_high_salary a 
    ON c.company_id = a.company_id
GROUP BY 
    c.name, a.company_high_salary
ORDER BY 
    count_unique_skills DESC
LIMIT 20;
