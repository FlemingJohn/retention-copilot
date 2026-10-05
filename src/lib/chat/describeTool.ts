import type { ToolDescription } from '@/types/ToolDescription'

const knownTools: Record<string, ToolDescription> = {
  CHURN_ANALYST: { runningLabel: 'Asking the churn analyst', doneLabel: 'Asked the churn analyst', kind: 'analyst' },
  system_execute_sql: { runningLabel: 'Running a SQL query', doneLabel: 'Ran a SQL query', kind: 'sql' },
  CALL_SEARCH_TOOL: {
    runningLabel: 'Searching call transcripts',
    doneLabel: 'Searched call transcripts',
    kind: 'search',
  },
  data_to_chart: { runningLabel: 'Drawing a chart', doneLabel: 'Drew a chart', kind: 'chart' },
  RECORD_DECISION_TOOL: {
    runningLabel: 'Recording a decision',
    doneLabel: 'Recorded a decision',
    kind: 'decision',
  },
}

export function describeTool(name: string): ToolDescription {
  return knownTools[name] ?? { runningLabel: `Running ${name}`, doneLabel: `Ran ${name}`, kind: 'other' }
}
