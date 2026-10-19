create database debit_credit_analysis;
use debit_credit_analysis;

select * from debit_credit_analysis.transaction_analysis;
use debit_credit_analysis;
select * from transaction_analysis;

-- Net Transaction Amount
select abs(sum(case when `transaction type` = 'credit' then amount else 0 end) -
sum(case when `transaction type` = 'debit' then amount else 0 end)) 
as net_transaction_amount
from transaction_analysis;

-- Total Credit Amount
select sum(amount) as total_credited_amount
from transaction_analysis
where `transaction type` = 'credit';

-- Total Debit Amount
select sum(amount) as total_debited_amount
from transaction_analysis
where `transaction type` = 'debit';

-- Credit to Debit Ratio
select sum(case when `transaction type` = 'credit' then amount else 0 end) /
nullif(sum(case when `transaction type` = 'debit' then amount else 0 end),0) 
as credit_debit_ratio
from transaction_analysis;

-- Account Activity Ratio
select concat((count(`Customer ID`)/ sum(`Balance`))*100,"%")
as account_activity_ratio
from transaction_analysis;


-- Transaction Per Day/Week/Month
-- Transaction Per Day
select date(`Transaction Date`) as transaction_day, 
count(*) as total_tansactions
from transaction_analysis
group by date(`Transaction Date`)
order by transaction_day;

-- Transaction Per Week
select yearweek(`Transaction Date`,3) as transaction_week, 
count(*) as total_transactions
from transaction_analysis
group by yearweek(`Transaction Date`,3)
order by transaction_week;

-- Transaction Per Month
select monthname(`Transaction Date`) as transaction_month,
count(*) as total_transactions
from transaction_analysis
group by monthname(`Transaction Date`)
order by transaction_month;

-- Total Transaction Amount By Branch
select branch , sum(amount) as total_transaction_amount
from transaction_analysis
group by branch;

-- Transaction Volume By Branch
select branch , count(amount) as transaction_volume
from transaction_analysis
group by branch;


-- 9.Transaction Method Distribution
select 
    `transaction method`,
    count(*) as transaction_count,
    round(count(*) * 100.0 / (select count(*) from transaction_analysis), 2) as percentage_share
from transaction_analysis
group by `transaction method`
order by transaction_count desc;



-- 10-Branch Transaction Growth:
with monthlybranchtotals as (
    select 
        branch,
        date_format(`transaction date`, '%y-%m') as month,
        sum(amount) as total_amount
    from transaction_analysis
    group by branch, date_format(`transaction date`, '%y-%m')
),
branchgrowthcalc as (
    select 
        branch,
        month,
        total_amount,
        lag(total_amount) over (partition by branch order by month) as prev_month_amount
    from monthlybranchtotals
)
select 
    branch,
    month,
    total_amount,
    round((total_amount - prev_month_amount) * 100.0 / nullif(prev_month_amount, 0), 2) as mom_growth_percentage
from branchgrowthcalc
order by branch, month;




-- 11-High-Risk Transaction Flag:
select 
    `customer id`,
    `customer name`,
    `account number`,
    `transaction date`,
    branch,
    amount,
    case 
        when amount > 4762.85 then 'high-risk'
        else 'normal'
    end as risk_flag
from transaction_analysis
where amount > 4762.85
order by amount desc;




-- 12-Suspicious Transaction Frequency:
select 
    date_format(`transaction date`, '%Y-%m') as monthly_period,
    count(*) as suspicious_transaction_count
from transaction_analysis
where amount > 4762.85
group by date_format(`transaction date`, '%Y-%m')
order by monthly_period asc;




