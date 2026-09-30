use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace procedure RETENTION_COPILOT.APP.RECORD_ACTION_DECISION(
    ACTION_ID varchar,
    DECISION  varchar,
    NOTE      varchar
)
returns varchar
language sql
execute as owner
as
$$
declare
    canonical_decision varchar(20);
    previous_status    varchar(20) default null;
    truncated_note     varchar(500);
    action_count       integer default 0;
begin
    if (upper(:DECISION) = 'APPROVED') then
        canonical_decision := 'Approved';
    elseif (upper(:DECISION) = 'DISMISSED') then
        canonical_decision := 'Dismissed';
    elseif (upper(:DECISION) = 'NEEDS REVIEW') then
        canonical_decision := 'Needs review';
    else
        return 'Invalid decision. Allowed values are Approved, Dismissed, or Needs review.';
    end if;

    select count(*) into :action_count
    from RETENTION_COPILOT.ANALYTICS.RECOMMENDED_ACTIONS
    where ACTION_ID = :ACTION_ID;

    if (:action_count = 0) then
        return 'No such action';
    end if;

    select STATUS into :previous_status
    from RETENTION_COPILOT.ANALYTICS.RECOMMENDED_ACTIONS
    where ACTION_ID = :ACTION_ID;

    truncated_note := left(:NOTE, 500);

    update RETENTION_COPILOT.ANALYTICS.RECOMMENDED_ACTIONS
    set STATUS = :canonical_decision
    where ACTION_ID = :ACTION_ID;

    insert into RETENTION_COPILOT.ANALYTICS.ACTION_DECISIONS (
        ACTION_ID,
        DECISION,
        NOTE,
        PREVIOUS_STATUS,
        DECIDED_BY
    ) values (
        :ACTION_ID,
        :canonical_decision,
        :truncated_note,
        :previous_status,
        current_user()
    );

    return 'Action ' || :ACTION_ID || ' marked ' || :canonical_decision;
end;
$$;
