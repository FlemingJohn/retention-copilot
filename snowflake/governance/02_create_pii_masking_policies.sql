create schema if not exists RETENTION_COPILOT.GOVERNANCE;

create or replace masking policy RETENTION_COPILOT.GOVERNANCE.MASK_NAME
  as (VALUE string) returns string ->
  case
    when is_role_in_session('ACCOUNTADMIN') or is_role_in_session('RETENTION_COPILOT_ADMIN')
      then VALUE
    else left(VALUE, 1) || '****'
  end;

create or replace masking policy RETENTION_COPILOT.GOVERNANCE.MASK_EMAIL
  as (VALUE string) returns string ->
  case
    when is_role_in_session('ACCOUNTADMIN') or is_role_in_session('RETENTION_COPILOT_ADMIN')
      then VALUE
    else '****@' || split_part(VALUE, '@', 2)
  end;

create or replace masking policy RETENTION_COPILOT.GOVERNANCE.MASK_PHONE
  as (VALUE string) returns string ->
  case
    when is_role_in_session('ACCOUNTADMIN') or is_role_in_session('RETENTION_COPILOT_ADMIN')
      then VALUE
    else '**********' || right(VALUE, 2)
  end;
