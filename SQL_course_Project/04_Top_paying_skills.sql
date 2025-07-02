-- Calculates the average salary for job postings by individual skill 
SELECT
  skills_dim.skills AS skill, 
  ROUND(AVG(job_postings_fact.salary_year_avg),0) AS avg_salary -- round up function was newly used here. 
FROM
  job_postings_fact
	INNER JOIN
	  skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
	INNER JOIN
	  skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  job_postings_fact.job_title_short = 'Data Analyst' 
  AND job_postings_fact.salary_year_avg IS NOT NULL 
	-- AND job_work_from_home = True  -- optional to filter for remote jobs
GROUP BY
  skills_dim.skills 
ORDER BY
  avg_salary DESC
LIMIT 20; 

/*
Top Paying Skills – Key Insights

Niche = High Pay
Rare skills like svn and solidity command top salaries due to low supply and specialized use (e.g., legacy systems, blockchain).

AI & ML Frameworks Are Lucrative
Tools like pytorch, keras, hugging face, and tensorflow reflect strong demand for deep learning and NLP expertise.

DevOps & Data Infrastructure Skills Boost Value
Knowledge of terraform, ansible, puppet, gitlab, and kafka signals production-level data maturity—highly rewarded.

AutoML & Hybrid Skills Matter
Platforms like datarobot and tools like dplyr show value in combining automation with analytical rigor.

Common ≠ Highest Paying
Skills like SQL, Excel, and Power BI are widely required but don’t differentiate on pay—specialize to stand out.
*/