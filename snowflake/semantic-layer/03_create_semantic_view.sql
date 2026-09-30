create or replace semantic view RETENTION_COPILOT.APP.CHURN_SEMANTIC_VIEW
  tables (
    CUSTOMER_OVERVIEW as RETENTION_COPILOT.APP.CUSTOMER_OVERVIEW
      primary key (CUSTOMER_ID)
      with synonyms = ('customers', 'policyholder overview', 'customer data', 'churn candidates')
      comment = 'One row per active customer as of 2026-06-30. Combines customer profile, modelled churn score and the highest-priority recommended retention action.',
    CALL_OVERVIEW as RETENTION_COPILOT.APP.CALL_OVERVIEW
      with synonyms = ('calls', 'customer calls', 'call records', 'service calls')
      comment = 'One row per inbound customer service call with AI-extracted sentiment score, main topic, competitor mentions and cancellation intent.'
  )
  relationships (
    CALL_OVERVIEW(CUSTOMER_ID) references CUSTOMER_OVERVIEW(CUSTOMER_ID)
  )
  facts (
    CUSTOMER_OVERVIEW.CHURN_PROBABILITY as CUSTOMER_OVERVIEW.CHURN_PROBABILITY
      with synonyms = ('churn score', 'cancellation probability', 'churn risk score', 'probability of churn')
      comment = 'Modelled probability that this customer cancels all active policies within 90 days of 2026-06-30. Ranges from 0 (no risk) to 1 (certain churn).',
    CUSTOMER_OVERVIEW.REVENUE_AT_RISK as CUSTOMER_OVERVIEW.REVENUE_AT_RISK
      with synonyms = ('customer at-risk revenue', 'customer revenue exposure')
      comment = 'Expected annual premium loss for this customer: churn probability multiplied by twelve times the monthly premium, in rupees. Populated only for Medium and High risk customers.',
    CALL_OVERVIEW.SENTIMENT_SCORE as CALL_OVERVIEW.SENTIMENT_SCORE
      with synonyms = ('call sentiment', 'sentiment', 'call score')
      comment = 'AI-scored sentiment for an individual call. Higher values indicate a more positive interaction.'
  )
  dimensions (
    CUSTOMER_OVERVIEW.CUSTOMER_ID as CUSTOMER_OVERVIEW.CUSTOMER_ID
      with synonyms = ('customer id', 'policyholder id', 'client id', 'customer number')
      comment = 'Unique customer identifier, for example C000001.',
    CUSTOMER_OVERVIEW.FIRST_NAME as CUSTOMER_OVERVIEW.FIRST_NAME
      with synonyms = ('name', 'given name', 'customer name', 'first name')
      comment = 'Customer given name.',
    CUSTOMER_OVERVIEW.CITY as CUSTOMER_OVERVIEW.CITY
      with synonyms = ('customer city', 'location', 'town')
      comment = 'City of customer residence.',
    CUSTOMER_OVERVIEW.STATE as CUSTOMER_OVERVIEW.STATE
      with synonyms = ('customer state', 'region', 'province')
      comment = 'State of customer residence within India.',
    CUSTOMER_OVERVIEW.SEGMENT as CUSTOMER_OVERVIEW.SEGMENT
      with synonyms = ('customer segment', 'tier', 'customer tier', 'value band')
      comment = 'Customer value tier based on premium and tenure: Standard, Silver or Gold.',
    CUSTOMER_OVERVIEW.PRODUCTS_HELD as CUSTOMER_OVERVIEW.PRODUCTS_HELD
      with synonyms = ('products', 'insurance products', 'policy types', 'product mix')
      comment = 'Comma-separated list of insurance product types held by the customer, such as Motor, Health, Life, Home or Travel.',
    CUSTOMER_OVERVIEW.RISK_TIER as CUSTOMER_OVERVIEW.RISK_TIER
      with synonyms = ('churn risk', 'risk level', 'risk category', 'churn tier')
      comment = 'Modelled churn risk category: Low, Medium or High.',
    CUSTOMER_OVERVIEW.ACTION_TYPE as CUSTOMER_OVERVIEW.ACTION_TYPE
      with synonyms = ('recommended action', 'retention action', 'intervention type', 'action')
      comment = 'Type of recommended retention action for this customer, such as Discount Offer or Agent Outreach.',
    CUSTOMER_OVERVIEW.ACTION_STATUS as CUSTOMER_OVERVIEW.ACTION_STATUS
      with synonyms = ('action progress', 'intervention status', 'outreach status')
      comment = 'Current status of the recommended retention action: Pending, Sent or Resolved.',
    CUSTOMER_OVERVIEW.ACTION_CONFIDENCE as CUSTOMER_OVERVIEW.ACTION_CONFIDENCE
      with synonyms = ('recommendation confidence', 'action confidence level', 'confidence')
      comment = 'Confidence level of the recommended action: Low, Medium or High.',
    CALL_OVERVIEW.MAIN_TOPIC as CALL_OVERVIEW.MAIN_TOPIC
      with synonyms = ('call topic', 'call reason', 'topic', 'call subject')
      comment = 'Primary topic of the customer service call, such as Claim, Renewal, Complaint or Cancellation.',
    CALL_OVERVIEW.COMPETITOR_MENTIONED as CALL_OVERVIEW.COMPETITOR_MENTIONED
      with synonyms = ('rival insurer', 'competitor', 'other insurer', 'rival mentioned')
      comment = 'Name of the competing insurer mentioned during the call. NULL when no competitor was referenced.',
    CALL_OVERVIEW.CALL_AT as CALL_OVERVIEW.CALL_AT
      with synonyms = ('call date', 'call time', 'call datetime', 'date of call')
      comment = 'Date and time when the customer service call took place.',
    CALL_OVERVIEW.COMPLAINT_REASON as CALL_OVERVIEW.COMPLAINT_REASON
      with synonyms = ('complaint', 'reason for complaint', 'complaint detail', 'grievance reason')
      comment = 'Reason given by the customer for their complaint or request to cancel.'
  )
  metrics (
    CUSTOMER_OVERVIEW.CUSTOMER_COUNT as count(distinct CUSTOMER_OVERVIEW.CUSTOMER_ID)
      with synonyms = ('number of customers', 'total customers', 'headcount', 'customer headcount')
      comment = 'Total number of distinct active customers in the selection.',
    CUSTOMER_OVERVIEW.HIGH_RISK_CUSTOMER_COUNT as count_if(CUSTOMER_OVERVIEW.RISK_TIER = 'High')
      with synonyms = ('high risk customers', 'high churn customers', 'number of high risk customers')
      comment = 'Number of customers assigned the High churn risk tier.',
    CUSTOMER_OVERVIEW.AVERAGE_CHURN_PROBABILITY as avg(CUSTOMER_OVERVIEW.CHURN_PROBABILITY)
      with synonyms = ('mean churn probability', 'average churn score', 'avg churn risk', 'mean churn risk')
      comment = 'Mean modelled probability of churning within 90 days of 2026-06-30, ranging from 0 to 1.',
    CUSTOMER_OVERVIEW.TOTAL_REVENUE_AT_RISK as sum(CUSTOMER_OVERVIEW.REVENUE_AT_RISK)
      with synonyms = ('revenue at risk', 'total at-risk revenue', 'premium at risk', 'total premium exposure')
      comment = 'Sum of expected annual premium loss, in rupees, across the Medium and High risk customers in the selection.',
    CUSTOMER_OVERVIEW.TOTAL_MONTHLY_PREMIUM as sum(CUSTOMER_OVERVIEW.TOTAL_MONTHLY_PREMIUM)
      with synonyms = ('total premium', 'total monthly premium', 'premium volume', 'sum of premiums')
      comment = 'Total monthly premium income across all customers in the selection.',
    CUSTOMER_OVERVIEW.LATE_PAYMENTS as sum(CUSTOMER_OVERVIEW.LATE_PAYMENTS)
      with synonyms = ('total late payments', 'number of late payments', 'late payment count', 'overdue payments')
      comment = 'Total number of late payment events recorded across all customers in the selection.',
    CUSTOMER_OVERVIEW.FAILED_PAYMENTS as sum(CUSTOMER_OVERVIEW.FAILED_PAYMENTS)
      with synonyms = ('total failed payments', 'payment failures', 'number of failed payments', 'missed payments')
      comment = 'Total number of payment failures recorded across all customers in the selection.',
    CUSTOMER_OVERVIEW.OPEN_TICKETS as sum(CUSTOMER_OVERVIEW.OPEN_TICKETS)
      with synonyms = ('total open tickets', 'unresolved tickets', 'pending service tickets', 'open service requests')
      comment = 'Total number of unresolved service tickets across all customers in the selection.',
    CUSTOMER_OVERVIEW.AVERAGE_SATISFACTION as avg(CUSTOMER_OVERVIEW.AVERAGE_SATISFACTION)
      with synonyms = ('satisfaction score', 'average csat', 'mean satisfaction', 'customer satisfaction')
      comment = 'Mean satisfaction score from service ticket ratings across customers in the selection, on a scale of 1 to 5.',
    CALL_OVERVIEW.AVERAGE_SENTIMENT as avg(CALL_OVERVIEW.SENTIMENT_SCORE)
      with synonyms = ('mean sentiment', 'average call sentiment', 'mean call score', 'sentiment score')
      comment = 'Mean AI-scored sentiment across all calls in the selection. Higher values indicate more positive interactions.',
    CALL_OVERVIEW.NUMBER_OF_CALLS as count(CALL_OVERVIEW.TRANSCRIPT_ID)
      with synonyms = ('call count', 'total calls', 'calls', 'number of service calls')
      comment = 'Total number of customer service calls in the selection.',
    CALL_OVERVIEW.CALLS_MENTIONING_RIVAL as count_if(CALL_OVERVIEW.COMPETITOR_MENTIONED is not null)
      with synonyms = ('rival mentions', 'competitor mentions', 'calls with rival mention', 'calls mentioning competitor')
      comment = 'Number of calls in which a competing insurer was mentioned by name.',
    CALL_OVERVIEW.CALLS_WITH_CANCELLATION_INTENT as count_if(CALL_OVERVIEW.WANTS_TO_CANCEL)
      with synonyms = ('cancellation intent calls', 'cancel calls', 'calls wanting to cancel', 'churn calls')
      comment = 'Number of calls in which the customer indicated they wanted to cancel their policy.'
  )
  comment = 'Synthetic data for Suraksha General Insurance retention analytics. All customer records, policies, payments, claims, service tickets and call transcripts are generated data and do not represent real individuals or events. Churn probability is the modelled chance of a customer cancelling all active policies within 90 days of the cutoff date 2026-06-30.'
  ai_sql_generation 'Use CUSTOMER_OVERVIEW for customer-level analysis and CALL_OVERVIEW for call-level analysis. Join them via CUSTOMER_ID. CHURN_PROBABILITY ranges from 0 to 1. RISK_TIER values are Low, Medium and High. SEGMENT values are Standard, Silver and Gold. REVENUE_AT_RISK and ACTION columns are NULL for Low risk customers. COMPETITOR_MENTIONED is NULL when no rival insurer was named.'
  ai_verified_queries (
    CUSTOMERS_BY_RISK_TIER as (
      question 'How many customers are in each churn risk tier?'
      sql 'select * from semantic_view(RETENTION_COPILOT.APP.CHURN_SEMANTIC_VIEW metrics (CUSTOMER_OVERVIEW.CUSTOMER_COUNT) dimensions (CUSTOMER_OVERVIEW.RISK_TIER))'
    ),
    REVENUE_AT_RISK_BY_ACTION_TYPE as (
      question 'What is the total revenue at risk broken down by recommended action type?'
      sql 'select * from semantic_view(RETENTION_COPILOT.APP.CHURN_SEMANTIC_VIEW metrics (CUSTOMER_OVERVIEW.TOTAL_REVENUE_AT_RISK) dimensions (CUSTOMER_OVERVIEW.ACTION_TYPE))'
    ),
    RIVAL_CALLS_BY_INSURER as (
      question 'How many calls mention a rival insurer, grouped by insurer name?'
      sql 'select * from semantic_view(RETENTION_COPILOT.APP.CHURN_SEMANTIC_VIEW metrics (CALL_OVERVIEW.CALLS_MENTIONING_RIVAL) dimensions (CALL_OVERVIEW.COMPETITOR_MENTIONED))'
    )
  )
