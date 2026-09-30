use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace procedure RETENTION_COPILOT.GENERATOR.WRITE_TRANSCRIPT_BATCH(
    P_FIRST_ID number(6,0),
    P_LAST_ID number(6,0)
)
returns varchar
language sql
execute as caller
as
$$
begin
    delete from RETENTION_COPILOT.GENERATOR.TRANSCRIPT_DRAFTS
    where PLAN_ID between :P_FIRST_ID and :P_LAST_ID;

    insert into RETENTION_COPILOT.GENERATOR.TRANSCRIPT_DRAFTS (PLAN_ID, RESPONSE)
    with plan_data as (
        select
            cp.PLAN_ID,
            cp.CUSTOMER_ID,
            cp.CALL_AT,
            cp.AGENT_ID,
            cp.AGENT_NAME,
            cp.TOPIC,
            cp.STYLE,
            cp.COMPETITOR,
            cp.TONE,
            cp.DURATION_TARGET,
            cp.POLICY_ID,
            cp.PRODUCT_TYPE,
            cp.PREMIUM_MONTHLY,
            cu.FIRST_NAME,
            cu.CITY,
            cl.RECENT_CLAIM_TYPE,
            round(cl.RECENT_CLAIM_AMOUNT) as RECENT_CLAIM_AMOUNT,
            cl.RECENT_CLAIM_STATUS,
            coalesce(lp.LATE_COUNT, 0) as LATE_COUNT
        from RETENTION_COPILOT.GENERATOR.CALL_PLAN cp
        join RETENTION_COPILOT.RAW.CUSTOMERS cu on cu.CUSTOMER_ID = cp.CUSTOMER_ID
        left join (
            select CUSTOMER_ID,
                CLAIM_TYPE as RECENT_CLAIM_TYPE,
                CLAIM_AMOUNT as RECENT_CLAIM_AMOUNT,
                STATUS as RECENT_CLAIM_STATUS,
                row_number() over (partition by CUSTOMER_ID order by CLAIM_DATE desc) as rn
            from RETENTION_COPILOT.RAW.CLAIMS
        ) cl on cl.CUSTOMER_ID = cp.CUSTOMER_ID and cl.rn = 1
        left join (
            select CUSTOMER_ID, count(*) as LATE_COUNT
            from RETENTION_COPILOT.RAW.PAYMENTS
            where STATUS in ('Late', 'Failed')
            and DUE_DATE >= '2025-10-01'
            group by CUSTOMER_ID
        ) lp on lp.CUSTOMER_ID = cp.CUSTOMER_ID
        where cp.PLAN_ID between :P_FIRST_ID and :P_LAST_ID
        and not exists (
            select 1 from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS t
            where t.TRANSCRIPT_ID = 'CALL' || lpad(cp.PLAN_ID::varchar, 6, '0')
        )
    )
    select
        pd.PLAN_ID,
        snowflake.cortex.complete(
            'claude-haiku-4-5',
            array_construct(object_construct('role', 'user', 'content',
                'Write a realistic phone call transcript for an Indian general insurance call center. '
                || 'The customer ' || pd.FIRST_NAME || ' from ' || pd.CITY
                || ' is calling Suraksha General Insurance. '
                || 'Agent ' || pd.AGENT_NAME
                || ' answers and greets the customer on behalf of Suraksha General Insurance. '
                || 'The customer has a ' || pd.PRODUCT_TYPE || ' insurance policy, policy number ' || pd.POLICY_ID
                || ', with a monthly premium of Rs ' || pd.PREMIUM_MONTHLY::varchar || '. '
                || 'The call is about: ' || pd.TOPIC || '. '
                || case when pd.RECENT_CLAIM_TYPE is not null
                    then 'The customer recently filed a ' || pd.RECENT_CLAIM_TYPE
                        || ' claim for Rs ' || pd.RECENT_CLAIM_AMOUNT::varchar
                        || ' which is ' || pd.RECENT_CLAIM_STATUS || '. '
                    else '' end
                || case when pd.LATE_COUNT > 0
                    then 'The customer has ' || pd.LATE_COUNT::varchar
                        || ' late or failed payments in the last nine months. '
                    else '' end
                || pd.TONE || ' '
                || case pd.STYLE
                    when 'hinglish' then 'Write in Indian English with occasional Hindi words like haan, achha, theek hai, kya, bhai, ji. '
                    when 'formal' then 'Use formal, polished English. '
                    when 'hurried' then 'The customer speaks in short, rushed sentences. '
                    when 'chatty' then 'The customer is talkative and goes on tangents. '
                    else 'Use casual, everyday English. ' end
                || case when pd.COMPETITOR != ''
                    then 'The customer mentions considering ' || pd.COMPETITOR || '. '
                    else '' end
                || 'Rules: whenever a policy number comes up use exactly ' || pd.POLICY_ID
                || '; the customer may not remember it and the agent reads it out. '
                || 'Say all rupee amounts as whole rupees in Indian numbering, for example Rs 54,831 or Rs 1,200. Never say paise. '
                || 'Write ' || case pd.DURATION_TARGET
                    when 'short' then '120 to 160'
                    when 'medium' then '180 to 250'
                    else '270 to 350' end || ' words of dialogue only. '
                || 'Alternating lines starting with Agent: and Customer:. '
                || 'No narration, stage directions, headings, markdown, asterisks, or parenthetical actions. '
                || 'Never use the words churn, mood, score, or cancel-risk.'
            )),
            object_construct('max_tokens', 700)
        ) as RESPONSE
    from plan_data pd;

    insert into RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS
        (TRANSCRIPT_ID, CUSTOMER_ID, TICKET_ID, CALL_AT, DURATION_SECONDS, AGENT_ID, TRANSCRIPT_TEXT)
    select
        'CALL' || lpad(d.PLAN_ID::varchar, 6, '0'),
        cp.CUSTOMER_ID,
        null,
        cp.CALL_AT,
        greatest(30, round(array_size(split(d.RESPONSE['choices'][0]['messages']::varchar, ' ')) / 130.0 * 60
            + (abs(hash(d.PLAN_ID::varchar || 'dur')) % 31 - 15))),
        cp.AGENT_ID,
        d.RESPONSE['choices'][0]['messages']::varchar
    from RETENTION_COPILOT.GENERATOR.TRANSCRIPT_DRAFTS d
    join RETENTION_COPILOT.GENERATOR.CALL_PLAN cp on cp.PLAN_ID = d.PLAN_ID
    where d.PLAN_ID between :P_FIRST_ID and :P_LAST_ID
    and not exists (
        select 1 from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS t
        where t.TRANSCRIPT_ID = 'CALL' || lpad(d.PLAN_ID::varchar, 6, '0')
    );

    insert into RETENTION_COPILOT.GENERATOR.TRANSCRIPT_USAGE
        (PLAN_ID, TRANSCRIPT_ID, MODEL, PROMPT_TOKENS, COMPLETION_TOKENS, TOTAL_TOKENS)
    select
        d.PLAN_ID,
        'CALL' || lpad(d.PLAN_ID::varchar, 6, '0'),
        'claude-haiku-4-5',
        d.RESPONSE['usage']['prompt_tokens']::number,
        d.RESPONSE['usage']['completion_tokens']::number,
        d.RESPONSE['usage']['total_tokens']::number
    from RETENTION_COPILOT.GENERATOR.TRANSCRIPT_DRAFTS d
    where d.PLAN_ID between :P_FIRST_ID and :P_LAST_ID;

    let v_count number := (select count(*)
        from RETENTION_COPILOT.GENERATOR.TRANSCRIPT_DRAFTS
        where PLAN_ID between :P_FIRST_ID and :P_LAST_ID);
    return :v_count || ' transcripts written';
end;
$$;
