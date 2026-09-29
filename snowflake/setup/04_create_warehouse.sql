create warehouse if not exists RETENTION_COPILOT_WH
  warehouse_size = 'XSMALL'
  auto_suspend = 60
  auto_resume = true
  initially_suspended = true
  resource_monitor = RETENTION_COPILOT_MONITOR;
