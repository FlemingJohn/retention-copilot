set grant_admin_role = 'grant role RETENTION_COPILOT_ADMIN to user ' || current_user();
execute immediate $grant_admin_role;
set grant_reader_role = 'grant role RETENTION_COPILOT_READER to user ' || current_user();
execute immediate $grant_reader_role;
grant role RETENTION_COPILOT_ADMIN to role SYSADMIN;
