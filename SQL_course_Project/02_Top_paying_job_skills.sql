-- Gets the top 10 paying Data Analyst jobs 
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg
        -- name AS company_name
    FROM
        job_postings_fact
    -- LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst'
				AND salary_year_avg IS NOT NULL
        AND job_location = 'Anywhere'
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)

/* 

SELECT * 
FROM top_paying_jobs; 'this is very practical to check if the CTE is working correctly, felt like it might avoid some time-consuming troubleshooting later' 
*/


-- Skills required for data analyst jobs
SELECT
    top_paying_jobs.job_id, -- I liked another alternative of in case of calling all the data from CTE by writing (SELECT top_paying_job.*) 
    job_title,
    salary_year_avg,
    skills
FROM
    top_paying_jobs
	INNER JOIN
    skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
	INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC; 



/* 

CHATGPT recommended insights 

Key Insights:

High-paying roles are senior-level: Positions like "Director" or "Principal" command the highest salaries.
SQL, Python, and R are must-haves: These core skills are consistent across top roles.
Cloud and data platform knowledge boosts value: Azure, Databricks, and Snowflake are in demand.
Visualization skills round out the profile: Tools like Tableau and Power BI remain relevant. 

*/ 