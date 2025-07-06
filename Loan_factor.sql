SELECT * FROM public.loan_app

-- Make a new column to group the credit score into classes.
ALTER TABLE loan_app
ADD COLUMN credit_score_class VARCHAR(50);

UPDATE loan_app
SET credit_score_class = CASE 
	WHEN creditscore BETWEEN 300 AND 579 THEN 'Poor'
	WHEN creditscore BETWEEN 580 AND 669 THEN 'Fair'
	WHEN creditscore BETWEEN 670 AND 739 THEN 'Good'
	WHEN creditscore BETWEEN 740 AND 799 THEN 'Very Good'
	WHEN creditscore BETWEEN 800 AND 850 THEN 'Excelent'
	ELSE 'unknown'
END;

-- 1.What is the loan approval rate by credit score range?
SELECT 
    credit_score_class,
    ROUND(
        COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END)::decimal / COUNT(*), 
        4
    ) AS approval_rate
FROM loan_app
GROUP BY credit_score_class
ORDER BY approval_rate DESC;

-- 2.How does employment status affect loan approval rates?
SELECT 
    employmentstatus,
    COUNT(*) AS total_applicants,
    COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END) AS approved,
    ROUND(
        COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END)::decimal / COUNT(*), 
        4
    ) AS approval_rate
FROM loan_app
GROUP BY employmentstatus
ORDER BY approval_rate DESC;

-- 3.What is the average loan amount approved by purpose of loan?
SELECT 
    purposeofloan,
    ROUND(AVG(loanamountrequested), 0)
FROM loan_app
GROUP BY purposeofloan
ORDER BY AVG(loanamountrequested) DESC;

-- 4.What is the approval rate across different education levels?
SELECT 
    educationlevel,
	COUNT(*) AS total_applicant,
	COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END) AS approved,
    ROUND(
        COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END)::decimal / COUNT(*), 
        4
    ) AS approval_rate
FROM loan_app
GROUP BY educationlevel
ORDER BY approval_rate DESC;

-- 5.How does the number of existing loans relate to credit score?
SELECT 
	existingloanscount,
	AVG(creditscore)
FROM loan_app
GROUP BY existingloanscount
ORDER BY AVG(creditscore) DESC;

-- 6.Is there a relationship between annual income and loan approval?
SELECT 
	MIN(annualincome),
	MAX(annualincome)
FROM loan_app; -- to identify the minimum quartile and maximum quartile for the distribution. 

WITH income_grouped AS (
  SELECT *,
    CASE 
      WHEN annualincome BETWEEN 20000 AND 64999 THEN 'lower'
      WHEN annualincome BETWEEN 65000 AND 109999 THEN 'middle'
      WHEN annualincome BETWEEN 110000 AND 154999 THEN 'high'
      WHEN annualincome BETWEEN 155000 AND 200000 THEN 'ultra'
      ELSE 'unknown'
    END AS income_range
  FROM loan_app
)
SELECT
  income_range,
  COUNT(*) AS total_applicants,
  COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END) AS approved,
  ROUND(
    COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END)::decimal / COUNT(*), 
    4
  ) AS approval_rate
FROM income_grouped
GROUP BY income_range
ORDER BY approval_rate DESC;

-- 7.What is the average number of late payments by employment status?
SELECT 
  employmentstatus,
  ROUND(AVG(latepaymentslastyear), 2) AS avg_late_payments
FROM loan_app
GROUP BY employmentstatus
ORDER BY avg_late_payments DESC;


-- 8.Which gender and marital status combinations have the highest loan approval rates?
WITH top_combine AS(SELECT 
	gender,
	maritalstatus,
	COUNT(*) AS total_applicant,
	COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END) AS loan_approved,
	ROUND(COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END)::decimal / COUNT(*), 4) AS approval_rate
FROM loan_app
GROUP BY gender, maritalstatus),
ranked AS (SELECT 
	gender,
	maritalstatus,
	RANK()OVER(PARTITION BY gender ORDER BY approval_rate) AS rank
FROM top_combine)
SELECT 
	gender,
	maritalstatus
FROM ranked
WHERE rank = 1
;

-- 9.What is the distribution of loan purposes by income group?
WITH purpose_income AS (SELECT
	CASE 
      WHEN annualincome BETWEEN 20000 AND 64999 THEN 'lower'
      WHEN annualincome BETWEEN 65000 AND 109999 THEN 'middle'
      WHEN annualincome BETWEEN 110000 AND 154999 THEN 'high'
      WHEN annualincome BETWEEN 155000 AND 200000 THEN 'ultra'
      ELSE 'unknown'
    END AS income_range,
	purposeofloan
FROM loan_app)
SELECT 
	income_range,
	purposeofloan,
	COUNT(*) AS total_applicant
FROM purpose_income
GROUP BY income_range, purposeofloan
ORDER BY income_range, total_applicant DESC;

-- 10.How does age impact credit score and loan approval?
SELECT 
  CASE 
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 45 THEN '36-45'
    WHEN age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
  END AS age_group,
  COUNT(*) AS total_applicant,
  COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END) AS loan_approved,
  ROUND(AVG(creditscore), 0) AS avg_credit_score,
  ROUND(COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END)::decimal / COUNT(*), 4) AS approval_rate
FROM loan_app
GROUP BY age_group
ORDER BY age_group;

-- 11.Which segment of customers has the highest number of late payments?
-- *employmentstatus
SELECT 
	employmentstatus,
	SUM(latepaymentslastyear) AS total_late_payments
FROM loan_app
GROUP BY employmentstatus
ORDER BY SUM(latepaymentslastyear) DESC;

-- *educationlevel
SELECT 
	educationlevel,
	SUM(latepaymentslastyear) AS total_late_payments
FROM loan_app
GROUP BY educationlevel
ORDER BY SUM(latepaymentslastyear) DESC;

-- *income_range
WITH latepay_income AS (SELECT
	CASE 
      WHEN annualincome BETWEEN 20000 AND 64999 THEN 'lower'
      WHEN annualincome BETWEEN 65000 AND 109999 THEN 'middle'
      WHEN annualincome BETWEEN 110000 AND 154999 THEN 'high'
      WHEN annualincome BETWEEN 155000 AND 200000 THEN 'ultra'
      ELSE 'unknown'
    END AS income_range,
	latepaymentslastyear
FROM loan_app)
SELECT 
	income_range,
	SUM(latepaymentslastyear) AS total_late_payments
FROM latepay_income
GROUP BY income_range
ORDER BY SUM(latepaymentslastyear) DESC;

-- *age_group
WITH late_age_group AS (SELECT 
	CASE 
    	WHEN age BETWEEN 18 AND 25 THEN '18-25'
    	WHEN age BETWEEN 26 AND 35 THEN '26-35'
    	WHEN age BETWEEN 36 AND 45 THEN '36-45'
    	WHEN age BETWEEN 46 AND 60 THEN '46-60'
    	ELSE '60+'
  	END AS age_group,
	latepaymentslastyear
FROM loan_app)
SELECT 
	age_group,
	SUM(latepaymentslastyear) AS total_late_payments
FROM late_age_group
GROUP BY age_group
ORDER BY SUM(latepaymentslastyear) DESC;
	
-- *gender + maritalstatus
SELECT 
	gender,
	maritalstatus,
	SUM(latepaymentslastyear) AS total_late_payments
FROM loan_app
GROUP BY gender, maritalstatus
ORDER BY gender, total_late_payments DESC;

-- 12.What is the average credit score and income of customers who were denied loans?
SELECT
	ROUND(AVG(creditscore), 0) AS avg_credit_score,
	ROUND(AVG(annualincome), 0) AS avg_income
FROM loan_app
WHERE loanapproved = 'No';

-- 13.Rank customers by risk based on late payments and credit score.
SELECT 
	customerid,
	app_name,
	latepaymentslastyear,
	creditscore,
	RANK()OVER(ORDER BY latepaymentslastyear DESC, creditscore) AS risk_rank,
	CASE
		WHEN latepaymentslastyear >= 5 OR creditscore < 550 THEN 'High Risk'
    	WHEN latepaymentslastyear BETWEEN 2 AND 4 OR creditscore BETWEEN 550 AND 650 THEN 'Medium Risk'
    	ELSE 'Low Risk'
  	END AS risk_level
FROM loan_app;

-- 14.What is the trend of loan approval rate by age bracket (e.g., 20s, 30s, 40s)?
SELECT 
  CASE 
    WHEN age BETWEEN 20 AND 29 THEN '20s'
    WHEN age BETWEEN 30 AND 39 THEN '30s'
    WHEN age BETWEEN 40 AND 49 THEN '40s'
    WHEN age BETWEEN 50 AND 59 THEN '50s'
    WHEN age >= 60 THEN '60+'
    ELSE 'Under 20'
  END AS age_bracket,
  COUNT(*) AS total_applicants,
  COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END) AS approved_applicants,
  ROUND(
    COUNT(CASE WHEN loanapproved = 'Yes' THEN 1 END)::decimal / COUNT(*), 
    4
  ) AS approval_rate
FROM loan_app
GROUP BY age_bracket
ORDER BY age_bracket;

-- 15.What is the average loan amount requested vs. approved (if you have both)?
SELECT 
	loanapproved,
	ROUND(AVG(loanamountrequested), 0) AS avg_loan_requested
FROM loan_app
GROUP BY loanapproved;