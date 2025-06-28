-- Practice table --
CREATE TABLE practice_job_applied (
    job_id INT,
    application_sent_date DATE,
    custom_resume BOOLEAN,
    resume_file_name VARCHAR(255),
    cover_letter_sent BOOLEAN,
    cover_letter_file_name VARCHAR(255),
    status VARCHAR(50)
);

INSERT INTO practice_job_applied (job_id, application_sent_date, custom_resume, resume_file_name, cover_letter_sent, cover_letter_file_name, status) 
VALUES
(1, '2024-02-01', TRUE, 'resume_01.pdf', TRUE, 'cover_letter_01.pdf', 'submitted'),
(2, '2024-02-02', FALSE, 'resume_02.pdf', FALSE, NULL, 'interview scheduled'),
(3, '2024-02-03', TRUE, 'resume_03.pdf', TRUE, 'cover_letter_03.pdf', 'ghosted'),
(4, '2024-02-04', TRUE, 'resume_04.pdf', FALSE, NULL, 'submitted'),
(5, '2024-02-05', FALSE, 'resume_05.pdf', TRUE, 'cover_letter_05.pdf', 'rejected');

SELECT*
from practice_job_applied; 

-- ALTER TABLE table_name
-- ADD column_name datatype;
-- RENAME COLUMN column_name TO new_name;
-- ALTER COLUMN column_name TYPE datatype;
-- DROP COLUMN column_name;

ALTER TABLE practice_job_applied
ADD contact VARCHAR(50);

ALTER TABLE practice_job_applied
RENAME COLUMN contact TO contact_name;

ALTER TABLE practice_job_applied
ALTER COLUMN contact_name TYPE TEXT;

ALTER TABLE practice_job_applied
DROP COLUMN contact_name;

UPDATE practice_job_applied SET contact_name = 'Erlich Bachman' WHERE job_id = 1;
UPDATE practice_job_applied SET contact_name = 'Dinesh Chugtai' WHERE job_id = 2;
UPDATE practice_job_applied SET contact_name = 'Bertram Gilfoyle' WHERE job_id = 3;
UPDATE practice_job_applied SET contact_name = 'Jian Yang' WHERE job_id = 4;
UPDATE practice_job_applied SET contact_name = 'Big Head' WHERE job_id = 5;


SELECT*
from practice_job_applied;


--Problem statements -- 

-- Problem Statement 01 -- 
/* Create a table named data_science_jobs that will hold information about job postings. 
Include the following columns: 
job_id (integer and primary key), 
job_title (text), company_name (text), 
and post_date (date). */

CREATE TABLE data_science_jobs (
    job_id INT primary key, 
    job_title TEXT, 
    company_name TEXT, 
    post_date DATE          -- I got it! 
); 

SELECT*
FROM data_science_jobs; 

--Problem Statement 02 -- 
/* Insert three job postings into the data_science_jobs table. 
Make sure each job posting has a unique job_id, a job_title, a company_name, and a post_date.*/

INSERT INTO data_science_jobs (job_id, job_title, company_name, post_date)
VALUES
(1, 'Data Scientist', 'Tech Innovations', '2023-01-01'),
(2, 'Machine Learning Engineer', 'Data Driven Co', '2023-01-15'),
(3, 'AI Specialist', 'Future Tech', '2023-02-01'); -- couldn't get this one, bcz I added all the column names in the section of values. 

--Problem Statement 03 --
/* Alter the data_science_jobs table to add a new boolean column (uses True or False values) named remote.*/

ALTER table data_science_jobs
add column remote boolean; -- couldn't get this one, because I added (=) after add column. 

--Problem Statement 04 --
/* Rename the post_date column to posted_on from the data_science_job table.*/

ALTER TABLE data_science_jobs
rename post_date to posted_on; -- couldn't get this one as well, bcz I used 'as' instead of 'to'. 

--Problem Statement 05 --
/* Modify the remote column so that it defaults to FALSE in the data_science_job table.*/

ALTER TABLE data_science_jobs 
ALTER COLUMN remote SET DEFAULT FALSE;

INSERT INTO data_science_jobs (job_id, job_title, company_name, posted_on) VALUES (4, 'Data Scientist', 'Google', '2023-02-05');

--Problem Statement 06 --
/* Drop the company_name column from the data_science_jobs table. */

ALTER TABLE data_science_jobs
DROP COLUMN company_name; 

--Problem Statement 07 --
/* Update the job posting with the job_id = 2 . Update the remote column for this job posting to TRUE in data_science_jobs.*/

UPDATE data_science_jobs
SET remote = 'TRUE'
WHERE job_id = 2;


--Problem Statement 08 --
/*Drop the data_science_jobs table.*/