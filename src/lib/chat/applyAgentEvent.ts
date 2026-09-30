import type { AgentStreamEvent } from '@/types/AgentStreamEvent'
import type { ChatEntry } from '@/types/ChatEntry'

const failureText = 'The assistant could not finish that request. Please try again.'

export function applyAgentEvent(entry: ChatEntry, event: AgentStreamEvent): ChatEntry {
  switch (event.type) {
    case 'text':
      return { ...entry, text: entry.text + event.text }
    case 'tool':
      return entry.tools.includes(event.name) ? entry : { ...entry, tools: [...entry.tools, event.name] }
    case 'table':
      return { ...entry, table: event.table }
    case 'error':
      return { ...entry, hasFailed: true, text: entry.text === '' ? failureText : entry.text }
    default:
      return entry
  }
}
