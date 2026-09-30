import type { AgentTable } from '@/types/AgentTable'

export type AgentStreamEvent =
  | { type: 'text'; text: string }
  | { type: 'tool'; name: string }
  | { type: 'table'; table: AgentTable }
  | { type: 'finished' }
  | { type: 'error'; message: string }
