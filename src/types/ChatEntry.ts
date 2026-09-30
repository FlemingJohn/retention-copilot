import type { AgentTable } from '@/types/AgentTable'

export interface ChatEntry {
  role: 'user' | 'assistant'
  text: string
  tools: string[]
  table: AgentTable | null
  hasFailed: boolean
}
