use role ACCOUNTADMIN;

create database if not exists COCO_APP;

create authentication policy if not exists COCO_APP.PUBLIC.PAT_NO_NETWORK
  pat_policy = (network_policy_evaluation = NOT_ENFORCED);
