import type { AgentChart } from '@/types/AgentChart'
import type { AgentTable } from '@/types/AgentTable'
import type { ChatStep } from '@/types/ChatStep'

export interface ChatEntry {
  role: 'user' | 'assistant'
  text: string
  thinking: string
  status: string
  steps: ChatStep[]
  table: AgentTable | null
  chart: AgentChart | null
  sources: string[]
  suggestions: string[]
  hasFailed: boolean
  isFinished: boolean
}
