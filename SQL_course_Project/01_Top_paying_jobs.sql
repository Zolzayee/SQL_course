--Top 10 highest paying data analyst roles that are either remote or local
-- basic query #01 
SELECT
	job_id,
	job_title,
	job_location,
	job_schedule_type,
	salary_year_avg,
	job_posted_date
FROM
	job_postings_fact
WHERE
	job_title = 'Data Analyst'
	AND salary_year_avg IS NOT NULL
	AND job_location = 'Anywhere'
ORDER BY
	salary_year_avg DESC 
LIMIT 10;

-- query #02 
SELECT
	job_id,
	name AS company_name,
	job_title,
	job_location,
	job_schedule_type,
	salary_year_avg,
	job_posted_date
FROM
	job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
	job_title = 'Data Analyst'
	AND salary_year_avg IS NOT NULL
	AND job_location = 'Anywhere'
ORDER BY
	salary_year_avg DESC 
LIMIT 10;

/* 

CHATGPT provided insights 

Key highlights:
A Data Analyst role is surprisingly the top earner at $650,000, possibly due to a niche industry, seniority mislabel, or equity compensation.
Leadership roles like Director of Analytics and Associate Director – Data Insights follow with strong salaries above $250K.
Even mid-level roles (e.g., Marketing Data Analyst) can command high pay when domain expertise is valued.

*/