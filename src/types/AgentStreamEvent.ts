import type { AgentChart } from '@/types/AgentChart'
import type { AgentTable } from '@/types/AgentTable'

export type AgentStreamEvent =
  | { type: 'text'; text: string }
  | { type: 'thinking'; text: string }
  | { type: 'status'; message: string }
  | { type: 'tool'; id: string; name: string; detail: string }
  | { type: 'toolDone'; id: string }
  | { type: 'table'; table: AgentTable }
  | { type: 'chart'; chart: AgentChart }
  | { type: 'source'; text: string }
  | { type: 'suggestions'; questions: string[] }
  | { type: 'finished' }
  | { type: 'error'; message: string }
