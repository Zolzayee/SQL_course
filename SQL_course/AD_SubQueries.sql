-- Problem Statement 01 --

/* Identify the top 5 skills that are most frequently mentioned in job postings. 
Use a subquery to find the skill IDs with the highest counts in the skills_job_dim table 
and then join this result with the skills_dim table to get the skill names.

-- Hint --
Focus on creating a subquery that identifies and ranks (ORDER BY in descending order) the top 5 skill IDs by 
their frequency (COUNT) of mention in job postings.
Then join this subquery with the skills table (skills_dim) to match IDs to skill names.*/

SELECT 
    top_skills.skill_count,
    skills_dim.skills
FROM skills_dim
 INNER JOIN (
SELECT 
    skill_id,
    COUNT(job_id) as skill_count
FROM 
    skills_job_dim
GROUP BY
    skills_job_dim.skill_id
ORDER BY 
    skill_count DESC
LIMIT 5
) as top_skills ON skills_dim.skill_id = top_skills.skill_id
ORDER BY 
    top_skills.skill_count DESC; 

-- Problem Statement 02 -- 

/* Determine the size category ('Small', 'Medium', or 'Large') for each company by first identifying the number of job postings they have. 
Use a subquery to calculate the total job postings per company. 
A company is considered 'Small' if it has less than 10 job postings, 
'Medium' if the number of job postings is between 10 and 50, 
and 'Large' if it has more than 50 job postings. 
Implement a subquery to aggregate job counts per company before classifying them based on size.

-- Hint -- 
Aggregate job counts per company in the subquery. This involves grouping by company and counting job postings.
Use this subquery in the FROM clause of your main query.
In the main query, categorize companies based on the aggregated job counts from the subquery with a CASE statement.
The subquery prepares data (counts jobs per company), and the outer query classifies companies based on these counts.*/

SELECT 
total_job_count.company_id,
total_job_count.job_count,
name,
CASE 
    WHEN job_count <= 10 THEN 'SMALL'
    WHEN job_count BETWEEN 10 AND 50 THEN 'MEDIUM'
    ELSE 'LARGE'
END AS company_size
FROM 
(SELECT 
    company_id,
    COUNT (job_id) as job_count
FROM 
    job_postings_fact
GROUP BY 
    company_id
ORDER BY 
    job_count DESC) as total_job_count 
ORDER BY job_count DESC;  -- the query I ran 

-- the solution --- 

SELECT
   company_id,
   name,
   -- Categorize companies
   CASE
       WHEN job_count < 10 THEN 'Small'
       WHEN job_count BETWEEN 10 AND 50 THEN 'Medium'
       ELSE 'Large'
   END AS company_size
FROM (
   -- Subquery to calculate number of job postings per company 
   SELECT
       company_dim.company_id,
       company_dim.name,
       COUNT(job_postings_fact.job_id) AS job_count
   FROM company_dim
   INNER JOIN job_postings_fact 
       ON company_dim.company_id = job_postings_fact.company_id
   GROUP BY
       company_dim.company_id,
       company_dim.name
) AS company_job_count;

-- Problem Statement 03 --

/*Find companies that offer an average salary above the overall average yearly salary of all job postings. 
Use subqueries to select companies with an average salary higher than the overall average salary (which is another subquery).

-- Hint --
Start by separating the task into two main steps:
Calculating the overall average salary
Identifying companies with higher averages.
Use a subquery (subquery 1) to find the average yearly salary across all job postings. 
Then join this subquery onto the company_dim table.
Use another subquery (subquery 2) to establish the overall average salary, 
which will help in filtering in the WHERE clause companies with higher average salaries.
Determine each company's average salary (what you got from subquery 1) and 
compare it to the overall average you calculated (subquery 2). Focus on companies that greater than this average.*/

SELECT 
    company_dim.name
FROM company_dim
INNER JOIN 
    (SELECT
        company_id,
        AVG(salary_year_avg) as avg_salary
    FROM    job_postings_fact
    GROUP BY    company_id
    ) as company_salaries
ON company_salaries.company_id = company_dim.company_id
WHERE 
    company_salaries.avg_salary > (
        SELECT AVG(salary_year_avg)
        FROM job_postings_fact
    );

--  Find individual job postings with above-average salary -- This is what I got! 
SELECT 
    job_postings_fact.salary_year_avg,
    company_dim.name
FROM job_postings_fact
INNER JOIN company_dim 
    ON job_postings_fact.company_id = company_dim.company_id
WHERE salary_year_avg IS NOT NULL
  AND salary_year_avg > (
      SELECT AVG(salary_year_avg)
      FROM job_postings_fact
  )
GROUP BY 
    company_dim.name,
    job_postings_fact.salary_year_avg;





