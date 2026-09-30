use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

select s.SPLIT, count(*) as n_customers,
       avg(case when l.CHURNED_WITHIN_90_DAYS then 1.0 else 0.0 end) as churn_rate
from RETENTION_COPILOT.ANALYTICS.CHURN_SPLIT s
join RETENTION_COPILOT.ANALYTICS.CHURN_LABELS l on s.CUSTOMER_ID = l.CUSTOMER_ID
group by s.SPLIT
order by s.SPLIT;

select MODEL_NAME, SPLIT_NAME, METRIC_NAME, round(METRIC_VALUE, 4) as METRIC_VALUE
from RETENTION_COPILOT.ANALYTICS.CHURN_MODEL_RESULTS
where METRIC_NAME not like 'importance_%'
order by MODEL_NAME, SPLIT_NAME, METRIC_NAME;

select MODEL_NAME, METRIC_NAME, round(METRIC_VALUE, 4) as METRIC_VALUE
from RETENTION_COPILOT.ANALYTICS.CHURN_MODEL_RESULTS
where METRIC_NAME like 'importance_%'
order by METRIC_VALUE desc
limit 10;

select count(*) as total_scored
from RETENTION_COPILOT.ANALYTICS.CHURN_SCORES;

select RISK_TIER, count(*) as n_customers
from RETENTION_COPILOT.ANALYTICS.CHURN_SCORES
group by RISK_TIER
order by RISK_TIER;

select cs.RISK_TIER,
       count(*) as n_test_customers,
       round(avg(case when cl.CHURNED_WITHIN_90_DAYS then 1.0 else 0.0 end), 4) as actual_churn_rate
from RETENTION_COPILOT.ANALYTICS.CHURN_SCORES cs
join RETENTION_COPILOT.ANALYTICS.CHURN_LABELS cl on cs.CUSTOMER_ID = cl.CUSTOMER_ID
where cs.IS_TEST_CUSTOMER = true
group by cs.RISK_TIER
order by actual_churn_rate desc;

select cs.RISK_TIER,
       count(*) as n_test_customers,
       round(avg(cs.CHURN_PROBABILITY), 4) as avg_predicted_probability,
       round(avg(case when cl.CHURNED_WITHIN_90_DAYS then 1.0 else 0.0 end), 4) as actual_churn_rate
from RETENTION_COPILOT.ANALYTICS.CHURN_SCORES cs
join RETENTION_COPILOT.ANALYTICS.CHURN_LABELS cl on cs.CUSTOMER_ID = cl.CUSTOMER_ID
where cs.IS_TEST_CUSTOMER = true
group by cs.RISK_TIER
order by actual_churn_rate desc;

select round(avg(cs.CHURN_PROBABILITY), 4) as overall_avg_predicted_probability,
       round(avg(case when cl.CHURNED_WITHIN_90_DAYS then 1.0 else 0.0 end), 4) as overall_actual_churn_rate
from RETENTION_COPILOT.ANALYTICS.CHURN_SCORES cs
join RETENTION_COPILOT.ANALYTICS.CHURN_LABELS cl on cs.CUSTOMER_ID = cl.CUSTOMER_ID
where cs.IS_TEST_CUSTOMER = true;

select round(min(CHURN_PROBABILITY), 4) as min_prob,
       round(avg(CHURN_PROBABILITY), 4) as avg_prob,
       round(max(CHURN_PROBABILITY), 4) as max_prob
from RETENTION_COPILOT.ANALYTICS.CHURN_SCORES;

select CUSTOMER_ID, round(CHURN_PROBABILITY, 4) as CHURN_PROBABILITY,
       RISK_TIER, TOP_DRIVER_1, TOP_DRIVER_2, TOP_DRIVER_3
from RETENTION_COPILOT.ANALYTICS.CHURN_SCORES
order by CHURN_PROBABILITY desc
limit 5;
