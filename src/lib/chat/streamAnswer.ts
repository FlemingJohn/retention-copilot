import { readJsonOrThrow } from '@/lib/api/readJsonOrThrow'
import { readEventLines } from '@/lib/chat/readEventLines'
import type { AgentStreamEvent } from '@/types/AgentStreamEvent'
import type { ChatEntry } from '@/types/ChatEntry'

function toMessages(entries: ChatEntry[]) {
  return entries
    .filter((entry) => entry.text.trim() !== '')
    .map((entry) => ({ role: entry.role, text: entry.text }))
}

export async function streamAnswer(history: ChatEntry[], onEvent: (event: AgentStreamEvent) => void): Promise<void> {
  const response = await fetch('/api/questions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ messages: toMessages(history) }),
  })
  if (!response.ok || response.body === null) {
    await readJsonOrThrow(response)
    return
  }
  for await (const line of readEventLines(response.body)) {
    onEvent(JSON.parse(line) as AgentStreamEvent)
  }
}
