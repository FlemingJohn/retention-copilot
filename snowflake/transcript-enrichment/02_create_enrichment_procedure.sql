use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace procedure RETENTION_COPILOT.ANALYTICS.ENRICH_CALLS(FIRST_NUMBER number, LAST_NUMBER number)
returns varchar
language sql
as
$$
begin
    create or replace temporary table RETENTION_COPILOT.ANALYTICS.CALL_READINGS as
    select
        TRANSCRIPT_ID,
        CUSTOMER_ID,
        CALL_AT,
        snowflake.cortex.sentiment(TRANSCRIPT_TEXT) as SENTIMENT_SCORE,
        ai_classify(TRANSCRIPT_TEXT, ['premium or price complaint', 'claim delay or rejection', 'billing or payment problem', 'policy change request', 'general enquiry', 'praise or thanks', 'cancellation request']):labels[0]::varchar as MAIN_TOPIC,
        ai_extract(TRANSCRIPT_TEXT, ['competitor insurer mentioned', 'complaint reason', 'customer intends to cancel yes or no']):response as EXTRACTED
    from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS
    where regexp_substr(TRANSCRIPT_ID, '[0-9]+')::number between :FIRST_NUMBER and :LAST_NUMBER
      and TRANSCRIPT_ID not in (select TRANSCRIPT_ID from RETENTION_COPILOT.ANALYTICS.CALL_INSIGHTS);

    insert into RETENTION_COPILOT.ANALYTICS.CALL_INSIGHTS
        (TRANSCRIPT_ID, CUSTOMER_ID, CALL_AT, SENTIMENT_SCORE, MAIN_TOPIC, COMPETITOR_MENTIONED, COMPLAINT_REASON, WANTS_TO_CANCEL)
    select
        TRANSCRIPT_ID,
        CUSTOMER_ID,
        CALL_AT,
        SENTIMENT_SCORE,
        MAIN_TOPIC,
        regexp_substr(EXTRACTED:"competitor insurer mentioned"::varchar, '(\\bLIC\\b|HDFC Life|ICICI Lombard|Star Health|Bajaj Allianz|Tata AIG|SBI Life)'),
        case
            when lower(EXTRACTED:"complaint reason"::varchar) in ('none', 'n/a', 'null', 'not mentioned', '') then null
            else left(EXTRACTED:"complaint reason"::varchar, 300)
        end,
        case
            when lower(EXTRACTED:"customer intends to cancel yes or no"::varchar) like 'yes%' then true
            when lower(EXTRACTED:"customer intends to cancel yes or no"::varchar) like 'no%' then false
            else null
        end
    from RETENTION_COPILOT.ANALYTICS.CALL_READINGS;

    return 'inserted ' || SQLROWCOUNT::varchar || ' rows';
end;
$$;
