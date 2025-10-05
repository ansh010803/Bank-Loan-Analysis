
-- BANK LOAN ANALYSIS --
   
select * from FINANCE1 ; 
select * from FINANCE2;


-- working on some of the key metrics 
-- total loan amount 
select format(sum(coalesce(loan_Amnt,0)),'N0' ) as total_loan_amount 
from FINANCE1 ;

--Find the maximum annual income among all loan applicants 
select max(coalesce (annual_inc,-1))as maximum_annual_inc from FINANCE1;

-- Find the minimum annual income among all loan applicants if consider there is a null in it 

select min(coalesce (annual_inc,60000002)) as minimun_annual_inc from FINANCE1;

-- Calculate the average revolving balance . revolving balance is the debt 
select 
round(avg(revol_bal),0) as avg_revol_bal
from FINANCE2 ;

--total loan applications 
select distinct count(id) as total_Applicants 
from finance1;

-- Calculate the total invested funded amount for each month based on the last payment month

select 
   month ( cast ( f2.last_payment_month + ' 01,2001' as date )) AS [Month],
    sum (f1.funded_amnt_inv) AS Funded_Amount_Inv  
	from finance1 as f1
	join finance2 as f2 
	on f1.id = f2.id

	group by month ( cast ( f2.last_payment_month + ' 01,2001' as date ))
	order by [month]

-- group total loan amounts by home ownership type and order them from highest to lowest
SELECT
    home_ownership,
    CONCAT('$', FORMAT(SUM(loan_amnt), 'N0')) AS [Total_Loan_Amount]
FROM finance1
GROUP BY home_ownership
ORDER BY SUM(loan_amnt) DESC;

-- KPI 1 
-- Calculate the total loan amount for each year, with a grand total summary row.
select 
isnull(cast (year_issue_d as varchar(20)), 'grand total ') , 
    CONCAT('$', FORMAT(SUM(loan_amnt), 'N0')) AS [Total_Loan_Amount]
FROM finance1
GROUP BY year_issue_d with rollup;
-- grand total = $445,602,650
	 
--KPI 2 
--Calculate the total revolving balance for each loan grade and sub-grade.
select f1.grade as grade , 
f1.sub_grade as sub_grade ,sum(f2.revol_bal) as revolving_bal
from finance1 as f1 
join FINANCE2 as f2 
on f1.id = f2.id 
GROUP BY f1.grade, f1.sub_grade
ORDER BY f1.grade, f1.sub_grade;

-- KPI 3: Compare total payments from 'Verified' vs. 'Not Verified' applicants.
SELECT
    verification_status,
    CONCAT('$', FORMAT(SUM(f2.total_pymnt), 'N0')) AS [Total_Payment]
FROM finance1 AS f1
JOIN finance2 AS f2 ON f1.id = f2.id
WHERE verification_status IN ('Verified', 'Not Verified')
GROUP BY verification_status;

-- KPI 4: List the state, issue month, and status for each loan.

SELECT
    addr_state AS [State],
    month_issue_d_1 AS [Month],
    loan_status AS [Loan_Status]
FROM finance1;

-- KPI 5: Calculate the sum of the last payment amount for each home ownership category.
SELECT
    f1.home_ownership,
    CONCAT('$', FORMAT(SUM(f2.last_pymnt_amnt), 'N0')) AS [Last_Payment_Amount]
FROM finance2 AS f2
JOIN finance1 AS f1 ON f1.id = f2.id
GROUP BY f1.home_ownership
ORDER BY SUM(f2.last_pymnt_amnt) DESC;


-- Risk & Credit Analysis KPIs
--Default Rate by Loan Grade: 
-- high default rate means high risk 
   SELECT
    grade,
    sub_grade,
    total_loans,
    defaulted_loans,
    -- Calculate the final default rate in the outer query
   concat ((round ( ( (CAST(defaulted_loans AS FLOAT) / total_loans) * 100) ,2 ) ) , '%') AS default_rate_percentage
FROM
    (
        -- Subquery: This part runs first to count total and defaulted loans for each group
        SELECT
            grade,
            sub_grade,
            COUNT(id) AS total_loans,
            SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS defaulted_loans
        FROM
            finance1
        GROUP BY
            grade,
            sub_grade
    ) AS LoanCounts -- The subquery is given an alias 'LoanCounts'
ORDER BY
    default_rate_percentage DESC;
				

-- Calculate default rate for each loan purpose and compare to the overall average and rank accordingly 
select purpose , total_Loans , defaulted_loans,purpose_default_rate,overall_average_default_rate , (purpose_default_rate - overall_average_default_rate ) as diff ,
rank() over( order by (purpose_default_rate - overall_average_default_rate ) ) as rank_of_pupose_default_rate
from (
        SELECT
            purpose,
            COUNT(id) AS total_loans,
            SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS defaulted_loans,
            -- This is the default rate for each specific purpose
           round( ((CAST(SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(id)) * 100) , 2 ) AS purpose_default_rate,
            -- This scalar subquery calculates the overall average default rate for the entire table
            (
                SELECT round( ((CAST(SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(id)) * 100) , 2 ) 
                FROM finance1
            ) AS overall_average_default_rate
        FROM
            finance1
            GROUP BY
                purpose
           
    ) AS t;


 --Business Question: How predictive is a borrower's past payment behavior on their future loan performance?

--It demonstrates your ability to perform behavioral analysis and use historical data to predict future risk. This is more sophisticated than just looking at static attributes like income.
SELECT
    delinquency_group,
    COUNT(*) AS number_of_loans,
    (CAST(SUM(CASE WHEN f1.loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS default_rate_percentage
FROM
    finance1 AS f1
JOIN
    (
        SELECT
            id,
            CASE
                WHEN delinq_2yrs = 0 THEN '0 Delinquencies'
                WHEN delinq_2yrs = 1 THEN '1 Delinquency'
                ELSE '2+ Delinquencies'
            END AS delinquency_group
        FROM
            finance2
    ) AS f2 ON f1.id = f2.id
GROUP BY
    delinquency_group
ORDER BY
    delinquency_group;
