create or replace procedure RETENTION_COPILOT.ANALYTICS.ENRICH_NEW_CALLS()
returns text
language sql
execute as owner
as
$$
begin
  let STREAM_ROW_COUNT number := (select count(*) from RETENTION_COPILOT.RAW.CALL_TRANSCRIPT_STREAM);
  if (STREAM_ROW_COUNT = 0) then
    return 'Stream is empty, no new calls to process';
  end if;
  create or replace temporary table TEMP_STREAM_CONSUMED_ROWS as
    select TRANSCRIPT_ID from RETENTION_COPILOT.RAW.CALL_TRANSCRIPT_STREAM;
  let FIRST_NUM number;
  let LAST_NUM number;
  let NEW_COUNT number;
  select
    coalesce(min(to_number(substr(t.TRANSCRIPT_ID, 5))), 0),
    coalesce(max(to_number(substr(t.TRANSCRIPT_ID, 5))), 0),
    count(*)
  into :FIRST_NUM, :LAST_NUM, :NEW_COUNT
  from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS t
  left join RETENTION_COPILOT.ANALYTICS.CALL_INSIGHTS ci on ci.TRANSCRIPT_ID = t.TRANSCRIPT_ID
  where ci.TRANSCRIPT_ID is null;
  if (NEW_COUNT = 0) then
    return 'Stream consumed but all transcripts already enriched, 0 new calls';
  end if;
  call RETENTION_COPILOT.ANALYTICS.ENRICH_CALLS(:FIRST_NUM, :LAST_NUM);
  alter dynamic table RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE refresh;
  return 'Enriched ' || :NEW_COUNT || ' call(s) from numeric id ' || :FIRST_NUM || ' to ' || :LAST_NUM;
end;
$$;
