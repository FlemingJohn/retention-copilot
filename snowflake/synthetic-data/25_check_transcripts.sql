use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

select 'transcript_count' as CHECK_NAME, count(*)::varchar as VALUE
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS

union all

select 'avg_word_count', round(avg(array_size(split(TRANSCRIPT_TEXT, ' '))))::varchar
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS

union all

select 'min_word_count', min(array_size(split(TRANSCRIPT_TEXT, ' ')))::varchar
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS

union all

select 'max_word_count', max(array_size(split(TRANSCRIPT_TEXT, ' ')))::varchar
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS

union all

select 'total_prompt_tokens', sum(PROMPT_TOKENS)::varchar
from RETENTION_COPILOT.GENERATOR.TRANSCRIPT_USAGE

union all

select 'total_completion_tokens', sum(COMPLETION_TOKENS)::varchar
from RETENTION_COPILOT.GENERATOR.TRANSCRIPT_USAGE

union all

select 'total_tokens', sum(TOTAL_TOKENS)::varchar
from RETENTION_COPILOT.GENERATOR.TRANSCRIPT_USAGE

union all

select 'avg_tokens_per_transcript', round(avg(TOTAL_TOKENS))::varchar
from RETENTION_COPILOT.GENERATOR.TRANSCRIPT_USAGE

union all

select 'model_used', max(MODEL)
from RETENTION_COPILOT.GENERATOR.TRANSCRIPT_USAGE

union all

select 'mood_low_count', count(*)::varchar
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS t
join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on m.CUSTOMER_ID = t.CUSTOMER_ID
where m.MOOD < 0.33

union all

select 'mood_mid_count', count(*)::varchar
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS t
join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on m.CUSTOMER_ID = t.CUSTOMER_ID
where m.MOOD >= 0.33 and m.MOOD < 0.66

union all

select 'mood_high_count', count(*)::varchar
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS t
join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on m.CUSTOMER_ID = t.CUSTOMER_ID
where m.MOOD >= 0.66

union all

select 'mentions_suraksha', count(*)::varchar
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS
where TRANSCRIPT_TEXT ilike '%Suraksha General Insurance%'

union all

select 'mentions_rival', count(*)::varchar
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS
where regexp_count(TRANSCRIPT_TEXT, '\\bLIC\\b|HDFC Life|ICICI Lombard|Star Health|Bajaj Allianz|Tata AIG|SBI Life') > 0

union all

select 'forbidden_words', count(*)::varchar
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS
where TRANSCRIPT_TEXT ilike '%churn%'
   or TRANSCRIPT_TEXT ilike '%mood%'
   or TRANSCRIPT_TEXT ilike '%score%'

union all

select 'mentions_paise', count(*)::varchar
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS
where TRANSCRIPT_TEXT ilike '%paise%';

select TOPIC, count(*) as CNT
from RETENTION_COPILOT.GENERATOR.CALL_PLAN cp
join RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS t
    on t.TRANSCRIPT_ID = 'CALL' || lpad(cp.PLAN_ID::varchar, 6, '0')
group by TOPIC
order by CNT desc;

select STYLE, count(*) as CNT
from RETENTION_COPILOT.GENERATOR.CALL_PLAN cp
join RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS t
    on t.TRANSCRIPT_ID = 'CALL' || lpad(cp.PLAN_ID::varchar, 6, '0')
group by STYLE
order by CNT desc;

select t.TRANSCRIPT_ID, m.MOOD, t.TRANSCRIPT_TEXT
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS t
join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on m.CUSTOMER_ID = t.CUSTOMER_ID
where m.MOOD < 0.33
order by t.TRANSCRIPT_ID
limit 1;

select t.TRANSCRIPT_ID, m.MOOD, t.TRANSCRIPT_TEXT
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS t
join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on m.CUSTOMER_ID = t.CUSTOMER_ID
where m.MOOD >= 0.33 and m.MOOD < 0.66
order by t.TRANSCRIPT_ID
limit 1;

select t.TRANSCRIPT_ID, m.MOOD, t.TRANSCRIPT_TEXT
from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS t
join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on m.CUSTOMER_ID = t.CUSTOMER_ID
where m.MOOD >= 0.66
order by t.TRANSCRIPT_ID
limit 1;
