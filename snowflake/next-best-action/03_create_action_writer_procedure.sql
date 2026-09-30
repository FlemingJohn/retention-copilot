create or replace procedure RETENTION_COPILOT.ANALYTICS.WRITE_ACTIONS(LIMIT_ROWS number)
returns varchar
language sql
as
$$
declare
    model_count    number default 0;
    template_count number default 0;
begin
    truncate table RETENTION_COPILOT.ANALYTICS.RECOMMENDED_ACTIONS;

    create or replace temporary table TEMP_DRAFTS as
    select
        c.CUSTOMER_ID,
        c.FIRST_NAME,
        c.CITY,
        c.ACTION_TYPE,
        c.CHANNEL,
        c.REASON,
        c.CONFIDENCE,
        c.STATUS,
        c.PRIORITY_RANK,
        c.REVENUE_AT_RISK,
        snowflake.cortex.complete(
            'claude-haiku-4-5',
            array_construct(
                object_construct(
                    'role', 'user',
                    'content',
                    'Write a short warm outreach message in plain English from a retention manager at Suraksha General Insurance to a customer named '
                    || c.FIRST_NAME
                    || ' based in '
                    || c.CITY
                    || '. Purpose of outreach: '
                    || c.ACTION_TYPE
                    || '. Customer service signals: '
                    || coalesce(nullif(array_to_string(array_compact(array_construct(
                            nullif(c.TOP_DRIVER_1, ''), nullif(c.TOP_DRIVER_2, ''), nullif(c.TOP_DRIVER_3, '')
                        )), '; '), ''), 'general service review')
                    || '. Requirements: keep under 90 words; no subject line; no markdown; do not mention scores, probabilities, churn, models, AI or data analysis; do not promise a specific discount, amount or outcome; only offer to review options, schedule a call, discuss a payment plan or follow up as appropriate to the purpose; do not mention any competitor by name; sign off as: Suraksha General Insurance retention team.'
                )
            ),
            object_construct('max_tokens', 300)
        ) as RAW_RESPONSE,
        c.TOP_DRIVER_1,
        c.TOP_DRIVER_2,
        c.TOP_DRIVER_3
    from RETENTION_COPILOT.ANALYTICS.ACTION_CANDIDATES c
    where (:LIMIT_ROWS = 0 or c.PRIORITY_RANK <= :LIMIT_ROWS);

    insert into RETENTION_COPILOT.ANALYTICS.RECOMMENDED_ACTIONS (
        ACTION_ID,
        CUSTOMER_ID,
        ACTION_TYPE,
        CHANNEL,
        REASON,
        CONFIDENCE,
        STATUS,
        PRIORITY_RANK,
        REVENUE_AT_RISK,
        DRAFT_MESSAGE,
        DRAFT_SOURCE,
        CREATED_AT
    )
    with extracted as (
        select
            t.CUSTOMER_ID,
            t.FIRST_NAME,
            t.ACTION_TYPE,
            t.CHANNEL,
            t.REASON,
            t.CONFIDENCE,
            t.STATUS,
            t.PRIORITY_RANK,
            t.REVENUE_AT_RISK,
            t.RAW_RESPONSE:choices[0]:messages::varchar as EXTRACTED_TEXT
        from TEMP_DRAFTS t
    ),
    guarded as (
        select
            e.CUSTOMER_ID,
            e.FIRST_NAME,
            e.ACTION_TYPE,
            e.CHANNEL,
            e.REASON,
            e.CONFIDENCE,
            e.STATUS,
            e.PRIORITY_RANK,
            e.REVENUE_AT_RISK,
            case
                when e.EXTRACTED_TEXT is null
                  or trim(e.EXTRACTED_TEXT) = ''
                  or length(e.EXTRACTED_TEXT) > 900
                  or regexp_like(e.EXTRACTED_TEXT, '.*(\\bchurn\\b|\\bscore\\b|\\bprobability\\b|\\brisk\\b|\\balgorithm\\b|\\bmodel\\b|\\bai\\b).*', 'i')
                then 'template'
                else 'model'
            end as DRAFT_SOURCE,
            case
                when e.EXTRACTED_TEXT is null
                  or trim(e.EXTRACTED_TEXT) = ''
                  or length(e.EXTRACTED_TEXT) > 900
                  or regexp_like(e.EXTRACTED_TEXT, '.*(\\bchurn\\b|\\bscore\\b|\\bprobability\\b|\\brisk\\b|\\balgorithm\\b|\\bmodel\\b|\\bai\\b).*', 'i')
                then
                    case e.ACTION_TYPE
                        when 'Retention offer callback'
                            then 'Dear ' || e.FIRST_NAME || ', we would love to connect with you to review your coverage and explore options tailored to your needs. Please expect a call from us shortly. Suraksha General Insurance retention team.'
                        when 'Escalate open ticket'
                            then 'Dear ' || e.FIRST_NAME || ', we noticed you have an open query with us and want to make sure it is resolved as soon as possible. Our team will reach out to you shortly. Suraksha General Insurance retention team.'
                        when 'Claims follow-up call'
                            then 'Dear ' || e.FIRST_NAME || ', we want to ensure your claims experience has been smooth and satisfactory. Our team will call you soon to follow up and address any concerns. Suraksha General Insurance retention team.'
                        when 'Payment plan offer'
                            then 'Dear ' || e.FIRST_NAME || ', we understand that managing payments can sometimes be challenging. We would be happy to discuss a flexible arrangement that works comfortably for you. Suraksha General Insurance retention team.'
                        when 'Service recovery call'
                            then 'Dear ' || e.FIRST_NAME || ', your satisfaction is our top priority. We would love to speak with you to understand your experience better and explore how we can serve you well. Suraksha General Insurance retention team.'
                        else
                            'Dear ' || e.FIRST_NAME || ', as a valued customer, we would love to check in and ensure your coverage continues to meet your needs. Please feel free to reach out at any time. Suraksha General Insurance retention team.'
                    end
                else e.EXTRACTED_TEXT
            end as DRAFT_MESSAGE
        from extracted e
    )
    select
        'ACT' || lpad(row_number() over (order by PRIORITY_RANK), 6, '0'),
        CUSTOMER_ID,
        ACTION_TYPE,
        CHANNEL,
        REASON,
        CONFIDENCE,
        STATUS,
        PRIORITY_RANK,
        REVENUE_AT_RISK,
        DRAFT_MESSAGE,
        DRAFT_SOURCE,
        current_timestamp()
    from guarded;

    model_count    := (select count_if(DRAFT_SOURCE = 'model')    from RETENTION_COPILOT.ANALYTICS.RECOMMENDED_ACTIONS);
    template_count := (select count_if(DRAFT_SOURCE = 'template') from RETENTION_COPILOT.ANALYTICS.RECOMMENDED_ACTIONS);

    return 'Model drafts: ' || :model_count || ', Template drafts: ' || :template_count;
end;
$$;
