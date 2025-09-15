
-- BANK LOAN ANALYSIS --
   
SELECT * FROM FINANCE1;
SELECT * FROM FINANCE2;

-- TOTAL LOAN AMOUNT
select concat('$',format(sum(loan_amnt),-2)) as TOTAL_LOAN_AMOUNT from finance1;

-- MINIMUM ANNAUL INCOME
SELECT min(ANNUAL_INC) AS 'MINIMUM ANNAUL INCOME' FROM finance1;

-- MAXIMUM ANNAUL INCOME
SELECT concat('$',FORMAT( max(ANNUAL_INC),-2)) AS 'MAXIMUM ANNAUL INCOME' FROM FINANCE1;

-- AVERAGE REVOL BALANCE
SELECT ROUND(AVG(REVOL_BAL)) AS 'AVERAGE REVOL BALANCE'  FROM finance2;


-- TOTAL LOAN APPLICATIONS
select count(id) as TOTAL_LOAN FROM FINANCE1;

-- MONTH WISE FUNDED AMOUNT INV
SELECT last_payment_month AS 'MONTH',SUM(funded_amnt_inv) AS 'FUNDED AMOUNT INV'
FROM finance1 
JOIN finance2 ON finance1.id = finance2.id 
group by finance2.last_payment_month
order by 'MONTH' DESC;


-- HOME OWNERSHIP BY LOAN AMOUNT 
SELECT  HOME_OWNERSHIP, concat('$',FORMAT(sum(loan_amnt),-2)) as TOTAL_LOAN_AMOUNT
FROM FINANCE1
GROUP BY HOME_OWNERSHIP 
ORDER BY TOTAL_LOAN_AMOUNT desc;

-- LOAN STATUS BY LOAN AMOUNT
SELECT LOAN_STATUS, concat('$',FORMAT(SUM(LOAN_AMNT),-2)) AS TOTAL_LOAN_AMOUNT
FROM FINANCE1
GROUP BY LOAN_STATUS
ORDER BY TOTAL_LOAN_AMOUNT;

-- YEAR WISE TOTAL LOAN AMOUNT/MIN LOAN/MAX LOAN/ AVERAGE LOAN
SELECT year_issue_d ,
	COUNT(*) AS TOTAL_LOAN,
	concat('$', MIN(LOAN_AMNT)) AS MIN_LOAN_AMOUNT,
    concat('$',MAX(LOAN_AMNT)) AS MAX_LOAN_AMNT,
    concat('$',round(AVG(LOAN_AMNT))) AS AVG_LOAN_AMT
    FROM FINANCE1
    GROUP BY year_issue_d
    ORDER BY year_issue_d;
	

-- KPI 1 YEAR WISE LOAN AMOUNT STATS
SELECT 
  CASE WHEN year_issue_d IS NULL THEN 'TOTAL' ELSE year_issue_d END AS year_issue_d, 
  CONCAT('$ ', FORMAT(SUM(loan_amnt), -2)) AS Total_Loan_amnt 
FROM finance1 
GROUP BY year_issue_d 
WITH ROLLUP;

-- KPI 2 GRADE AND SUB GRADE WISE REVOL_BAL
SELECT FINANCE1.grade, finance1.sub_grade,
concat('$', format(sum(finance2.revol_bal),-2)) as Total_revol_bal
FROM FINANCE1
join FINANCE2 ON FINANCE1.id = FINANCE2.id
group by finance1.GRADE, finance1.SUB_GRADE 
ORDER BY FINANCE1.GRADE ASC;

-- KPI 3 TOTAL PAYMENT FOR VERIFIED STATUS vs TOTAL PAYMENT FOR NON VERIFIED STATUS
SELECT * FROM bank_analysis.finance1;
select verification_status, 
concat('$',format(sum(total_pymnt),-2)) as Total_payment
from finance1 join finance2
on(finance1.id= finance2.id) 
where verification_status in('Verified', 'Not Verified')
group by verification_status;

-- KPI 4 state wise and month wise loan status
select * from  finance1;
select * from  finance2;
select addr_state as STATES, month_issue_d_1 AS MONTHS, loan_status AS LOAN_STATUS
from finance1;

-- KPI 5 HOME OWENERSHIP vs LAST PAYMENT DATE STATS
select home_ownership, concat('$',FORMAT( sum(last_pymnt_amnt),-2)) as 'LAST PAYMENT AMOUNT'  
 from finance2
 JOIN finance1 ON finance1.id = finance2.id
 group by home_ownership
 order by 'LAST PAYMENT AMOUNT' desc;

