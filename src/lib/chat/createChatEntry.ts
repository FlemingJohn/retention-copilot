import type { ChatEntry } from '@/types/ChatEntry'

export function createChatEntry(role: 'user' | 'assistant', text: string): ChatEntry {
  return { role, text, tools: [], table: null, hasFailed: false }
}
