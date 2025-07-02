-- Identifies the top 5 most demanded skills for Data Analyst job postings
SELECT
  skills_dim.skills,
  COUNT(skills_job_dim.job_id) AS demand_count
FROM
  job_postings_fact
  INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  -- Filters job titles for 'Data Analyst' roles
  job_postings_fact.job_title_short = 'Data Analyst'
    AND job_work_from_home = True -- optional to filter for remote jobs
GROUP BY
  skills_dim.skills
ORDER BY
  demand_count DESC
LIMIT 5;

/* compared insights of the previous query provided by CHATGpt

Key Insights
SQL is universally important
It’s the most demanded skill and also dominates in high-paying jobs. Knowing SQL is essential.

Python ranks high in both
Strong programming skills make candidates more competitive across all levels.

Excel is in high demand, but not in top-paying jobs
It suggests Excel is more important for entry/mid roles, while advanced tools are needed at senior levels.

Niche cloud/data tools (Databricks, Snowflake, Azure)
These are more common in high-paying jobs — likely because they indicate experience with big data systems and modern analytics stacks.

Visualization skills (Tableau, Power BI)
Both are important across job tiers, but higher-paying roles might emphasize strategic over operational use.

*/